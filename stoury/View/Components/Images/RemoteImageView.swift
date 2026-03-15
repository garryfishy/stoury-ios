import SwiftUI
import QuickLookThumbnailing
import UIKit
import WebKit

struct RemoteImageView<Placeholder: View>: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var allowsSVGMarkupFallback = false
    @ViewBuilder let placeholder: () -> Placeholder

    var body: some View {
        if let url, Self.isPDFURL(url) {
            placeholder()
        } else if let url, Self.isSVGURL(url) {
            SVGRemoteImageView(
                url: url,
                contentMode: contentMode,
                allowsMarkupFallback: allowsSVGMarkupFallback,
                placeholder: placeholder
            )
        } else {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .empty, .failure:
                    placeholder()
                @unknown default:
                    placeholder()
                }
            }
        }
    }

    private static func isSVGURL(_ url: URL) -> Bool {
        if url.pathExtension.lowercased() == "svg" {
            return true
        }

        return url.absoluteString.lowercased().contains(".svg")
    }

    private static func isPDFURL(_ url: URL) -> Bool {
        if url.pathExtension.lowercased() == "pdf" {
            return true
        }

        return url.absoluteString.lowercased().contains(".pdf")
    }
}

private struct SVGRemoteImageView<Placeholder: View>: View {
    let url: URL
    let contentMode: ContentMode
    let allowsMarkupFallback: Bool
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var renderedImage: UIImage?
    @State private var svgMarkup: String?
    @State private var hasFailed = false

    var body: some View {
        Group {
            if let renderedImage {
                Image(uiImage: renderedImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if let svgMarkup {
                SVGMarkupWebView(
                    svgMarkup: svgMarkup,
                    contentMode: contentMode
                )
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadSVGThumbnail()
        }
    }

    @MainActor
    private func loadSVGThumbnail() async {
        guard renderedImage == nil, !hasFailed else { return }

        if let cachedImage = SVGThumbnailCache.shared.image(for: url) {
            renderedImage = cachedImage
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  200 ... 299 ~= httpResponse.statusCode else {
                hasFailed = true
                return
            }

            let temporaryURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("svg")
            try data.write(to: temporaryURL, options: .atomic)

            defer {
                try? FileManager.default.removeItem(at: temporaryURL)
            }

            do {
                let thumbnail = try await SVGThumbnailGenerator.shared.thumbnail(for: temporaryURL)
                SVGThumbnailCache.shared.insert(thumbnail, for: url)
                renderedImage = thumbnail
            } catch {
                if allowsMarkupFallback,
                   let markup = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .unicode) {
                    svgMarkup = markup
                } else {
                    hasFailed = true
                }
            }
        } catch {
            hasFailed = true
        }
    }
}

private struct SVGMarkupWebView: UIViewRepresentable {
    let svgMarkup: String
    let contentMode: ContentMode

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.bounces = false
        webView.isUserInteractionEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.lastMarkup != svgMarkup else { return }
        context.coordinator.lastMarkup = svgMarkup

        let normalizedMarkup = Self.normalizedSVGMarkup(
            for: svgMarkup,
            contentMode: contentMode
        )
        webView.loadHTMLString(Self.htmlDocument(for: normalizedMarkup), baseURL: nil)
    }

    private static func htmlDocument(for markup: String) -> String {
        """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            background: transparent;
            overflow: hidden;
        }
        body {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        svg, img {
            width: 100%;
            height: 100%;
            display: block;
            overflow: hidden;
        }
        </style>
        </head>
        <body>
        \(markup)
        </body>
        </html>
        """
    }

    private static func normalizedSVGMarkup(
        for markup: String,
        contentMode: ContentMode
    ) -> String {
        guard let svgOpenTagRange = markup.range(of: "<svg", options: [.caseInsensitive]),
              let tagCloseRange = markup[svgOpenTagRange.lowerBound...].range(of: ">") else {
            return markup
        }

        let rootTagRange = svgOpenTagRange.lowerBound..<tagCloseRange.upperBound
        var rootTag = String(markup[rootTagRange])

        let preserveAspectPattern = #"preserveAspectRatio\s*=\s*['"][^'"]*['"]"#
        rootTag = rootTag.replacingOccurrences(
            of: preserveAspectPattern,
            with: "",
            options: .regularExpression
        )

        let preserveAspectValue = contentMode == .fill ? "xMidYMid slice" : "xMidYMid meet"
        let injectedAttributes = #" preserveAspectRatio="\#(preserveAspectValue)" width="100%" height="100%""#
        rootTag = rootTag.replacingOccurrences(of: ">", with: injectedAttributes + ">", options: .backwards)

        return markup.replacingCharacters(in: rootTagRange, with: rootTag)
    }

    final class Coordinator {
        var lastMarkup: String?
    }
}

private final class SVGThumbnailCache {
    static let shared = SVGThumbnailCache()

    private let cache = NSCache<NSString, UIImage>()

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url.absoluteString as NSString)
    }

    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }
}

private final class SVGThumbnailGenerator {
    static let shared = SVGThumbnailGenerator()

    func thumbnail(for fileURL: URL) async throws -> UIImage {
        let request = QLThumbnailGenerator.Request(
            fileAt: fileURL,
            size: CGSize(width: 1200, height: 1200),
            scale: UIScreen.main.scale,
            representationTypes: .thumbnail
        )

        let representation = try await withCheckedThrowingContinuation { continuation in
            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
                if let thumbnail {
                    continuation.resume(returning: thumbnail)
                } else {
                    continuation.resume(throwing: error ?? URLError(.cannotDecodeContentData))
                }
            }
        }

        return representation.uiImage
    }
}

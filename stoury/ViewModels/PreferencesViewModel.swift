import Foundation
import Combine

@MainActor
final class PreferencesViewModel: ObservableObject {
    @Published var items: [PreferenceItem] = []
    @Published var selectedIDs: Set<String> = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let apiService: APIService

    init(apiService: APIService? = nil, sessionStore: SessionStore? = nil) {
        if let apiService {
            self.apiService = apiService
        } else {
            let store = sessionStore ?? SessionStore()
            self.apiService = APIService(sessionStore: store)
        }
    }

    func loadPreferences() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            async let categoriesTask = apiService.getPreferences()
            async let myPreferencesTask = apiService.getMyPreferences()

            let categories = try await categoriesTask
            let myPreferences = (try? await myPreferencesTask) ?? []

            items = categories.map { preference in
                PreferenceItem(
                    id: preference.id.uuidString,
                    title: preference.name,
                    subtitle: preference.description,
                    imageName: imageName(for: preference.slug),
                    imageScale: imageScale(for: preference.slug),
                    imageOffsetY: imageOffset(for: preference.slug)
                )
            }

            let selected = Set(myPreferences.map { $0.id.uuidString })
            selectedIDs = selected
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func savePreferences() async -> Bool {
        guard !selectedIDs.isEmpty else {
            errorMessage = "Pilih minimal 1 preferensi."
            return false
        }

        let ids = selectedIDs.compactMap { UUID(uuidString: $0) }
        if ids.isEmpty {
            errorMessage = "Preferensi tidak valid."
            return false
        }

        errorMessage = nil
        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await apiService.updatePreferences(categoryIds: ids)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func imageName(for slug: String) -> String {
        switch slug {
        case "popular":
            return "populer"
        case "food":
            return "makanan"
        case "shopping":
            return "belanja"
        case "history":
            return "sejarah"
        default:
            return slug
        }
    }

    private func imageScale(for slug: String) -> CGFloat {
        switch slug {
        case "popular", "food", "shopping":
            return 1.4
        case "history":
            return 1.0
        default:
            return 1.0
        }
    }

    private func imageOffset(for slug: String) -> CGFloat {
        switch slug {
        case "history":
            return 0
        default:
            return 12
        }
    }
}

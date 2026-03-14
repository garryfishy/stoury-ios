//
//  MapPreview.swift
//  stoury
//
//  Created by Garry Agassi on 12/03/26.
//

import SwiftUI
import MapKit

struct MapPreview: View {
    let title: String
    let latitude: Double
    let longitude: Double

    @Environment(\.openURL) private var openURL

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private var position: MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    private var mapsURL: URL? {
        var components = URLComponents(string: "http://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "ll", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "q", value: title)
        ]
        return components?.url
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(initialPosition: position){
                Marker(title, coordinate: coordinate)
            }
            .mapStyle(.imagery)
            .frame(height: 180)
            
            Button {
                guard let mapsURL else { return }
                openURL(mapsURL)
            } label: {
                HStack {
                    Image("ic-direction")
                        .padding(8)
                        .background(Color("Beige"))
                        .cornerRadius(50)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)

            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MapPreview(title: "Nongsa Digital Park", latitude: 1.1854, longitude: 104.1017)
}

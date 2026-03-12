//
//  MapPreview.swift
//  stoury
//
//  Created by Garry Agassi on 12/03/26.
//

import SwiftUI
import MapKit

struct MapPreview: View {
    let position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 1.1854, longitude: 104.1017),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    let coordinate = CLLocationCoordinate2D(
        latitude: 1.1854,
        longitude: 104.1017
    )


    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(initialPosition: position){
                Marker("Nongsa Digital Park", coordinate: coordinate)
                
            }
            .mapStyle(.imagery)
            .frame(height: 180)
            
            Button {
            print("Something")
                
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


            
        }
    }
}

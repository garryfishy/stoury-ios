//
//  SearchInputField.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import SwiftUI


struct SearchInputField: View {
    @Binding var text: String
    var placeholder: String = "Cari lokasi tujuan Anda"
    
    var body: some View {
        HStack(spacing: 12){
            ZStack{
                Circle()
                    .fill(Color.orange)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.black)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label : {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white)
        .overlay {
                   RoundedRectangle(cornerRadius: 18)
                       .stroke(Color.orange.opacity(0.7), lineWidth: 1)
               }
               .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

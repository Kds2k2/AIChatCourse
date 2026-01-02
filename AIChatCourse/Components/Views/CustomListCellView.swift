//
//  CustomListCellView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//

import SwiftUI

struct CustomListCellView: View {
    
    var imageName: String? = Constants.randomImage
    var title: String? = "Alien"
    var subtitle: String? = "An alien that is smiling in the park."
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                if let imageName {
                    ImageLoaderView(urlString: imageName)
                } else {
                    Rectangle()
                        .fill(.accent)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 60)
            .outlineBackground(lineWidth: 1.0)
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 5) {
                if let title {
                    Text(title)
                        .font(.headline)
                }

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .padding(.vertical, 4)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        VStack {
            CustomListCellView()
            CustomListCellView(title: nil)
            CustomListCellView(subtitle: nil)
            CustomListCellView(imageName: nil)
        }
    }
}

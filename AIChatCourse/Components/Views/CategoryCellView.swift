//
//  CategoryCellView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//

import SwiftUI

struct CategoryCellView: View {
    
    var title: String = "Aliens"
    var imageName: String = Constants.randomImage
    
    var font: Font = .title2
    var cornerRadius: CGFloat = 16
    var lineWidth: CGFloat = 0.0
    var contentMode: ContentMode = .fit
    
    var body: some View {
        ImageLoaderView(urlString: imageName)
            .aspectRatio(1, contentMode: contentMode)
            .overlay(alignment: .bottomLeading) {
                Text(title)
                    .font(font)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .gradientBackground()
            }
            .outlineBackground(lineWidth: lineWidth)
            .cornerRadius(cornerRadius)
    }
}

#Preview {
    VStack {
        CategoryCellView(lineWidth: 1.0)
            .frame(width: 150)
        CategoryCellView(lineWidth: 0.0)
            .frame(width: 150)
        CategoryCellView(lineWidth: 1.0)
            .frame(width: 300)
        
        CategoryCellView(lineWidth: 1.0, contentMode: .fill)
    }
}

//
//  ThumbnailPreview.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.12.2022.
//

import SwiftUI

struct ThumbnailPreview: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let thumbnail: UIImage
    
    init(_ thumbnail: UIImage) {
        self.thumbnail = thumbnail
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Spacer()
                    Image(uiImage: thumbnail)
                        .resizedToFill(width: proxy.size.width, height: proxy.size.height * 0.9)
                        .cornerRadius(12)
                }
                NavigationBar(inlineTitle: Strings.ContentCreation.customThumbnail, onDismiss: {}, trailingView: {
                    Buttons.QuickActionButton(
                        text: Strings.Buttons.close,
                        action: dismiss.callAsFunction
                    )
                })
                .backButtonHidden(true)
            }
        }
        .primaryBackground()
    }
}

#if DEBUG
struct ThumbnailPreview_Previews: PreviewProvider {
    
    static var previews: some View {
       ThumbnailPreviewView()
    }
    
    private struct ThumbnailPreviewView: View {
        
        @State var show = true
        
        var body: some View {
            Color.white
                .onTapGesture {
                    show.toggle()
                }
                .fullScreenCover(isPresented: $show) {
                    ThumbnailPreview(UIImage(named: "sweatshirt")!)
                }
        }
    }
}
#endif

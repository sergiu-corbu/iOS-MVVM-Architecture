//
//  AsyncImageView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 24.11.2022.
//

import SwiftUI
import Kingfisher

struct AsyncImageView<Placeholder: View>: View {
    
    let imageURL: URL?
    var localImage: UIImage?
    var cancelOnDisappear: Bool = true
    var backgroundColor: Color = .lightGrey
    var imageProcessor: ImageProcessor? = nil
    
    @ViewBuilder let placeholder: Placeholder
    
    var body: some View {
        if let localImage {
            Image(uiImage: localImage)
                .resizable()
        } else {
            KFImage(imageURL)
                .resizable()
                .memoryCacheExpiration(.seconds(15))
                .cancelOnDisappear(cancelOnDisappear)
                .fade(duration: 0.3)
                .appendProcessor(imageProcessor ?? DefaultImageProcessor())
                .placeholder {
                    placeholder
                        .transition(.opacity.animation(.easeInOut))
                }
                .background(backgroundColor)
                .onDisappear(perform: handleOnDisappear)
        }
    }
    
    private func handleOnDisappear() {
        if let imageURL {
            ImageCache.default.removeImage(forKey: imageURL.absoluteString, fromDisk: false)
        }
    }
    
    func clearBackground() -> Self {
        return setBackgroundColor(.clear)
    }
    
    func setBackgroundColor(_ color: Color) -> Self {
        var mutableSelf = self
        mutableSelf.backgroundColor = color
        return mutableSelf
    }
    
    func downsampled(targetSize: CGSize) -> Self {
        var mutableSelf = self
        mutableSelf.imageProcessor = DownsamplingImageProcessor(size: targetSize)
        return mutableSelf
    }
}

extension AsyncImageView where Placeholder == EmptyView {
    
    init(imageURL: URL?, localImage: UIImage? = nil, cancelOnDisappear: Bool = false) {
        self.imageURL = imageURL
        self.localImage = localImage
        self.cancelOnDisappear = cancelOnDisappear
        self.placeholder = EmptyView()
    }
}


extension AsyncImageView where Placeholder == Image {
    
    init(imageURL: URL?, localImage: UIImage? = nil, cancelOnDisappear: Bool = false, placeholderImage: ImageResource) {
        self.imageURL = imageURL
        self.localImage = localImage
        self.cancelOnDisappear = cancelOnDisappear
        self.placeholder = Image(placeholderImage)
    }
}

extension URL {
    
    static var sampleImageURL: URL {
        return URL(string: "https://picsum.photos/200/300")!
    }
    
    static func sampleImageURL(width: Int = 200, height: Int = 300) -> URL {
        return URL(string: "https://picsum.photos/\(width)/\(height)")!
    }
}

#if DEBUG
struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImageView(imageURL: nil, localImage: UIImage(named: "user_profile"))
            .aspectRatio(contentMode: .fit)
            .cornerRadius(5)
            .frame(height: 200)
    }
}
#endif

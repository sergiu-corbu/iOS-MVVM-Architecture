//
//  ApprovedCreatorView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.11.2022.
//

import SwiftUI

struct ApprovedCreatorView: View {
        
    let action: () -> Void
    
    var body: some View {
        mainContent
            .background(VisualEffectView(blurStyle: .systemUltraThinMaterialLight, vibrancyStyle: .fill))
            .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private var mainContent: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Text(Strings.Authentication.creatorApproved)
                    .font(kernedFont: .Main.h1MediumKerned)
                    .foregroundColor(.brightGold)
                    .fixedSize(horizontal: false, vertical: true)
                Text(Strings.Authentication.creatorFillProfileMessage)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.ebony)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 16)
            Text(Strings.Authentication.fillProfileGuidance)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
            fillInProfileView
            Buttons.FilledRoundedButton(title: Strings.Buttons.getStarted, action: action)
        }
        .multilineTextAlignment(.center)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, safeAreaInsets.bottom)
    }
    
    private var fillInProfileView: some View {
        VStack(spacing: 8) {
            FillInProfile(image: .mediaContentIcon, text: Strings.Placeholders.addProfilePicture)
            FillInProfile(image: .editIcon, text: Strings.Placeholders.fillCreatorBio)
        }
        .padding(.horizontal, 16)
    }
}

struct FillInProfile: View {
    
    let image: ImageResource
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                Image(image)
            }
            Text(text)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
            Spacer()
        }
        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(Color.cultured.opacity(0.9).cornerRadius(5))
    }
}

#if DEBUG
struct ApprovedCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(previewDevices) {
            GeometryReader { proxy in
                ZStack{
                    Image("sweatshirt")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    ApprovedCreatorView(action: {})
                }
                .frame(height: proxy.size.height / 2)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .previewDevice($0)
        }
    }
}
#endif

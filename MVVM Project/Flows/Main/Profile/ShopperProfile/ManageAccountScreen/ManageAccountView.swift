//
//  ManageAccountView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.11.2022.
//

import SwiftUI

struct ManageAccountView: View {
    
    @ObservedObject var viewModel: ManageAccountViewModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 22) {
                NavigationBar(inlineTitle: Strings.MenuSection.manageAccount) {
                    viewModel.onBack.send()
                }
                deleteAccountView
                Spacer()
                AppVersionView()
            }
            .primaryBackground()
            
            Buttons.FillBorderedButton(title: Strings.Buttons.logOut, isLoading: viewModel.isLoading) {
                Image(.logOutIcon)
            } action: {
                viewModel.onPresentLogOutAlert.send()
            }
            .padding(.horizontal, 16)
        }
        .errorToast(error: $viewModel.backendError)
    }
    
    private var deleteAccountView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Button {
                viewModel.onDeleteAccount.send()
            } label: {
                HStack {
                    Text(Strings.MenuSection.deleteAccount)
                        .font(kernedFont: .Secondary.p1RegularKerned)
                    Spacer()
                    Image(.chevronRight)
                        .renderingMode(.template)
                }
                .foregroundColor(.firebrick)
                .background(Color.cultured)
            }
            .buttonStyle(.plain)
            Text(Strings.Profile.deleteAccountDescription)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
        }
        .padding(.horizontal, 16)
    }
}

struct AppVersionView: View {
    
    var body: some View {
        if let appVersion = Constants.APP_VERSION as? String {
            Text(Strings.Others.appVersion(appVersion))
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.paleSilver)
                .frame(maxWidth: .infinity)
        }
    }
}

#if DEBUG
struct ManageAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ManageAccountView(viewModel: ManageAccountViewModel(userSession: MockUserSession(), authenticationService: MockAuthService()))
    }
}
#endif

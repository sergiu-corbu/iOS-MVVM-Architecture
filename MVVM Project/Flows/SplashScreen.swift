//
//  SplashScreen.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.10.2022.
//

import SwiftUI

struct SplashScreen: View {
    
    @State private var isAnimating = false
    let onFinishedInteraction: () -> Void
    
    var body: some View {
        ZStack {
            Color.darkGreen
                .ignoresSafeArea(.container, edges: .vertical)
//            Image(.logo)
//                .scaleEffect(isAnimating ? 1 : 0, anchor: .center)
//                .animation(.spring(response: 2, dampingFraction: 0.75, blendDuration: 1), value: isAnimating)
        }
        .task {
            isAnimating = true
            await Task.sleep(seconds: 2)
            onFinishedInteraction()
        }
    }
}

class SplashViewController: UIHostingController<SplashScreen> {
    
    init(onFinishedInteraction: @escaping () -> Void) {
        super.init(rootView: SplashScreen(onFinishedInteraction: onFinishedInteraction))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#if DEBUG
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(onFinishedInteraction: {})
    }
}
#endif

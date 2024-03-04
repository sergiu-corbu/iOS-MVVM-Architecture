//
//  TabBarController + AnimatedTransitioning.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.11.2022.
//

import UIKit

class TabBarAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let viewControllers: [UIViewController]
    let transitionDuration: TimeInterval
    
    init(viewControllers: [UIViewController], transitionDuration: TimeInterval = 0.3) {
        self.viewControllers = viewControllers
        self.transitionDuration = transitionDuration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let startVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
              let endVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let currentFrame = transitionContext.initialFrame(for: startVC)
        
        var startFrameEnd = currentFrame
        var endFrameStart = currentFrame
        
        let isForwardTransitioning = compareIndexes(startVC: startVC, endVC: endVC)
        
        startFrameEnd.origin.x = currentFrame.origin.x + (isForwardTransitioning ? -currentFrame.width : currentFrame.width)
        endFrameStart.origin.x = currentFrame.origin.x + (isForwardTransitioning ? currentFrame.width : -currentFrame.width)
        
        endVC.view.frame = endFrameStart
        
        transitionContext.containerView.addSubview(endVC.view)
        
        UIView.animate(withDuration: self.transitionDuration, delay: 0, options: .transitionCrossDissolve) {
            startVC.view.frame = startFrameEnd
            endVC.view.frame = currentFrame
        } completion: { transitionStatus in
            startVC.view.removeFromSuperview()
            transitionContext.completeTransition(transitionStatus)
        }
    }
    
    private func compareIndexes(startVC: UIViewController, endVC: UIViewController) -> Bool {
        guard let firstIndex = viewControllers.firstIndex(of: startVC),
              let lastIndex = viewControllers.firstIndex(of: endVC) else {
                  return true
              }
        return firstIndex < lastIndex
    }
}

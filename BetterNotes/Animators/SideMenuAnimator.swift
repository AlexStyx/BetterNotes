//
//  PopAnimator.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 16.02.2021.
//

import UIKit

class SideMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration: TimeInterval
    var presenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.viewController(forKey: .to)?.view,
              let fromView = transitionContext.viewController(forKey: .from)?.view else {
            return
        }
        
        let presentingView = presenting ? toView : fromView
        containerView.addSubview(presentingView)
        
        let size = CGSize(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.height)
        
        let offScreenFrame = CGRect(origin: CGPoint(x: -size.width, y: 0), size: size)
        let onScreenFrame = CGRect(origin: .zero, size: size)
        
        presentingView.frame = presenting ? offScreenFrame : onScreenFrame
        
        UIView.animate(withDuration: duration) {
            presentingView.frame = self.presenting ? onScreenFrame : offScreenFrame
        } completion: { _ in
            if !self.presenting {
                presentingView.removeFromSuperview()
            }
            transitionContext.completeTransition(true)
        }
    }
    
    init(duration: TimeInterval) {
        self.duration = duration
    }
}

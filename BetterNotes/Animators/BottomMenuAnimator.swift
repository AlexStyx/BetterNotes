//
//  RecorderAnimator.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 18.02.2021.
//

import UIKit

class BottomMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration: TimeInterval
    var presenting = true
    
    init(duration: TimeInterval) {
        self.duration = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.viewController(forKey: .to)?.view,
              let fromView = transitionContext.viewController(forKey: .from)?.view else {
            return
        }
        
        let presentingView = presenting ? toView : fromView

        containerView.addSubview(presentingView)

        let size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3)

        let offScreenFrame = CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height + size.height), size: size)
        let onScreenFrame = CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - size.height), size: size)
        
        presentingView.frame = presenting ? offScreenFrame : onScreenFrame

        UIView.animate(withDuration: duration) {
            presentingView.frame = self.presenting ? onScreenFrame : offScreenFrame
            presentingView.layer.cornerRadius = self.presenting ? 40 : 0
        } completion: { _ in
            if !self.presenting {
                presentingView.removeFromSuperview()
            }
            transitionContext.completeTransition(true)
        }
    }
}

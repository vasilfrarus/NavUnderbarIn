//
//  B32UnderViewController.swift
//
//  Created by Vasiliy Fedotov on 09/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import UIKit

fileprivate let navItemPlaceHolder = "   "

fileprivate enum B32UnderviewStatus {
    case hidden
    case shownPartially
    case shownFully
}

@IBDesignable
class B32UnderViewController: UIViewController {

    fileprivate static var transitionIsOn: Bool = false
    
    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    fileprivate var swipeToBackInteractor : UIPercentDrivenInteractiveTransition?

    @IBOutlet public weak var scrollUnderView: UIScrollView!
    @IBOutlet public weak var additionalView: UIView?
    
    weak open var scrollViewDelegate: UIScrollViewDelegate?
    
    fileprivate var underView: B32UnderView!
    private var orientationChanged: Bool = false
    private var firstAppearance: Bool = true

    fileprivate var underviewWasCollapsed: Bool = false
    
    fileprivate var underviewHeightConstraint: NSLayoutConstraint!
    fileprivate static let underviewCollapsedHeight: CGFloat = 0.5
    fileprivate var underviewHeightConstraintConstantDefault: CGFloat = 10000
    @IBInspectable fileprivate var underlabelNumberOfLines: Int = 4
    fileprivate var underviewHeightDefault: CGFloat!
    fileprivate var scrollViewInsetDefault: CGFloat!
    
    var underviewDefaultHeight: CGFloat {
        return underviewHeightDefault!
    }
    
    var scrollViewDefaultInset: CGFloat {
        return scrollViewInsetDefault!
    }
    
    fileprivate var underLabel: UILabel? {
        return underView.underLabel
    }
    
    fileprivate var innerUnderview: UIView! {
        return underView.underview
    }
    
    public var underLabelText: String?
    
    fileprivate static let animator = B32UnderViewControllerAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = UIColor.white
        
        automaticallyAdjustsScrollViewInsets = false
        
        installGestureRecognizer()

        createUnderView()
        if let navBar = navigationController?.navigationBar {
            underView.setBarEqualentTo(navBar)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setHideShadowView(true)
        
        if firstAppearance {
            firstAppearance = false
            
            underView.underLabelText = underLabelText
            underView.layoutIfNeeded()
            
            let underViewHeight = underView.frame.height
            let standartNavigationBarHeight = getStandartNavigationBarHeight()
            
            underviewHeightDefault = underViewHeight
            scrollViewInsetDefault = standartNavigationBarHeight + underviewHeightDefault
            
            let edgeInsets = UIEdgeInsetsMake(scrollViewInsetDefault, 0, 0, 0)
            
            scrollUnderView.contentInset = edgeInsets
            scrollUnderView.scrollIndicatorInsets = edgeInsets
            
            scrollUnderView.setContentOffset(CGPoint(x: 0, y: -1.0 * scrollViewInsetDefault), animated: false)
            
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
    }
    
    func didRotated() {
        let orientation = UIDevice.current.orientation
        guard orientation == .landscapeLeft ||
            orientation == .landscapeRight ||
            orientation == .portrait ||
            orientation == .portraitUpsideDown
            else { return }
        
        orientationChanged = true
        
        underviewHeightConstraint.constant = underviewHeightConstraintConstantDefault
        
        if (isViewLoaded && view.window != nil) {
            recalcUnderViewPropertiesIfOrientationChanged()
            
        }
    }
    
    func getStandartNavigationBarHeight() -> CGFloat {
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.height
        let navBarHeight = (navigationController?.navigationBar.bounds.height ?? 0)
        
        return statusBarHeight + navBarHeight
    }
    
    func recalcUnderViewPropertiesIfOrientationChanged() {
        
        guard orientationChanged else { return }
        
        scrollUnderView.delegate = nil
        
        orientationChanged = false

        let oldUnderviewHeightDefault = underviewHeightDefault!
        let oldScrollViewInsetDefault = scrollViewInsetDefault!
        let oldScrollViewOffset = scrollUnderView.contentOffset.y
        
        view.layoutIfNeeded()
        
        let underViewHeight = underView.frame.height
        let standartNavigationBarHeight = getStandartNavigationBarHeight()
        
        underviewHeightDefault = underViewHeight
        scrollViewInsetDefault = standartNavigationBarHeight + underviewHeightDefault
        
        let edgeInsets = UIEdgeInsetsMake(scrollViewInsetDefault, 0, 0, 0)
        
        scrollUnderView.contentInset = edgeInsets
        scrollUnderView.scrollIndicatorInsets = edgeInsets
        
        let oldStandartNavigationBarHeight = oldScrollViewInsetDefault - oldUnderviewHeightDefault
        
        if (oldScrollViewInsetDefault != -1.0 * oldScrollViewOffset)
        {
            let additional = oldStandartNavigationBarHeight + oldScrollViewOffset
            scrollUnderView.contentOffset.y = (-1 * standartNavigationBarHeight + additional)
            
        } else {
            scrollUnderView.contentOffset.y = (-1 * scrollViewInsetDefault)
        }
        
        recalcUnderviewHeightConstraint()
        
        scrollUnderView.delegate = self
    }
    
    func installGestureRecognizer() {
        screenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeToBackPan))
        screenEdgePanGestureRecognizer.edges = .left

        view.addGestureRecognizer(screenEdgePanGestureRecognizer)
    }
    
    func createUnderView() {
        underView = B32UnderView(withCustomView: additionalView)
        
        view.addSubview(underView)
        
        underView.translatesAutoresizingMaskIntoConstraints = false
        underView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        underView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        underView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        underviewHeightConstraint = underView.heightAnchor.constraint(lessThanOrEqualToConstant: underviewHeightConstraintConstantDefault)
        
        underLabel?.numberOfLines = underlabelNumberOfLines
        
        underviewHeightConstraint.isActive = true
    }
    
    func rewindScrollView(animated: Bool) {
        let actualHeight = underviewHeightConstraint.constant
        guard actualHeight > B32UnderViewController.underviewCollapsedHeight && actualHeight < underviewHeightDefault  else { return }
        
        let scrollToTop = actualHeight < underviewHeightDefault/2.0
        underviewHeightConstraint.constant = scrollToTop ? B32UnderViewController.underviewCollapsedHeight : underviewHeightDefault
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                let strongSelf = self!
                
                strongSelf.view.layoutIfNeeded()
                let yoffset = strongSelf.scrollUnderView.contentOffset.y
                strongSelf.scrollUnderView.contentOffset.y = scrollToTop ? yoffset + actualHeight : yoffset - (strongSelf.underviewHeightDefault - actualHeight)
                }, completion: nil
            )
            
        } else {
            let yoffset = scrollUnderView.contentOffset.y
            scrollUnderView.contentOffset.y = scrollToTop ? yoffset + actualHeight : yoffset - (underviewHeightDefault - actualHeight)

        }
    }
    
    func handleSwipeToBackPan(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        let viewTranslation = gestureRecognizer.translation(in: view)
        let progress = viewTranslation.x / view.bounds.width
        
        switch gestureRecognizer.state {
            
        case .began:
            B32UnderViewController.transitionIsOn = true
            
            swipeToBackInteractor = UIPercentDrivenInteractiveTransition()
            
            navigationController!.popViewController(animated: true)
            
        case .changed:
            
            swipeToBackInteractor?.update(progress)

        case .cancelled, .ended:
            
            if progress > 0.5 {
                swipeToBackInteractor?.finish()
            } else {
                swipeToBackInteractor?.cancel()
            }
            
            swipeToBackInteractor = nil
            B32UnderViewController.transitionIsOn = false
            
        default:
            print("Swift switch must be exhaustive, thus the default")
        }
    }
    
}

extension B32UnderViewController : UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop {
            return B32UnderViewController.animator
        }
        
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeToBackInteractor
    }
    
}

extension B32UnderViewController : UIScrollViewDelegate {
    
    fileprivate func getUnderviewStatus() -> B32UnderviewStatus {
        let underviewHeight = underView.bounds.height
        
        if underviewHeight <= B32UnderViewController.underviewCollapsedHeight {
            return .hidden
        } else if underviewHeight >= underviewHeightDefault {
            return .shownFully
        }
        
        return .shownPartially
        
    }
    
    fileprivate func setTitleBarShown(_ shown: Bool, animated: Bool = true) {

        navigationItem.title = underView.underLabelText ?? navItemPlaceHolder
        
        if let label = navigationController?.navigationBar.getTitleLabel() {
            
            label.clipsToBounds = true
            
            let from = CGFloat(shown ? 0 : 1)
            let to = CGFloat(shown ? 1 : 0)
            
            if animated {
                label.alpha = from
                UIView.animate(withDuration: shown ? 0.5 : 0.125 , animations: {
                    label.alpha = to
                }, completion: { res in
                    label.alpha = to
                })
            } else {
                label.alpha = to
            }
        }
    }
    
    fileprivate func refreshNavigationBarTitle(animated: Bool = true) {
        
        let underviewStatus = getUnderviewStatus()
        
        if underviewStatus == .hidden && !underviewWasCollapsed {
            // was hidden now
            underviewWasCollapsed = true
            setTitleBarShown(true, animated: animated)
            
        } else if underviewStatus == .shownFully && underviewWasCollapsed {
            // was shown now
            underviewWasCollapsed = false
            setTitleBarShown(false, animated: animated)
            
        }
    }
    
    fileprivate func recalcUnderviewHeightConstraint() {
        let navStatusHeight = getStandartNavigationBarHeight()
        
        let yoffset = scrollUnderView.contentOffset.y + navStatusHeight
        
        underviewHeightConstraint.constant = (yoffset >= 0.0) ? B32UnderViewController.underviewCollapsedHeight : abs(yoffset)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
        guard !B32UnderViewController.transitionIsOn else { return } // do not work at transition
        
        recalcUnderviewHeightConstraint()
        
        refreshNavigationBarTitle()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        guard !B32UnderViewController.transitionIsOn else { return } // do not work at transition
        rewindScrollView(animated: true)
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidZoom?(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollViewDelegate?.viewForZooming?(in: scrollView)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollViewDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollViewDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return (scrollViewDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? false)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
    }

}




//-----


class B32UnderViewControllerAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    static var transitionNavUnderView: B32UnderView?
    static var anotherTransitionNavUnderView: B32UnderView?
    
    override init() {
        super.init()
        
        if B32UnderViewControllerAnimator.transitionNavUnderView == nil ||
            B32UnderViewControllerAnimator.anotherTransitionNavUnderView == nil {
            
            B32UnderViewControllerAnimator.transitionNavUnderView = B32UnderView()
            B32UnderViewControllerAnimator.anotherTransitionNavUnderView = B32UnderView()
        }
        
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let duration = self.transitionDuration(using: transitionContext)
        
        let containerView = transitionContext.containerView
        
        guard let fromVC = transitionContext.viewController(forKey: .from)  as? B32UnderViewController else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        let transitionToNoNavBar = (toVC.navigationController == nil)
        let transitionToStandardNavBar = !(toVC is B32UnderViewController)
        
        let finalFrameTo : CGRect = transitionContext.finalFrame(for: toVC)
        let offsetFrame : CGRect = finalFrameTo.offsetBy(dx: UIScreen.main.bounds.width, dy: 0)
        
        containerView.insertSubview(toView, belowSubview: fromView)
        
        fromView.frame = finalFrameTo
        toView.frame = finalFrameTo
        
        
        let fromVCHeightConstraint = fromVC.underviewHeightConstraint
        let fromVCHeightConstraintConst = fromVCHeightConstraint!.constant
        
        let fromVCUnderView = fromVC.underView!
        let fromVCUnderViewHeight = fromVCUnderView.bounds.height
        
        let fromVCUnderLabel = fromVC.innerUnderview!
        
        let fromVCScrollView = fromVC.scrollUnderView!
        let fromVCScrollViewContentOffset = fromVCScrollView.contentOffset.y
        
        let transitionNavUnderView = B32UnderViewControllerAnimator.transitionNavUnderView!
        transitionNavUnderView.frame = fromVCUnderView.frame
        transitionNavUnderView.layoutIfNeeded()
        
        let underviewCollapsedHeight = B32UnderViewController.underviewCollapsedHeight
        
        // animation to VC without NavigationController
        let animateToNoNavigationBarViewController = {
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        }
        
        // animation to VC with standart NavigationController
        let animateToStandartNavigationBarViewController = { (collapsed: Bool) -> Void in

            print("last transition to Standart \(collapsed ? "Collapsed" : ""), fromVCUnderview is small = \(fromVCUnderView.bounds.height == underviewCollapsedHeight)")
            
            toView.addSubview(transitionNavUnderView)
            if let toNavBar = toVC.navigationController?.navigationBar {
                transitionNavUnderView.setBarEqualentTo(toNavBar)
            }
            let transitionNavUnderViewHeightBefore = transitionNavUnderView.frame.size.height
            
            fromVCHeightConstraint!.constant = underviewCollapsedHeight
            
            let toNavVCScrollView: UIScrollView? = collapsed ? (toVC as! B32UnderViewController).scrollUnderView : nil
            let toNavVCScrollViewOffset: CGFloat? = collapsed ? toNavVCScrollView!.contentOffset.y : nil
            if collapsed {
                let transitionNavUnderViewHeight = transitionNavUnderView.frame.height
                toNavVCScrollView!.contentOffset.y -= (transitionNavUnderViewHeight <= underviewCollapsedHeight) ? 0.0 : transitionNavUnderViewHeight
            }
            
            transitionNavUnderView.layoutIfNeeded()
            
            UIView.animate(withDuration: duration, animations: {
                
                toView.frame = finalFrameTo
                fromView.frame = offsetFrame
                
                fromVCScrollView.contentOffset.y = fromVCScrollViewContentOffset + fromVCUnderViewHeight
                

                transitionNavUnderView.bounds.size.height = underviewCollapsedHeight
                transitionNavUnderView.center.y += (underviewCollapsedHeight - transitionNavUnderViewHeightBefore)/2.0
                transitionNavUnderView.layoutIfNeeded()
                
                fromVCUnderLabel.alpha = 0
                fromView.layoutIfNeeded()
                
                if let toNavVCScrollViewOffset = toNavVCScrollViewOffset {
                    toNavVCScrollView!.contentOffset.y = toNavVCScrollViewOffset
                }
                
            }, completion: { result in
                transitionNavUnderView.removeFromSuperview()
                
                if let navBar = toVC.navigationController?.navigationBar, !collapsed {
                    navBar.setHideShadowView(false)
                }

                fromVCUnderLabel.alpha = 1
                
                fromVCHeightConstraint!.constant = fromVCHeightConstraintConst
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        }
        
        
        // animation to VC with B32UnderViewController NavigationController
        let animateToCustomNavigationBarViewController = {

            let toNavVC = toVC as! B32UnderViewController
            
            let toNavVCUnderView = toNavVC.underView!
            let toNavVCUnderViewHeight = toNavVCUnderView.bounds.height
            let toNavVCUnderLabel = toNavVC.innerUnderview!
            
            let toNavVCScrollView = toNavVC.scrollUnderView!
            
            toNavVC.recalcUnderViewPropertiesIfOrientationChanged()
            if toNavVCUnderViewHeight <= underviewCollapsedHeight {
                animateToStandartNavigationBarViewController(true)
                return
            }

            let fromVCUnderviewDefaultHeight: CGFloat = fromVC.underviewHeightDefault
            let toNavVCUnderviewDefaultHeight: CGFloat = toNavVC.underviewHeightDefault!
            
            if (fromVCUnderviewDefaultHeight > toNavVCUnderviewDefaultHeight) {
                // 1
                print("last transition #1, fromVCUnderview is small = \(fromVCUnderView.bounds.height == underviewCollapsedHeight)")
                
                // fromView preparation
                fromVCHeightConstraint!.constant = toNavVCUnderViewHeight
                fromVC.innerUnderview.isHidden = (fromVCUnderViewHeight == underviewCollapsedHeight)
                
                let fromVCCurrentContentOffset = fromVCScrollView.contentOffset.y
                let fromVCContentOffsetDiff = toNavVCUnderViewHeight - fromVCUnderViewHeight
                
                // toView preparation
                toView.addSubview(transitionNavUnderView)
                if let toNavBar = toVC.navigationController?.navigationBar {
                    transitionNavUnderView.setBarEqualentTo(toNavBar)
                }
                
                let labelSnapshot = toNavVCUnderLabel.snapshotView(afterScreenUpdates: true)!
                labelSnapshot.frame = toNavVCUnderLabel.frame
                labelSnapshot.alpha = 0
                transitionNavUnderView.addSubview(labelSnapshot)
                transitionNavUnderView.layoutIfNeeded()
                
                let defaultXCoordinate = transitionNavUnderView.center.x
                transitionNavUnderView.center.x -= toView.bounds.width
                let transitionNavUnderViewHeightBefore = transitionNavUnderView.bounds.size.height
                
                toNavVCUnderView.isHidden = true
                
                let toVCCurrentContentOffset = toNavVCScrollView.contentOffset.y
                let toVCContentOffsetDiff = toNavVCUnderViewHeight - fromVCUnderViewHeight
                toNavVCScrollView.contentOffset.y += toVCContentOffsetDiff

                
                UIView.animate(withDuration: duration, animations: {
                    
                    toView.frame = finalFrameTo
                    fromView.frame = offsetFrame
                    
                    // fromView animation
                    fromVCScrollView.contentOffset.y -= fromVCContentOffsetDiff
                    fromView.layoutIfNeeded()

                    fromVCUnderLabel.alpha = 0
                    
                    // toView animation
                    
                    let newCenter = CGPoint(x: defaultXCoordinate, y: transitionNavUnderView.center.y + (toNavVCUnderView.bounds.height - transitionNavUnderViewHeightBefore)/2.0)
                    transitionNavUnderView.bounds.size.height = toNavVCUnderView.bounds.height
                    transitionNavUnderView.center = newCenter
                    transitionNavUnderView.layoutIfNeeded()
                    
                    toNavVCScrollView.contentOffset.y -= toVCContentOffsetDiff

                    labelSnapshot.alpha = 1
                    
                }, completion: { result in
                    // fromView restoration
                    fromVCScrollView.contentOffset.y = fromVCCurrentContentOffset
                    fromVC.innerUnderview.isHidden = false
                    fromVCHeightConstraint!.constant = fromVCHeightConstraintConst
                    fromVCUnderLabel.alpha = 1
                    
                    // toView restoration
                    toNavVCUnderView.isHidden = false
                    labelSnapshot.removeFromSuperview()
                    transitionNavUnderView.removeFromSuperview()
                    
                    toNavVCScrollView.contentOffset.y = toVCCurrentContentOffset

                    //
                    
                    
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
                
                
            } else {
                // 2
                print("last transition #2, fromVCUnderview is small = \(fromVCUnderView.bounds.height == underviewCollapsedHeight)")
                // fromView preparation
                fromView.addSubview(transitionNavUnderView)
                if let fromNavBar = fromVC.navigationController?.navigationBar {
                    transitionNavUnderView.setBarEqualentTo(fromNavBar)
                }
                
                let transitionNavUnderViewHeightBefore = transitionNavUnderView.bounds.size.height
                
                let labelSnapshot = fromVCUnderLabel.snapshotView(afterScreenUpdates: false)!
                labelSnapshot.frame = fromVCUnderLabel.frame
                transitionNavUnderView.addSubview(labelSnapshot)
                
                let fromVCCurrentContentOffset = fromVCScrollView.contentOffset.y
                let fromVCContentOffsetDiff = toNavVCUnderViewHeight - fromVCUnderViewHeight
                
                if fromVCUnderViewHeight <= underviewCollapsedHeight {
                    fromVCUnderLabel.isHidden = true
                }
                
                if fromVCUnderViewHeight <= underviewCollapsedHeight {
                    labelSnapshot.isHidden = true
                }
                
                // toView preparation
                let anotherTransitionNavUnderView = B32UnderViewControllerAnimator.anotherTransitionNavUnderView!
                anotherTransitionNavUnderView.frame = transitionNavUnderView.frame
                anotherTransitionNavUnderView.layoutIfNeeded()
                toView.addSubview(anotherTransitionNavUnderView)
                if let toNavBar = toVC.navigationController?.navigationBar {
                    anotherTransitionNavUnderView.setBarEqualentTo(toNavBar)
                }
                
                let anotherTransitionNavUnderViewHeightBefore = anotherTransitionNavUnderView.bounds.size.height
                
                let labelSnapshot2 = toNavVCUnderLabel.snapshotView(afterScreenUpdates: true)!
                labelSnapshot2.frame = toNavVCUnderLabel.frame
                labelSnapshot2.alpha = 0
                anotherTransitionNavUnderView.addSubview(labelSnapshot2)
                
                toNavVCUnderView.isHidden = true
                
                let toVCCurrentContentOffset = toNavVCScrollView.contentOffset.y
                let toVCContentOffsetDiff = toNavVCUnderViewHeight - fromVCUnderViewHeight
                toNavVCScrollView.contentOffset.y += toVCContentOffsetDiff
                
                let toVCUnderLabelCenterX = anotherTransitionNavUnderView.center.x
                anotherTransitionNavUnderView.center.x -= toView.bounds.width
                
                transitionNavUnderView.layoutIfNeeded()
                anotherTransitionNavUnderView.layoutIfNeeded()
                
                UIView.animate(withDuration: duration, animations: {
                    
                    toView.frame = finalFrameTo
                    fromView.frame = offsetFrame
                    
                    // fromView animation
                    let newCenter = CGPoint(x: transitionNavUnderView.center.x, y: transitionNavUnderView.center.y + (toNavVCUnderViewHeight - transitionNavUnderViewHeightBefore)/2.0)
                    transitionNavUnderView.bounds.size.height = toNavVCUnderViewHeight
                    transitionNavUnderView.center = newCenter
                    transitionNavUnderView.layoutIfNeeded()
                    
                    fromVCScrollView.contentOffset.y -= fromVCContentOffsetDiff
                    
                    fromVCUnderLabel.isHidden = false
                    labelSnapshot.alpha = 0
                    
                    // toView animation
                    let anotherNewCenter = CGPoint(x: toVCUnderLabelCenterX, y: anotherTransitionNavUnderView.center.y + (toNavVCUnderView.bounds.height - anotherTransitionNavUnderViewHeightBefore)/2.0)
                    anotherTransitionNavUnderView.bounds.size.height = toNavVCUnderView.bounds.height
                    anotherTransitionNavUnderView.center = anotherNewCenter
                    anotherTransitionNavUnderView.layoutIfNeeded()
                    
                    toNavVCScrollView.contentOffset.y = toVCCurrentContentOffset
                    
                    labelSnapshot2.alpha = 1
                    
                }, completion: { result in
                    // fromView restoration
                    fromVCUnderView.isHidden = false
                    
                    labelSnapshot.removeFromSuperview()
                    transitionNavUnderView.removeFromSuperview()
                    
                    fromVCScrollView.contentOffset.y = fromVCCurrentContentOffset
                    
                    // toView restoration
                    toNavVCUnderView.isHidden = false
                    toNavVCScrollView.contentOffset.y = toVCCurrentContentOffset
                    
                    labelSnapshot2.removeFromSuperview()
                    anotherTransitionNavUnderView.removeFromSuperview()
                    
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            }
            
        }
        
        
        if transitionToNoNavBar {
            animateToNoNavigationBarViewController()
        } else {
            if transitionToStandardNavBar {
                animateToStandartNavigationBarViewController(false)
            } else {
                animateToCustomNavigationBarViewController()
            }
        }
    }
    
}

// -- 

extension UINavigationBar {
    
    private func findTitleLabel(under view: UIView) -> UILabel? {
        
        if view is UILabel, let superview = view.superview, NSStringFromClass(type(of: superview)) == "UINavigationItemView" {
            return (view as! UILabel)
        }
        
        for subview in view.subviews {
            if let label = findTitleLabel(under: subview) {
                return label
            }
        }
        
        return nil
    }
    
    
    func getTitleLabel() -> UILabel? {
        return findTitleLabel(under: self)
    }
    
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        
        if view is UIImageView && view.bounds.size.height <= 3 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        
        return nil
    }
    
    func setHideShadowView(_ hide: Bool) {
        if let view = findShadowImage(under: self) {
            view.isHidden = hide
        }
    }
    
}



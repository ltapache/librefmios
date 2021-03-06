//
//  PopAnimator.m
//  Popping
//
//  Created by André Schneider on 14.05.14.
//  Copyright (c) 2014 André Schneider. All rights reserved.
//

#import "PresentingAnimator.h"
#import "UIColor+CustomColors.h"
#import "Utils.h"
#import <POP/POP.h>

@implementation PresentingAnimator

CGFloat _heightOffset;

- (instancetype)initWithHeightOffset:(CGFloat)heightOffset
{
    if (self = [super init]) {
        _heightOffset = heightOffset;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    fromView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    fromView.userInteractionEnabled = NO;

    UIView *dimmingView = [[UIView alloc] initWithFrame:fromView.bounds];
    dimmingView.backgroundColor = [UIColor customGrayColor];
    dimmingView.layer.opacity = 0.0;

    UIView *toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    
    CGFloat transitionWidth = CGRectGetWidth(transitionContext.containerView.bounds);
    CGFloat transitionHeight = CGRectGetHeight(transitionContext.containerView.bounds);
    CGFloat xOffset = 104.0;
    CGFloat yOffset = _heightOffset;
    //CGFloat transitionRatio = transitionHeight / transitionWidth;
    //if (transitionRatio < 1.7) {
    if ([Utils aspectRatio] < 1.7) {
        //yOffset *= 0.7;
        yOffset -= 88;
    }
    toView.frame = CGRectMake(0,
                              0,
                              transitionWidth - xOffset,
                              transitionHeight - yOffset);
    toView.center = CGPointMake(transitionContext.containerView.center.x, -transitionContext.containerView.center.y);

    [transitionContext.containerView addSubview:dimmingView];
    [transitionContext.containerView addSubview:toView];

    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    positionAnimation.toValue = @(transitionContext.containerView.center.y);
    positionAnimation.springBounciness = 10;
    //[positionAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [transitionContext completeTransition:YES];
    //}];

    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.springBounciness = 20;
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.2, 1.4)];

    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(0.2);

    [toView.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
    [toView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    [dimmingView.layer pop_addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}

@end

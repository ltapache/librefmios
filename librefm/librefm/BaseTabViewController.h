//
//  BaseTabViewController.h
//  librefm
//
//  Created by alopatindev on 26/07/14.
//  Copyright (c) 2014 Alexander Lopatin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTabViewController : UIViewController <UITabBarControllerDelegate,
                                                     UIViewControllerTransitioningDelegate>

@property CGFloat presentationViewHeightOffset;

- (void)switchToTab:(UIViewController *)controller;
- (void)switchToTabIndex:(NSUInteger)controllerIndex;

@end

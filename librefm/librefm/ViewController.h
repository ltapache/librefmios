//
//  ViewController.h
//  librefm
//
//  Created by sbar on 14/06/14.
//  Copyright (c) 2014 Alexander Lopatin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibrefmDelegate.h"
#import "IDZAudioPlayer.h"
#import "BaseTabViewController.h"

@interface ViewController : BaseTabViewController <LibrefmDelegate,
                                                   IDZAudioPlayerDelegate,
                                                   UIViewControllerTransitioningDelegate,
                                                   UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

- (IBAction)playButtonClicked:(id)sender;
- (IBAction)pauseButtonClicked:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;

@end

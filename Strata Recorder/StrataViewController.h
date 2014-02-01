//
//  StrataViewController.h
//  Strata Recorder
//
//  Created by Don Altman on 10/29/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentListControllerDelegate.h"
#import "SettingsControllerDelegate.h"
#import "StratumMaterialsControllerDelegate.h"

@interface StrataViewController : UIViewController <StratumMaterialsControllerDelegate, DocumentListControllerDelegate, SettingsControllerDelegate> {
}

- (void)handleStratumInfo:(id)sender;
+ (void)handleEnterBackground;
+ (void)handleEnterForeground;

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolbarTitle;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *documentsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *modeButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeControl;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIImageView *pageViewBackground;

@end

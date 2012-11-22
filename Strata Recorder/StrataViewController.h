//
//  StrataViewController.h
//  Strata Recorder
//
//  Created by Don Altman on 10/29/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentListControllerDelegate.h"

@interface StrataViewController : UIViewController <DocumentListControllerDelegate> {
	UISegmentedControl*						modeControl;
}

- (void)handleStratumInfo:(id)sender;
- (void)dismissPopoverContainer:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *graphPageToggle;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolbarTitle;

@end

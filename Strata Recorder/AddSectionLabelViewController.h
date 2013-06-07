//
//  AddSectionLabelViewController.h
//  Strata Recorder
//
//  Created by daltman on 5/28/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionLabelsTableViewController.h"

@interface AddSectionLabelViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *sectionLabelText;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property SectionLabelsTableViewController *delegate;

@end

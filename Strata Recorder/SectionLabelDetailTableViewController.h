//
//  SectionLabelDetailTableViewController.h
//  Strata Recorder
//
//  Created by daltman on 5/29/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataModel.h"
#import "SectionLabelsTableViewController.h"

@interface SectionLabelDetailTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITextField *sectionLabelText;
@property (strong, nonatomic) IBOutlet UILabel *numberStrataSpanned;
@property (strong, nonatomic) IBOutlet UIStepper *stratumSpannedStepper;

@property SectionLabel*							sectionLabel;
@property SectionLabelsTableViewController*		delegate;

@end

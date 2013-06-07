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
@property (weak, nonatomic) IBOutlet UITextField *sectionLabelText;
@property (weak, nonatomic) IBOutlet UILabel *numberStrataSpanned;
@property (weak, nonatomic) IBOutlet UIStepper *stratumSpannedStepper;

@property SectionLabel*							sectionLabel;
@property SectionLabelsTableViewController*		delegate;

@end

//
//  GrainSizeTableViewController.h
//  Strata Recorder
//
//  Created by daltman on 10/7/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataModel.h"

@interface GrainSizeTableViewController : UITableViewController

@property StrataDocument*			activeDocument;
@property int						grainSizesMask;

@property (weak, nonatomic) IBOutlet UISwitch *boulderSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cobblesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *coarseGravelSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fineGravelSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *coarseSandSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mediumSandSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fineSandSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fineSiltAndClaySwitch;

- (void)viewDidPop;
- (IBAction)handleGrainSizeRadioButton:(id)sender;

@end

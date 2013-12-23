//
//  SectionLabelsTableViewController.h
//  Strata Recorder
//
//  Created by daltman on 5/28/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataModel.h"

@interface SectionLabelsTableViewController : UITableViewController

@property StrataDocument*			activeDocument;
@property NSMutableArray*			sectionLabels;

- (IBAction)handleAddSectionLabel:(id)sender;
- (IBAction)handleUpdateButton:(id)sender;

@end

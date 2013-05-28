//
//  StratumInfoTableViewController.h
//  Strata Recorder
//
//  Created by daltman on 5/9/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataModel.h"
#import "StratumInfoTableViewController.h"

@interface StratumMaterialsPaletteTableViewController : UITableViewController <UINavigationControllerDelegate>

@property StrataDocument *activeDocument;
@property int materialNumber;
@property UIViewController *delegate;
@property StratumInfoTableViewController *stratumInfoTableViewController;

@end

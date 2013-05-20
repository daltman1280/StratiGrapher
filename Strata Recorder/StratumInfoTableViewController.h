//
//  StratumInfoTableViewController.h
//  Strata Recorder
//
//  Created by daltman on 5/9/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataModel.h"

@interface StratumInfoTableViewController : UITableViewController <UINavigationControllerDelegate>

@property StrataDocument *activeDocument;
@property Stratum *stratum;
@property UIViewController *delegate;

@end

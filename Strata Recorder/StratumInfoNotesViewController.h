//
//  StratumInfoNotesViewController.h
//  Strata Recorder
//
//  Created by daltman on 12/15/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StratumInfoTableViewController.h"
#import "StrataModel.h"

@interface StratumInfoNotesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView*			notesTextView;
@property NSString*											notes;
@property StratumInfoTableViewController*					stratumInfoTableViewController;
@property Stratum*											stratum;
@end

//
//  StratumGranularityViewController.h
//  Strata Recorder
//
//  Created by daltman on 12/16/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataModel.h"
#import "StratumInfoTableViewController.h"

@interface StratumGranularityViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *granularityPicker;

@property StrataDocument*					currentDocument;
@property Stratum*							stratum;
@property StratumInfoTableViewController*	parent;

@end

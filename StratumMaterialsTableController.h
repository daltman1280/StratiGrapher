//
//  StratumMaterialsTableController.h
//  Strata Recorder
//
//  Created by Don Altman on 11/15/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataModel.h"

@interface StratumMaterialsTableController : UITableViewController

@property Stratum *stratum;
@property UIViewController *delegate;
@property StrataDocument *activeDocument;
@property NSMutableArray* materialIndexes;										// cached, sorted, material numbers from StrataDocument materialNumbersPalette

@end

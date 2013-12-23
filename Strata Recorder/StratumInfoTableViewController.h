//
//  StratumInfoTableViewController.h
//  Strata Recorder
//
//  Created by daltman on 5/23/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaterialPatternView.h"
#import "StrataModel.h"
#import "StratumInfoNavigationController.h"

@interface StratumInfoTableViewController : UITableViewController

@property Stratum*							stratum;
@property StrataDocument*					activeDocument;
@property UIViewController*					delegate;
@property StratumInfoNavigationController*	stratumInfoNavigationController;
@property int								materialNumber;
@property grainSizeEnum						grainSizeIndex;

- (void)handleMaterialSelectionChanged:(int)materialNumber;
- (void)handleGranularityChanged:(grainSizeEnum)grainSizeIndex;

@end

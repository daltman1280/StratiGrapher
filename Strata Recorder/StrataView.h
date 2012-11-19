//
//  StrataView.h
//  Strata Recorder
//
//  Created by Don Altman on 10/29/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataViewController.h"
#import "StrataModel.h"

//	globals for use with callback function

CGPDFPageRef gPage;
int gPatternNumber;
CGFloat gScale;

void patternDrawingCallback(void *info, CGContextRef context);

@interface StrataView : UIView

@property CGFloat scale;
@property UILabel* locationLabel;
@property UILabel* dimensionLabel;
@property CGPDFPageRef patternsPage;
@property StrataViewController* delegate;
@property Stratum*	selectedStratum;
@property CGPoint infoSelectionPoint;							// for stratum info popover
@property StrataDocument* activeDocument;				// current StrataDocument being edited/displayed

@end

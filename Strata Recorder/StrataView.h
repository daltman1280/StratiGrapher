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

NSMutableArray *gPageArray;										// array of NSValue containing CGPDFPageRef's, one per page
CGFloat gScale;

void patternDrawingCallback(void *info, CGContextRef context);

@interface StrataView : UIView

- (void)initialize;
- (void)handleStrataHeightChanged:(id)sender;

@property CGFloat scale;
@property UILabel* locationLabel;
@property UILabel* dimensionLabel;
@property NSMutableArray* patternsPageArray;					// of NSValue of CGPDFPageRef
@property StrataViewController* delegate;
@property Stratum*	selectedStratum;
@property PaleoCurrent* selectedPaleoCurrent;
@property CGPoint infoSelectionPoint;							// for stratum info popover
@property (nonatomic) StrataDocument* activeDocument;			// current StrataDocument being edited/displayed

// for graphics.h

@property CGPoint origin;

@end

//
//  FreehandStrataView.h
//  Strata Recorder
//
//  Created by daltman on 12/31/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataViewController.h"
#import "StrataModel.h"

@interface FreehandStrataView : UIView

@property CGFloat scale;
@property (nonatomic) StrataDocument* activeDocument;			// current StrataDocument being edited/displayed
@property StrataViewController* delegate;

// for graphics.h

@property CGPoint origin;

@end

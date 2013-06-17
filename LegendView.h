//
//  LegendView.h
//  Strata Recorder
//
//  Created by daltman on 6/16/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaterialPatternView.h"
#import "StrataModel.h"

@interface LegendView : UIView

@property UIView*						legendLineContainer;
@property UILabel*						legendLineLabel;
@property MaterialPatternView*			legendLineMaterial;

@property StrataDocument*				activeDocument;

- (void)populateLegend;

@end

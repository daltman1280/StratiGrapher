//
//  StrataPageView.h
//  Strata Recorder
//
//  Created by Don Altman on 11/16/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataModel.h"
#import "IconImage.h"

typedef enum {
	graphMode,
	PDFMode
} drawMode;

@interface StrataPageView : UIView

@property IconImage*							arrowIcon;
@property (nonatomic) StrataDocument*			activeDocument;
@property NSMutableArray*						patternsPageArray;
@property drawMode								mode;

// for graphics.h
@property CGPoint								origin;

@property (nonatomic) StrataPageView*			strataPageView;
@property (weak, nonatomic) UILabel*			columnNumber;
@property (weak, nonatomic) UILabel*			grainSizeLegend;
@property (weak, nonatomic) UIView*				strataColumn;
@property (weak, nonatomic) UILabel*			grainSizeLines;

@end

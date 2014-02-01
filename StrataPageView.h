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
#import "LegendView.h"

typedef enum {
	graphMode,
	PDFMode
} drawMode;

@interface StrataPageView : UIView

// initialized externally

@property IconImage*							arrowIcon;
@property (nonatomic) StrataDocument*			activeDocument;
@property NSMutableArray*						patternsPageArray;
@property drawMode								mode;

// for graphics.h

@property CGPoint								origin;

//	view content to help drawing column adornments

@property (strong, nonatomic) UILabel*			columnNumber;
@property (strong, nonatomic) UILabel*			grainSizeLegend;
@property (strong, nonatomic) UIView*				strataColumn;
@property (strong, nonatomic) UILabel*			grainSizeLines;

//	for legend

@property (strong, nonatomic) LegendView*			legendView;

@property int									pageIndex;					// index of page to be drawn
@property int									maxPageIndex;				// number of pages-1 (including legend): initialized by setupPages

- (void)setupPages;
- (void)exportPDF;

@end

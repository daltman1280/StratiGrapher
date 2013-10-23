//
//  StrataView.h
//  Strata Recorder
//
//  Created by Don Altman on 10/29/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "StrataViewController.h"
#import "StrataModel.h"

static const float kPencilMargin = 0.1;

//	grain size constants

static const int gGrainSizeOffsetInTickmarks = 4;				// x offset (in graph tickmarks), from origin to first grainsize location (fine silt and clay)
static const NSString *gGrainSizeNames[] = { @"Fine Silt & Clay", @"Fine Sand", @"Medium Sand", @"Coarse Sand", @"Fine Gravel", @"Coarse Gravel", @"Cobbles", @"Boulders" };
static const NSString *gAbbreviatedGrainSizeNames[] = { @"Silt", @"F. Sand", @"M. Sand", @"C. Sand", @"F. Grav.", @"C. Grav.", @"Cobb.", @"Bould." };
static const int gGrainSizeNamesCount = 8;

//	globals for use with callback function

NSMutableArray *gPageArray;										// array of NSValue containing CGPDFPageRef's, one per page
CGFloat gScale;
BOOL gTransparent;

void patternDrawingCallback(void *info, CGContextRef context);

@interface TraceLayer : CALayer
@end

@interface TraceLayerContainer : CALayer
@property TraceLayer*		trace;
@property BOOL				traceVisible;
@property NSMutableArray*	tracePoints;
@end

@interface OverlayLayer : CALayer
@end

@class StrataView;

@interface OverlayLayerContainer : CALayer

@property OverlayLayer*		overlay;
@property BOOL				overlayVisible;
@property StrataView*		strataView;
@property NSMutableArray*	tracePoints;

// cloned from StrataView parent, to allow drawPencilHighlighting to work
@property Stratum* selectedPencilStratum;
@property CGPoint origin;
@property (nonatomic) StrataDocument* activeDocument;			// current StrataDocument being edited/displayed

@end

@interface StrataView : UIView

- (void)initialize;
- (void)handleStrataHeightChanged:(id)sender;
- (void)handlePencilTap:(Stratum *)stratum;
- (void)handlePaleoTap:(PaleoCurrent *)paleo inStratum:(Stratum *)stratum;
- (void)drawStratumOutline:(Stratum *)stratum;
+ (NSMutableArray *)populateControlPoints:(Stratum *)stratum;
- (void)populateMoveIconLocations;


@property CGFloat scale;
@property UILabel* locationLabel;
@property UILabel* dimensionLabel;
@property NSMutableArray* patternsPageArray;					// of NSValue of CGPDFPageRef
@property StrataViewController* delegate;
@property Stratum*	selectedStratum;
@property PaleoCurrent* selectedPaleoCurrent;
@property CGPoint infoSelectionPoint;							// for stratum info popover
@property (nonatomic) StrataDocument* activeDocument;			// current StrataDocument being edited/displayed
@property BOOL touchesEnabled;
@property OverlayLayerContainer *overlayContainer;				// to display pencil mode highlighting in overlay sublayer
@property TraceLayerContainer *traceContainer;

// for graphics.h

@property CGPoint origin;

@end

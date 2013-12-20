//
//  StrataView.m
//  Strata Recorder
//
//  Created by Don Altman on 10/29/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#define XORIGIN .75												// distance in inches of origin from LL of view
#define YORIGIN .5												// distance in inches of origin from LL of view

#import "StrataView.h"
#import "IconImage.h"
#import "Graphics.h"
#import "StrataViewController.h"
#import "StrataNotifications.h"

/*
 A static callback function for drawing stratigraphic patterns. Uses a matrix of pattern swatches contained in a manually prepared
 PDF, which contains rows of 5 elements each, one row per PDF page, arranged sequentially according to pattern number. Each item is a rectangle of 55
 pixels, which contains a 54 x 54 pixel pattern representation, derived from the "official" patterns. Presumably, the representations
 are in PostScript, so are resolution-independent.
 
 The callback makes use of static variables, because it has no access to StrataView.
 */
void patternDrawingCallback(void *info, CGContextRef context)
{
	if ((int) info < 0 || ((int) info == 0 && gTransparent)) return;
	int patternIndex = (info) ? (int) info-601 : 3;												// treat pattern 0 as 604 (which is blank)
	int columnIndex = patternIndex % 5;
	CGContextTranslateCTM(context, -(55*columnIndex)+.1, +.3);									// so the ith element in the row will be at the origin
	if (!gTransparent) {
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
		CGContextFillRect(context, CGContextGetClipBoundingBox(context));
	}
	CGContextDrawPDFPage(context, [((NSValue *)gPageArray[patternIndex/5]) pointerValue]);		// draw the requested pattern rectangle from the PDF materials patterns page
}

/*
 TraceLayerContainer class: CALayer subclass, to host TraceLayer
 
 TraceLayer class: custom CALayer
 
 Purpose: to display the path representing the touch events during the sequence of events. We can't keep up with the touch events if we have to call drawStratumOutline for each
 touch event. We simply display the path of touch events, until touchesEnded.
 */

@implementation TraceLayer
@end

@implementation TraceLayerContainer

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	UIGraphicsPushContext(ctx);
	UIBezierPath *path = [UIBezierPath bezierPath];
	for (NSDictionary *dict in self.tracePoints) {
		CGPoint point;
		CGPointMakeWithDictionaryRepresentation(CFBridgingRetain(dict), &point);
		if ([self.tracePoints indexOfObject:dict] == 0)
			[path moveToPoint:point];
		else
			[path addLineToPoint:point];
		CFRelease((__bridge CFTypeRef)(dict));
	}
	[path setLineWidth:3];
	[path stroke];
	UIGraphicsPopContext();
}

- (void)addPoint:(CGPoint)point
{
	if (!self.tracePoints) self.tracePoints = [[NSMutableArray alloc] init];
	[self.tracePoints addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(point))];
}

@end

/*
 ContainerLayer class: CALayer subclass, to host OverlayLayer
 
 OverlayLayer class: custom CALayer
 
 Purpose: to display pencil mode highlighting without requiring a StrataView redraw
 */

@implementation OverlayLayer
@end

@implementation OverlayLayerContainer

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	UIGraphicsPushContext(ctx);
	if (self.overlayVisible) {
		gTransparent = YES;
		[self drawPencilHighlighting];
		[self.strataView drawStratumOutline:self.selectedPencilStratum inContext:ctx];
	}
	UIGraphicsPopContext();
}

- (void)drawPencilHighlighting
{
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGFloat colorComponents[4] = {0, 0, 0, 0.3};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef color = CGColorCreate(colorSpace, colorComponents);
	CGContextSetFillColorWithColor(currentContext, color);
	CFRelease(color);
	CFRelease(colorSpace);
	/*
	 Draw a grey transparent background everywhere except for the margins of stratum boundary, where
	 the user is allowed to draw/edit the boundary in freehand.
	 */
	Stratum *stratum = self.selectedPencilStratum;
	// center: TODO: bypass if stratum is too shallow
	CGRect myRect = CGRectMake(VX(stratum.frame.origin.x-kPencilMargin), VY(stratum.frame.origin.y+kPencilMargin), VDX(stratum.frame.size.width), VDY(stratum.frame.size.height-2*kPencilMargin));
	CGContextFillRect(currentContext, myRect);
	// left
	myRect = CGRectMake(VX(-XORIGIN), VY(-YORIGIN), VDX(XORIGIN-kPencilMargin), VDY(self.activeDocument.strataHeight));
	CGContextFillRect(currentContext, myRect);
	// top/right
	myRect = CGRectMake(VX(stratum.frame.origin.x-kPencilMargin), VY(stratum.frame.origin.y+stratum.frame.size.height+kPencilMargin), self.bounds.size.width, VDY(self.activeDocument.strataHeight));
	CGContextFillRect(currentContext, myRect);
	// right
	myRect = CGRectMake(VX(stratum.frame.origin.x+stratum.frame.size.width+kPencilMargin), VY(stratum.frame.origin.y-kPencilMargin), self.bounds.size.width, VDY(stratum.frame.size.height+2*kPencilMargin));
	CGContextFillRect(currentContext, myRect);
	// bottom/right
	myRect = CGRectMake(VX(stratum.frame.origin.x-kPencilMargin), VY(stratum.frame.origin.y-kPencilMargin), self.bounds.size.width, -VDY(self.activeDocument.strataHeight));
	CGContextFillRect(currentContext, myRect);
}

- (void)addPoint:(CGPoint)point
{
	if (!self.tracePoints) self.tracePoints = [[NSMutableArray alloc] init];
	[self.tracePoints addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(point))];
}

@end

@interface StrataView() <UIGestureRecognizerDelegate>
@property IconImage* moveIcon;							// icon used to display drag sensitive locations for moving the upper-right corner of strata rectangles
@property IconImage* moveIconSelected;
@property IconImage* infoIcon;							// display touch sensitive location for info popovers
@property IconImage* scissorsIcon;
@property IconImage* anchorIcon;
@property IconImage* arrowIcon;
@property IconImage* arrowIconSelected;
@property IconImage* pencilIcon;
@property NSMutableArray* iconLocations;				// CGPoint dictionaries, in user coordinates, for moveIcon's
@property CGSize dragOffsetFromCenter;					// the offset of the drag coordinate from center of dragged object, to track movement of icon's center coordinates
@property CGPoint dragConstraint;						// lower left limit of dragging allowed, don't allow negative height/width
@property BOOL dragActive;								// tracks dragging state
@property int activeDragIndex;							// index in strata of dragged item
@property BOOL pencilActive;
@property BOOL pencilTouchBeganInEditRegion;
@property Stratum* selectedScissorsStratum;
@property Stratum* selectedAnchorStratum;
@property CGPoint iconOrigin;							// for dragging anchor or scissors icon
@end

@implementation StrataView

+ (Class)layerClass
{
	return [CATiledLayer class];
}

/*
 Algorithm from http://scaledinnovation.com/analytics/splines/aboutSplines.html
 */

+ (NSMutableArray *)populateControlPoints:(Stratum *)stratum
{
	NSMutableArray *controlPoints = [[NSMutableArray alloc] init];
	float t = .5;															// smoothness coefficient, arbitrary value
	// create a pair of control points shared between each pair of adjoining vertices
	for (int index = 0; index < stratum.outline.count-2; ++index) {
		CGPoint point;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[index]), &point);
		float x0 = point.x;
		float y0 = point.y;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[index+1]), &point);
		float x1 = point.x;
		float y1 = point.y;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[index+2]), &point);
		float x2 = point.x;
		float y2 = point.y;
		float d01 = sqrtf((x1-x0)*(x1-x0)+(y1-y0)*(y1-y0));
		float d12 = sqrtf((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));
		float fa = t*d01/(d01+d12);
		float fb = t*d12/(d01+d12);
		float p1x = x1-fa*(x2-x0);
		float p1y = y1-fa*(y2-y0);
		float p2x = x1+fb*(x2-x0);
		float p2y = y1+fb*(y2-y0);
		[controlPoints addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(CGPointMake(p1x, p1y)))];
		[controlPoints addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(CGPointMake(p2x, p2y)))];
	}
	return controlPoints;
}

- (void)drawStratumOutline:(Stratum *)stratum inContext:(CGContextRef)currentContext
{
	if (stratum.outline.count == 0) return;
	NSMutableArray *controlPoints = [StrataView populateControlPoints:stratum];
	CGContextSaveGState(currentContext);
	CGContextSetLineWidth(currentContext, 3);
	// draw left boundary, before setting clipping path
	CGContextMoveToPoint(currentContext, VX(stratum.frame.origin.x), VY(stratum.frame.origin.y));
	CGContextAddLineToPoint(currentContext, VX(stratum.frame.origin.x), VY(stratum.frame.origin.y+stratum.frame.size.height));
	CGContextStrokePath(currentContext);
	// set clipping rectangle
	CGContextBeginPath(currentContext);
	// it's larger than the stratum boundary
	CGContextAddRect(currentContext, CGRectMake(VX(stratum.frame.origin.x), VY(stratum.frame.origin.y-kPencilMargin), VDX(stratum.frame.size.width+kPencilMargin), VDY(stratum.frame.size.height+2*kPencilMargin)));
	CGContextClip(currentContext);
	// construct bezier path
	CGMutablePathRef mPath = CGPathCreateMutable();
	CGPoint point;
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[0]), &point);
	CGPathMoveToPoint(mPath, NULL, VX(point.x+stratum.frame.origin.x), VY(point.y+stratum.frame.origin.y));
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[1]), &point);
	CGPoint cPoint;
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[0]), &cPoint);
	// first and last curves have only a single control point
	CGPathAddQuadCurveToPoint(mPath, NULL, VX(cPoint.x+stratum.frame.origin.x), VY(cPoint.y+stratum.frame.origin.y), VX(point.x+stratum.frame.origin.x), VY(point.y+stratum.frame.origin.y));
	int cpIndex = 1;
	for (int index = 2; index < stratum.outline.count-3; ++index) {
		CGPoint cPoint1, cPoint2;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[index]), &point);
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[cpIndex++]), &cPoint1);
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[cpIndex++]), &cPoint2);
		// grab the next pair of control points and use them for the next curve
		CGPathAddCurveToPoint(mPath, NULL, VX(cPoint1.x+stratum.frame.origin.x), VY(cPoint1.y+stratum.frame.origin.y), VX(cPoint2.x+stratum.frame.origin.x), VY(cPoint2.y+stratum.frame.origin.y), VX(point.x+stratum.frame.origin.x), VY(point.y+stratum.frame.origin.y));
	}
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[cpIndex]), &cPoint);
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([stratum.outline lastObject]), &point);
	// last curve again has a single control point
	CGPathAddQuadCurveToPoint(mPath, NULL, VX(cPoint.x+stratum.frame.origin.x), VY(cPoint.y+stratum.frame.origin.y), VX(point.x+stratum.frame.origin.x), VY(point.y+stratum.frame.origin.y));
	CGPathCloseSubpath(mPath);
	CGContextAddPath(currentContext, mPath);
	CGPathRelease(mPath);
	// apparently, we need to do this in the current context, can't cache it
	CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
	CGContextSetFillColorSpace(currentContext, patternSpace);
	CGColorSpaceRelease(patternSpace);
	struct CGPatternCallbacks patternCallbacks = {
		0, &patternDrawingCallback, 0
	};
	CGPatternRef pattern = CGPatternCreate((void *)stratum.materialNumber, CGRectMake(0, 0, 54, 54), CGAffineTransformMakeScale(self.activeDocument.patternScale, -self.activeDocument.patternScale), 54, 54, kCGPatternTilingConstantSpacing, YES, &patternCallbacks);
	CGFloat alpha = 1;
	CGContextSetFillPattern(currentContext, pattern, &alpha);
	CGPatternRelease(pattern);
	gScale = self.scale;
	CGContextDrawPath(currentContext, kCGPathFillStroke);								// does fill and stroke
	// draw points in red for debugging purposes
	CGContextSetStrokeColorWithColor(currentContext, [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0].CGColor);
	if (self.pencilActive) {
		for (NSDictionary *dict in stratum.outline) {
			CGPoint point;
			CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(dict), &point);
			CGContextStrokeRect(currentContext, CGRectMake(VX(point.x+stratum.frame.origin.x), VY(point.y+stratum.frame.origin.y), 1, 1));
		}
	}
	CGContextRestoreGState(currentContext);
}

- (BOOL)inPencilEditRegion:(CGPoint)point
{
	CGRect frame = self.selectedStratum.frame;
	return ((point.x >= frame.origin.x &&												// top
			 point.x <= frame.origin.x + frame.size.width + kPencilMargin &&
			 point.y >= frame.origin.y + frame.size.height - kPencilMargin &&
			 point.y <= frame.origin.y + frame.size.height + kPencilMargin) ||
			(point.x >= frame.origin.x + frame.size.width - kPencilMargin &&			// right
			 point.x <= frame.origin.x + frame.size.width + kPencilMargin &&
			 point.y >= frame.origin.y - kPencilMargin &&
			 point.y <= frame.origin.y + frame.size.height + kPencilMargin) ||
			(point.x >= frame.origin.x &&												// bottom
			 point.x <= frame.origin.x + frame.size.width + kPencilMargin &&
			 point.y >= frame.origin.y - kPencilMargin &&
			 point.y <= frame.origin.y + kPencilMargin));
}

- (void)updateOutlineFromTrace
{
	Stratum *stratum = self.selectedStratum;
	if (stratum.outline && stratum.outline.count > 0 && self.overlayContainer.tracePoints.count > 1) {				// edit existing stratum outline
		BOOL traceReversed = NO;																					// trace is in opposite polarity from outline
		CGPoint p1, p2;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(self.overlayContainer.tracePoints[0]), &p1);
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([self.overlayContainer.tracePoints lastObject]), &p2);
		p1.x -= stratum.frame.origin.x;
		p1.y -= stratum.frame.origin.y;
		p2.x -= stratum.frame.origin.x;
		p2.y -= stratum.frame.origin.y;
		float d1Min = HUGE_VALF, d2Min = HUGE_VALF;
		int d1MinIndex = -1, d2MinIndex = -1;																		// -1 indicates it's uninitialized
		for (int index = 0; index < stratum.outline.count; ++index) {
			CGPoint pOutline;
			CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[index]), &pOutline);
			float d1 = distance(pOutline, p1);
			if (d1 < d1Min) {
				d1Min = d1;
				d1MinIndex = index;
			}
			float d2 = distance(pOutline, p2);
			if (d2 < d2Min) {
				d2Min = d2;
				d2MinIndex = index;
			}
		}
		if (d1MinIndex > d2MinIndex) {																				// d1MinIndex must always preceed d2MinIndex
			traceReversed = YES;
			int temp = d1MinIndex;
			d1MinIndex = d2MinIndex;
			d2MinIndex = temp;
		}
		NSMutableArray *newOutline = [[NSMutableArray alloc] init];
		for (int index = 0; index < d1MinIndex; ++index)															// initial segment of original outline
			[newOutline addObject:stratum.outline[index]];
		// replace points in outline between d1MinIndex and d2MinIndex with filtered trace points (minus endpoints)
		if (!traceReversed) {																						// add points from trace in original order
			for (int index = 1; index < self.overlayContainer.tracePoints.count-1; index += 5) {
				CGPoint p1;
				CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(self.overlayContainer.tracePoints[index]), &p1);
				p1.x -= stratum.frame.origin.x;
				p1.y -= stratum.frame.origin.y;
#ifdef MUTABLE
				[newOutline addObject:[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)CFBridgingRelease(CGPointCreateDictionaryRepresentation(p1))]];
#else
				[newOutline addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(p1))];
#endif
			}
		} else {																									// add points from trace in reversed order
			for (int index = self.overlayContainer.tracePoints.count-2; index > 0; index -= 5) {
				CGPoint p1;
				CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(self.overlayContainer.tracePoints[index]), &p1);
				p1.x -= stratum.frame.origin.x;
				p1.y -= stratum.frame.origin.y;
#ifdef MUTABLE
				[newOutline addObject:[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)CFBridgingRelease(CGPointCreateDictionaryRepresentation(p1))]];
#else
				[newOutline addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(p1))];
#endif
			}
		}
		if (d2MinIndex < stratum.outline.count-1) {																	// don't copy singular endpoint of original
			for (int index = d2MinIndex; index < stratum.outline.count; ++index)									// remaining segment of original outline
				[newOutline addObject:stratum.outline[index]];
		}
		stratum.outline = newOutline;																				// replace outline
	} else if (stratum.outline && stratum.outline.count > 0 && self.overlayContainer.tracePoints.count == 1) {		// delete existing outline
		[stratum.outline removeAllObjects];
	} else {																										// no existing outline, make a new one
		// TODO: this is very crude, it should recognize significant points, take curvature into account
		if (!stratum.outline) stratum.outline = [[NSMutableArray alloc] init];
		CGPoint point;
		for (int index = 0; index < self.overlayContainer.tracePoints.count; index += 5) {
			// make its user coordinates relative to stratum frame origin
			CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(self.overlayContainer.tracePoints[index]), &point);
			point.x -= stratum.frame.origin.x;
			point.y -= stratum.frame.origin.y;
#ifdef MUTABLE
			[stratum.outline addObject:[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)CFBridgingRelease(CGPointCreateDictionaryRepresentation(point))]];
#else
			[stratum.outline addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(point))];
#endif
		}
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([self.overlayContainer.tracePoints lastObject]), &point);
		point.x -= stratum.frame.origin.x;
		point.y -= stratum.frame.origin.y;
#ifdef MUTABLE
		[stratum.outline addObject:[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)CFBridgingRelease(CGPointCreateDictionaryRepresentation(point))]];
#else
		[stratum.outline addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(point))];
#endif
	}
}

/*
 Handle touch events in pencil mode. Called from touch events handlers when we're in pencil editing mode.
 */

- (void)pencilTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint dragPoint = [self getDragPoint:event];
	self.pencilTouchBeganInEditRegion = [self inPencilEditRegion:dragPoint];
	if (!self.pencilTouchBeganInEditRegion) return;
	[[NSNotificationCenter defaultCenter] postNotificationName:SREditingOperationStarted object:self];	// disable scrolling
	CGPoint viewPoint = CGPointMake(VX(dragPoint.x), VY(dragPoint.y));
	[self.traceContainer.tracePoints removeAllObjects];
	[self.traceContainer addPoint:viewPoint];
	[self.overlayContainer.tracePoints removeAllObjects];
	[self.overlayContainer addPoint:dragPoint];
}

- (void)pencilTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	if (!self.pencilTouchBeganInEditRegion) return;
	CGPoint dragPoint = [self getDragPoint:event];
	CGPoint viewPoint = CGPointMake(VX(dragPoint.x), VY(dragPoint.y));
	[self.traceContainer addPoint:viewPoint];
	[self.traceContainer.trace setNeedsDisplay];
	[self.overlayContainer addPoint:dragPoint];
	//	[self.overlayContainer.overlay setNeedsDisplay];
}

- (void)pencilTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	if (!self.pencilTouchBeganInEditRegion) return;
	[self.traceContainer.tracePoints removeAllObjects];
	[self.traceContainer.trace setNeedsDisplay];
	[self updateOutlineFromTrace];
	[[NSNotificationCenter defaultCenter] postNotificationName:SREditingOperationEnded object:self];	// re-enable scrolling
	[self.overlayContainer.overlay setNeedsDisplay];
}

- (void)populateMoveIconLocations
{
	self.iconLocations = [[NSMutableArray alloc] init];
    for (Stratum *stratum in self.activeDocument.strata) {
        CGRect myRect = stratum.frame;
        CGPoint iconLocation = CGPointMake(myRect.origin.x+myRect.size.width, myRect.origin.y+myRect.size.height);
#ifdef MUTABLE
		NSMutableDictionary *dict = ([NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(CGPointCreateDictionaryRepresentation(iconLocation))]);
        [self.iconLocations addObject:(dict)];
#else
		CFDictionaryRef dict = CGPointCreateDictionaryRepresentation(iconLocation);
        [self.iconLocations addObject:(__bridge id)(dict)];
		CFRelease(dict);
#endif
    }
}

- (void)handleStrataHeightChanged:(id)sender
{
	// these properties must be updated, because the graphics transform functions depend on them
	self.moveIcon.bounds = self.bounds;
	self.moveIconSelected.bounds = self.bounds;
	self.infoIcon.bounds = self.bounds;
	self.scissorsIcon.bounds = self.bounds;
	self.anchorIcon.bounds = self.bounds;
	self.arrowIcon.bounds = self.bounds;
	self.pencilIcon.bounds = self.bounds;

	self.overlayContainer.frame = self.bounds;
	self.overlayContainer.overlay.frame = self.bounds;
	self.traceContainer.frame = self.bounds;
	self.traceContainer.trace.frame = self.bounds;
}

- (void)setActiveDocument:(StrataDocument *)activeDocument
{
	_activeDocument = activeDocument;
	[self handleStrataHeightChanged:self];
	[self populateMoveIconLocations];														// we're overriding the setter, because this is a good time to do this
}

/*
 initWithCoder and initWithFrame are not reliably called, so we call this from the view controller in its UIApplicationDidBecomeActiveNotification
 This is to be called once.
 */

- (void)initialize
{
	CATiledLayer *tiledLayer = (CATiledLayer *)self.layer;
	tiledLayer.levelsOfDetail = 5;
	tiledLayer.levelsOfDetailBias = 2;
	tiledLayer.tileSize = CGSizeMake(512, 512);
	self.opaque = YES;
	self.origin = CGPointMake(XORIGIN, YORIGIN);
	self.touchesEnabled = YES;
	self.moveIcon = [[IconImage alloc] initWithImageName:@"move icon.png" offset:CGPointMake(9./50., 9./50.) width:50 viewBounds:self.bounds viewOrigin:self.origin];
	float width = 50.*921./555.;														// ratio of image size, relative to move icon, because of "flare" imagery
	self.moveIconSelected = [[IconImage alloc] initWithImageName:@"move icon selected.png" offset:CGPointMake(25./width, 25./width) width:width viewBounds:self.bounds viewOrigin:self.origin];
	self.infoIcon = [[IconImage alloc] initWithImageName:@"info icon.png" offset:CGPointMake(.5, .5) width:25 viewBounds:self.bounds viewOrigin:self.origin];
	self.scissorsIcon = [[IconImage alloc] initWithImageName:@"cut.png" offset:CGPointMake(.5, .5) width:25 viewBounds:self.bounds viewOrigin:self.origin];
	self.anchorIcon = [[IconImage alloc] initWithImageName:@"anchor.png" offset:CGPointMake(.5, .5) width:25 viewBounds:self.bounds viewOrigin:self.origin];
	self.arrowIcon = [[IconImage alloc] initWithImageName:@"paleocurrent.png" offset:CGPointMake(.5, .5) width:25 viewBounds:self.bounds viewOrigin:self.origin];
	self.pencilIcon = [[IconImage alloc] initWithImageName:@"post-it-pencil.png" offset:CGPointMake(.5, .5) width:50 viewBounds:self.bounds viewOrigin:self.origin];
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	[self addGestureRecognizer:longPress];
	longPress.cancelsTouchesInView = NO;
	// instantiate sublayer and its sublayer for pencil mode highlighting overlay
	self.overlayContainer = [[OverlayLayerContainer alloc] init];
	self.overlayContainer.frame = self.bounds;
	[self.layer addSublayer:self.overlayContainer];
	self.overlayContainer.overlay = [[OverlayLayer alloc] init];
	self.overlayContainer.overlay.frame = self.bounds;
	[self.overlayContainer addSublayer:self.overlayContainer.overlay];
	self.overlayContainer.overlay.delegate = self.overlayContainer;
	// instantiate sublayer and its sublayer for pencil trace overlay
	self.traceContainer = [[TraceLayerContainer alloc] init];
	self.traceContainer.frame = self.bounds;
	[self.layer addSublayer:self.traceContainer];
	self.traceContainer.trace = [[TraceLayer alloc] init];
	self.traceContainer.trace.frame = self.bounds;
	[self.traceContainer addSublayer:self.traceContainer.trace];
	self.traceContainer.trace.delegate = self.traceContainer;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleActiveDocumentSelectionChanged:) name:SRActiveDocumentSelectionChanged object:nil];
}

- (void)handleActiveDocumentSelectionChanged:(NSNotification *)notification
{
	self.activeDocument = [notification.userInfo objectForKey:@"activeDocument"];
}

//	return in user coordinates

- (CGPoint)getDragPoint:(UIEvent *)event
{
	CGPoint dragPoint = CGPointMake(UX([(UITouch *)[[event touchesForView:self] anyObject] locationInView:self].x),
									UY([(UITouch *)[[event touchesForView:self] anyObject] locationInView:self].y));
	return dragPoint;
}

- (void)updateCoordinateText:(CGPoint)iconLocation touchLocation:(CGPoint)touchLocation stratum:(Stratum *)stratum
{
	float snapLocation = iconLocation.x;
	int snapIndex = [StrataDocument snapToGrainSizePoint:&snapLocation];
	Stratum *anchorStratum = nil;
	for (Stratum *stratumIter in self.activeDocument.strata) {
		if (stratumIter.hasAnchor) anchorStratum = stratumIter;
		if (stratumIter == stratum) break;
	}
	float y = (anchorStratum) ? iconLocation.y - anchorStratum.frame.origin.y : iconLocation.y;
	[self.locationLabel setText:[NSString stringWithFormat:@"⌖%4.2f, %@", y, gGrainSizeNames[snapIndex]]];
	CGPoint converted = [self convertPoint:touchLocation toView:self.controller.view];						// in coordinates of controller's main view
    self.locationLabel.frame = CGRectMake(converted.x+10, converted.y-40, self.locationLabel.frame.size.width, self.locationLabel.frame.size.height);
    [self.dimensionLabel setText:[NSString stringWithFormat:@"Thickness: %4.2fm", stratum.frame.size.height]];
    self.dimensionLabel.frame = CGRectMake(VX(stratum.frame.origin.x+stratum.frame.size.width/2.)-self.dimensionLabel.bounds.size.width/2., VY(stratum.frame.origin.y+stratum.frame.size.height/2.)-self.dimensionLabel.bounds.size.height/2., self.dimensionLabel.frame.size.width, self.dimensionLabel.frame.size.height);
}

#define ANCHOR_X (-0.5)
#define SCISSORS_X (-0.25)
#define HIT_DISTANCE 1./6.

/*
 Toggle the pencil highlighting mode
 */

- (void)handlePencilTap:(Stratum *)stratum
{
	self.pencilActive = !self.pencilActive;
	// clone properties to support drawPencilHighlighting
	self.overlayContainer.selectedPencilStratum = stratum;
	self.selectedStratum = stratum;
	self.overlayContainer.origin = self.origin;
	self.overlayContainer.activeDocument = self.activeDocument;
	self.overlayContainer.strataView = self;
	if (stratum.outline == nil || stratum.outline.count == 0)
		[stratum initializeOutline];
	[self.overlayContainer.overlay setNeedsDisplay];
}

- (void)handlePaleoTap:(PaleoCurrent *)paleo inStratum:(Stratum *)stratum
{
	
}

#pragma mark Touch events handling

/*
 These are routed to StrataView, after determining that pan gesture on any of the tool icons has not fired (action methods are in StrataViewController).
 
 We check to see whether user has hit a move icon, anchor icon, or scissors icon.
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.pencilActive) {
		[self pencilTouchesBegan:touches withEvent:event];
		return;
	}
	if (!self.touchesEnabled) return;
	CGPoint dragPoint = [self getDragPoint:event];
	for (NSMutableDictionary *dict in self.iconLocations) {												// first check move icons
		CGPoint iconLocation;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(dict), &iconLocation);
		if ((dragPoint.x-iconLocation.x)*(dragPoint.x-iconLocation.x)+
			(dragPoint.y-iconLocation.y)*(dragPoint.y-iconLocation.y) < HIT_DISTANCE*HIT_DISTANCE) {	// hit detected
			[[NSNotificationCenter defaultCenter] postNotificationName:SREditingOperationStarted object:self];	// disable scrolling
			self.dragActive = YES;
			self.dragOffsetFromCenter = CGSizeMake(dragPoint.x-iconLocation.x, dragPoint.y-iconLocation.y);
			self.activeDragIndex = [self.iconLocations indexOfObject:dict];								// index of selected object
			Stratum *stratum = self.activeDocument.strata[self.activeDragIndex];						// selected stratum
			self.dragConstraint = CGPointMake(stratum.frame.origin.x, stratum.frame.origin.y);
			[self.locationLabel setHidden:NO];															// display location and dimension coordinate text
			[self.dimensionLabel setHidden:NO];
			NSSet *touches = [event touchesForView:self];
			UITouch *touch = touches.anyObject;
			CGPoint locationInView = [touch locationInView:self];
			[self updateCoordinateText:iconLocation touchLocation:locationInView stratum:stratum];
			[self setNeedsDisplay];
			break;
		}
	}
	for (Stratum *stratum in self.activeDocument.strata) {												// check anchors, and scissors
		if (stratum != self.activeDocument.strata.lastObject) {
			if (stratum.hasAnchor && (dragPoint.x-ANCHOR_X)*(dragPoint.x-ANCHOR_X)+
				(dragPoint.y-stratum.frame.origin.y)*(dragPoint.y-stratum.frame.origin.y) < HIT_DISTANCE*HIT_DISTANCE) {// hit detected on anchor icon
				[[NSNotificationCenter defaultCenter] postNotificationName:SREditingOperationStarted object:self];	// disable scrolling
				self.selectedAnchorStratum = stratum;
				stratum.hasAnchor = NO;																	// user is removing it (might return it at touchesEnded
			} else if (stratum.hasPageCutter && (dragPoint.x-SCISSORS_X)*(dragPoint.x-SCISSORS_X)+
					   (dragPoint.y-stratum.frame.origin.y)*(dragPoint.y-stratum.frame.origin.y) < HIT_DISTANCE*HIT_DISTANCE) {// hit detected on scissors icon
				[[NSNotificationCenter defaultCenter] postNotificationName:SREditingOperationStarted object:self];	// disable scrolling
				self.selectedScissorsStratum = stratum;
				stratum.hasPageCutter = NO;																// user is removing it (might return it at touchesEnded
			}
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	if (self.pencilActive) {
		[self pencilTouchesMoved:touches withEvent:event];
		return;
	}
	if (!self.touchesEnabled) return;
	CGPoint dragPoint = [self getDragPoint:event];
	if (self.dragActive) {																				// if dragging is active, modify the selected stratum
		CGPoint offsetDragPoint = CGPointMake(dragPoint.x-self.dragOffsetFromCenter.width, dragPoint.y-self.dragOffsetFromCenter.height);	// coordinates of icon center
		if (offsetDragPoint.x < self.dragConstraint.x) offsetDragPoint.x = self.dragConstraint.x;		// constrain the dragged icon
		if (offsetDragPoint.y < self.dragConstraint.y) offsetDragPoint.y = self.dragConstraint.y;
		Stratum *stratum = self.activeDocument.strata[self.activeDragIndex];							// selected stratum
#ifdef MUTABLE
		NSMutableDictionary *dict = [self.iconLocations objectAtIndex:self.activeDragIndex];
		[dict setObject:[NSNumber numberWithFloat:offsetDragPoint.x] forKey:@"X"];
		[dict setObject:[NSNumber numberWithFloat:offsetDragPoint.y] forKey:@"Y"];
#else
		CFDictionaryRef dict = CGPointCreateDictionaryRepresentation(offsetDragPoint);
		[self.iconLocations replaceObjectAtIndex:self.activeDragIndex withObject:(__bridge id)(dict)];
		CFRelease(dict);
#endif
		CGPoint iconLocation;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(self.iconLocations[self.activeDragIndex]), &iconLocation);
		CGSize newSize = CGSizeMake(iconLocation.x-stratum.frame.origin.x, iconLocation.y-stratum.frame.origin.y);
		[self.activeDocument adjustStratumSize:newSize atIndex:self.activeDragIndex];	// here's where the work is done
		NSSet *touches = [event touchesForView:self];
		UITouch *touch = touches.anyObject;
		CGPoint locationInView = [touch locationInView:self];
		[self updateCoordinateText:offsetDragPoint touchLocation:locationInView stratum:stratum];
		[self setNeedsDisplay];
	} else if (self.selectedAnchorStratum || self.selectedScissorsStratum) {
		self.iconOrigin = dragPoint;																	// so we can display it as it's dragged
		[self setNeedsDisplay];																			// to display the dragged icon
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	if (self.pencilActive) {
		[self pencilTouchesEnded:touches withEvent:event];
		return;
	}
	if (!self.touchesEnabled) return;
	CGPoint dragPoint = [self getDragPoint:event];
	[self.locationLabel setHidden:YES];
	[self.dimensionLabel setHidden:YES];
	if (self.dragActive) {																				// modified an existing stratum, snap to grain size point
		CGPoint offsetDragPoint = CGPointMake(dragPoint.x-self.dragOffsetFromCenter.width, dragPoint.y-self.dragOffsetFromCenter.height);	// coordinates of icon center
		if (offsetDragPoint.x < self.dragConstraint.x) offsetDragPoint.x = self.dragConstraint.x;		// constrain the dragged icon
		if (offsetDragPoint.y < self.dragConstraint.y) offsetDragPoint.y = self.dragConstraint.y;
		int grainSizeIndex = [StrataDocument snapToGrainSizePoint:&offsetDragPoint.x];
		Stratum *stratum = self.activeDocument.strata[self.activeDragIndex];							// selected stratum
		stratum.grainSizeIndex = grainSizeIndex + 1;
#ifdef MUTABLE
		NSMutableDictionary *dict = [self.iconLocations objectAtIndex:self.activeDragIndex];
		[dict setObject:[NSNumber numberWithFloat:offsetDragPoint.x] forKey:@"X"];
		[dict setObject:[NSNumber numberWithFloat:offsetDragPoint.y] forKey:@"Y"];
#else
		CFDictionaryRef dict = CGPointCreateDictionaryRepresentation(offsetDragPoint);
		[self.iconLocations replaceObjectAtIndex:self.activeDragIndex withObject:(__bridge id)(dict)];
		CFRelease(dict);
#endif
		CGPoint iconLocation;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(self.iconLocations[self.activeDragIndex]), &iconLocation);
		CGSize newSize = CGSizeMake(iconLocation.x-stratum.frame.origin.x, iconLocation.y-stratum.frame.origin.y);
		[self.activeDocument adjustStratumSize:newSize atIndex:self.activeDragIndex];					// here's where the work is done
		if (self.activeDragIndex == self.activeDocument.strata.count-1 &&
			((Stratum *)self.activeDocument.strata.lastObject).frame.size.width &&
			((Stratum *)self.activeDocument.strata.lastObject).frame.size.height) {						// user has modified last (empty) stratum, create a new empty stratum
			Stratum *lastStratum = self.activeDocument.strata.lastObject;
			Stratum *newStratum = [[Stratum alloc] initWithFrame:CGRectMake(0, lastStratum.frame.origin.y+lastStratum.frame.size.height, 0, 0)];
			newStratum.materialNumber = 0;																// unassigned material
			[self.activeDocument.strata addObject:newStratum];
		} else if (stratum.grainSizeIndex == 1 && stratum.frame.size.height == 0) {						// user has dragged UR corner to LL corner, remove the stratum
			if (self.activeDragIndex != self.activeDocument.strata.count-1) {							// last stratum is already empty, do nothing in this case
				[self.activeDocument removeStratumAtIndex:self.activeDragIndex];
			}
		}
		// possible resizing of StrataView
		float topStratumLocation = ((Stratum *)self.activeDocument.strata.lastObject).frame.origin.y+((Stratum *)self.activeDocument.strata.lastObject).frame.size.height;
			if (topStratumLocation > self.activeDocument.strataHeight-2.0) {							// increase StrataView height
			self.activeDocument.strataHeight = fmaxf((int) (topStratumLocation + 3), 8);
			[[NSNotificationCenter defaultCenter] postNotificationName:SRStrataHeightChangedNotification object:self];
			if (self.activeDragIndex == self.activeDocument.strata.count-2)								// pin scroller to the top if we're editing the top stratum
				[[NSNotificationCenter defaultCenter] postNotificationName:SRStrataViewScrollerScrollToTop object:self];
		} else if (topStratumLocation < self.activeDocument.strataHeight-4 && self.activeDocument.strataHeight > 8) {// decrease StrataView height
			self.activeDocument.strataHeight = fmaxf((int) (topStratumLocation + 3), 8);
			[[NSNotificationCenter defaultCenter] postNotificationName:SRStrataHeightChangedNotification object:self];
			if (self.activeDragIndex == self.activeDocument.strata.count-2)								// pin scroller to the top if we're editing the top stratum
				[[NSNotificationCenter defaultCenter] postNotificationName:SRStrataViewScrollerScrollToTop object:self];
		} else
			[self setNeedsDisplay];
	} else if (self.selectedAnchorStratum || self.selectedScissorsStratum) {
		if (dragPoint.x < 0.5) {																		// otherwise, throw it away
			float distance = HUGE;
			Stratum *closestStratum;
			for (Stratum *stratum in self.activeDocument.strata) {
				if (fabsf(dragPoint.y-stratum.frame.origin.y) < distance) {
					distance = fabsf(dragPoint.y-stratum.frame.origin.y);
					closestStratum = stratum;
				}
			}
			if (distance != HUGE) {
				if ([self.activeDocument.strata indexOfObject:closestStratum] != 0) {					// can't attach these to first stratum
					if (self.selectedAnchorStratum)
						closestStratum.hasAnchor = YES;													// tool has already been deselected, this selects it
					else
						closestStratum.hasPageCutter = YES;												// tool has already been deselected, this selects it
				}
			}
		}
		self.selectedAnchorStratum = self.selectedScissorsStratum = nil;
	}
	self.dragActive = NO;
	self.selectedPaleoCurrent = nil;
	[self populateMoveIconLocations];																	// re-populate move icon coordinates
	[[NSNotificationCenter defaultCenter] postNotificationName:SREditingOperationEnded object:self];	// re-enable scrolling
	if (!self.pencilActive)
		[self setNeedsDisplay];																			// still causes extra redraw when exiting pencil highlighting mode
}

//	when is this called?

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
}

- (void)drawRect:(CGRect)rect
{
	
}

-(void)drawLayer:(CALayer*)layer inContext:(CGContextRef)currentContext
{
	gTransparent = YES;
	[self drawGraphPaper:currentContext];
	CGContextSetShouldAntialias(currentContext, YES);
	CGRect clippingRect = CGContextGetClipBoundingBox(currentContext);
	// setup patterns
	struct CGPatternCallbacks patternCallbacks = {
		0, &patternDrawingCallback, 0
	};
	CGFloat alpha = 1;
	gPageArray = self.patternsPageArray;
	// apparently, we need to do this in the current context, can't cache it
	CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
	CGContextSetFillColorSpace(currentContext, patternSpace);
	CGColorSpaceRelease(patternSpace);
	// setup graphic attributes for drawing strata rectangles
	CGContextSetLineWidth(currentContext, 3);
	CGFloat colorComponents[4] = {0, 0, 0, 1.};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef color = CGColorCreate(colorSpace, colorComponents);
	CGContextSetStrokeColorWithColor(currentContext, color);
	CFRelease(color);
	CFRelease(colorSpace);
	for (int index = self.activeDocument.strata.count-1; index>=0; --index) {
		Stratum *stratum = self.activeDocument.strata[index];
		CGRect myRect = CGRectMake(VX(stratum.frame.origin.x),							// stratum rectangle
								   VY(stratum.frame.origin.y),
								   VDX(stratum.frame.size.width),
								   VDY(stratum.frame.size.height));
		if (CGRectIntersectsRect(myRect, clippingRect)) {								// only if it's inside clipping area
			if (stratum.outline == nil || stratum.outline.count == 0) {					// no outline, just a rectangle
				// setup fill pattern, must do for each stratum
				if (!self.dragActive) {
					CGPatternRef pattern = CGPatternCreate((void *)stratum.materialNumber, CGRectMake(0, 0, 54, 54), CGAffineTransformMakeScale(self.activeDocument.patternScale, -self.activeDocument.patternScale), 54, 54, kCGPatternTilingConstantSpacing, YES, &patternCallbacks);
					CGContextSetFillPattern(currentContext, pattern, &alpha);
					CGPatternRelease(pattern);
					gScale = self.scale;
					CGContextFillRect(currentContext, myRect);							// draw fill pattern
				}
				CGContextStrokeRect(currentContext, myRect);							// draw boundary
			} else
				[self drawStratumOutline:stratum inContext:currentContext];
		}
		if (stratum.hasPageCutter) [self.scissorsIcon drawAtPoint:CGPointMake(-0.25, stratum.frame.origin.y) scale:self.scale inContext:currentContext];
		// causes error
		if (stratum.hasAnchor) [self.anchorIcon drawAtPoint:CGPointMake(-0.5, stratum.frame.origin.y) scale:self.scale inContext:currentContext];
		for (PaleoCurrent *paleo in stratum.paleoCurrents)
			[self.arrowIcon drawAtPointWithRotation:CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y) scale:1 rotation:paleo.rotation inContext:currentContext];
		if (!self.dragActive && stratum != self.activeDocument.strata.lastObject)			// draw info icon, unless this is the last (empty) stratum
			[self.infoIcon drawAtPoint:CGPointMake(stratum.frame.origin.x+stratum.frame.size.width-.12, stratum.frame.origin.y+.1) scale:self.scale inContext:currentContext];
		if (!self.dragActive && stratum != self.activeDocument.strata.lastObject)			// draw pencil icon, unless this is the last (empty) stratum
			[self.pencilIcon drawAtPoint:CGPointMake(stratum.frame.origin.x+(stratum.frame.size.width/2.0), stratum.frame.origin.y+(stratum.frame.size.height/2.0)) scale:self.scale inContext:currentContext];
	}
	for (NSDictionary *dict in self.iconLocations) {										// draw move icons
		CGPoint iconLocation;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(dict), &iconLocation);
		CGPoint viewPoint = CGPointMake(VX(iconLocation.x), VY(iconLocation.y));
		CGRect iconRect = CGRectMake(viewPoint.x-self.moveIcon.width, viewPoint.y-self.moveIcon.width, self.moveIcon.width*2, self.moveIcon.width*2);
		if (CGRectIntersectsRect(clippingRect, iconRect)) {
			if (self.dragActive) {
				if (self.activeDragIndex == [self.iconLocations indexOfObject:dict])
					[self.moveIconSelected drawAtPoint:iconLocation scale:self.scale inContext:currentContext];		// draw icon in selected state if it's selected and dragging is active
			} else
				[self.moveIcon drawAtPoint:iconLocation scale:self.scale inContext:currentContext];
		}
	}
	if (self.selectedScissorsStratum)
		[self.scissorsIcon drawAtPoint:self.iconOrigin scale:self.scale inContext:currentContext];
	if (self.selectedAnchorStratum)
		[self.anchorIcon drawAtPoint:self.iconOrigin scale:self.scale inContext:currentContext];
}

- (void)drawGraphPaper:(CGContextRef)context
{
	// paper background
	CGContextSetShouldAntialias(context, NO);
	
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,self.bounds);
	// horizontal rules
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:1 blue:1 alpha:1.0].CGColor);
	for (float i=-YORIGIN; i<self.bounds.size.height/PPI; i+=GRID_WIDTH) {
		CGContextMoveToPoint(context, 0, VY(i));
		CGContextAddLineToPoint(context, self.frame.size.width, VY(i));
		CGContextStrokePath(context);
	}
	// vertical rules
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:1 blue:1 alpha:1.0].CGColor);
	for (float i=-XORIGIN; i<=self.bounds.size.width/PPI; i+=GRID_WIDTH) {
		CGContextMoveToPoint(context, VX(i), 0);
		CGContextAddLineToPoint(context, VX(i), self.frame.origin.y+self.frame.size.height);
		CGContextStrokePath(context);
	}
}

@end


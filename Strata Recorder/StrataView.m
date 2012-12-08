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

/*
 A static callback function for drawing stratigraphic patterns. Uses a matrix of pattern swatches contained in a manually prepared
 PDF, which contains rows of 5 elements each, one row per PDF page, arranged sequentially according to pattern number. Each item is a rectangle of 55
 pixels, which contains a 54 x 54 pixel pattern representation, derived from the "official" patterns. Presumably, the representations
 are in PostScript, so are resolution-independent.
 
 The callback makes use of static variables, because it has no access to StrataView.
 */
void patternDrawingCallback(void *info, CGContextRef context)
{
	if ((int) info <= 0) return;
	int patternIndex = (int) info-601;
	int columnIndex = patternIndex % 5;
	CGContextTranslateCTM(context, -(55*columnIndex)+.1, +.3);									// so the ith element in the row will be at the origin
	CGContextDrawPDFPage(context, [((NSValue *)gPageArray[patternIndex/5]) pointerValue]);		// draw the requested pattern rectangle from the PDF materials patterns page
}

@interface StrataView() <UIGestureRecognizerDelegate>
@property IconImage* moveIcon;							// icon used to display drag sensitive locations for moving the upper-right corner of strata rectangles
@property IconImage* moveIconSelected;
@property IconImage* infoIcon;							// display touch sensitive location for info popovers
@property IconImage* scissorsIcon;
@property IconImage* anchorIcon;
@property IconImage* arrowIcon;
@property NSMutableArray* iconLocations;				// CGPoint dictionaries, in user coordinates, for moveIcon's
@property CGSize dragOffsetFromCenter;					// the offset of the drag coordinate from center of dragged object, to track movement of icon's center coordinates
@property CGPoint dragConstraint;						// lower left limit of dragging allowed, don't allow negative height/width
@property BOOL dragActive;								// tracks dragging state
@property int activeDragIndex;							// index in strata of dragged item
@end

@implementation StrataView

- (void)populateIconLocations
{
	self.iconLocations = [[NSMutableArray alloc] init];
    for (Stratum *stratum in self.activeDocument.strata) {
        CGRect myRect = stratum.frame;
        CGPoint iconLocation = CGPointMake(myRect.origin.x+myRect.size.width, myRect.origin.y+myRect.size.height);
		CFDictionaryRef dict = CGPointCreateDictionaryRepresentation(iconLocation);
        [self.iconLocations addObject:(__bridge id)(dict)];
		CFRelease(dict);
    }
}

- (void)handleStrataHeightChanged:(id)sender
{
	// these properties must be updated, because the graphics transform functions depend on them
	self.moveIcon.bounds = self.bounds;
	self.moveIconSelected.bounds = self.bounds;
	self.infoIcon.bounds = self.bounds;
}

- (void)setActiveDocument:(StrataDocument *)activeDocument
{
	_activeDocument = activeDocument;
	[self populateIconLocations];														// we're overriding the setter, because this is a good time to do this
}

/*
 initWithCoder and initWithFrame are not reliably called, so we call this from the view controller in its UIApplicationDidBecomeActiveNotification
 */
- (void)initialize
{
	self.moveIcon = [[IconImage alloc] initWithImageName:@"move icon.png" offset:CGPointMake(9./50., 9./50.) width:50 viewBounds:self.bounds];
	float width = 50.*921./555.;														// ratio of image size, relative to move icon, because of "flare" imagery
	self.moveIconSelected = [[IconImage alloc] initWithImageName:@"move icon selected.png" offset:CGPointMake(25./width, 25./width) width:width viewBounds:self.bounds];
	self.infoIcon = [[IconImage alloc] initWithImageName:@"info icon.png" offset:CGPointMake(.5, .5) width:25 viewBounds:self.bounds];
	self.scissorsIcon = [[IconImage alloc] initWithImageName:@"cut.png" offset:CGPointMake(.5, .5) width:25 viewBounds:self.bounds];
	self.anchorIcon = [[IconImage alloc] initWithImageName:@"anchor.png" offset:CGPointMake(.5, .5) width:25 viewBounds:self.bounds];
	self.arrowIcon = [[IconImage alloc] initWithImageName:@"paleocurrent.png" offset:CGPointMake(.5, .5) width:25 viewBounds:self.bounds];
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	[self addGestureRecognizer:longPress];
	longPress.cancelsTouchesInView = NO;
}

//	return in user coordinates

- (CGPoint)getDragPoint:(UIEvent *)event
{
	CGPoint dragPoint = CGPointMake(UX([(UITouch *)[[event touchesForView:self] anyObject] locationInView:self].x),
									UY([(UITouch *)[[event touchesForView:self] anyObject] locationInView:self].y));
	return dragPoint;
}

- (void)updateCoordinateText:(CGPoint)iconLocation stratum:(Stratum *)stratum
{
    [self.locationLabel setText:[NSString stringWithFormat:@"%4.2fm x %4.2fm", iconLocation.x, iconLocation.y]];
    self.locationLabel.frame = CGRectMake(VX(iconLocation.x+.1), VY(iconLocation.y+.25), self.locationLabel.frame.size.width, self.locationLabel.frame.size.height);
    [self.dimensionLabel setText:[NSString stringWithFormat:@"W %4.2fm x H %4.2fm", stratum.frame.size.width, stratum.frame.size.height]];
    self.dimensionLabel.frame = CGRectMake(VX(stratum.frame.origin.x+stratum.frame.size.width/2.)-self.dimensionLabel.bounds.size.width/2., VY(stratum.frame.origin.y+stratum.frame.size.height/2.)-self.dimensionLabel.bounds.size.height/2., self.dimensionLabel.frame.size.width, self.dimensionLabel.frame.size.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
	CGPoint dragPoint = [self getDragPoint:event];
#define HIT_DISTANCE 1./6.
	for (NSDictionary *dict in self.iconLocations) {													// first check move icons
		CGPoint iconLocation;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(dict), &iconLocation);
		if ((dragPoint.x-iconLocation.x)*(dragPoint.x-iconLocation.x)+
			(dragPoint.y-iconLocation.y)*(dragPoint.y-iconLocation.y) < HIT_DISTANCE*HIT_DISTANCE) {	// hit detected
			self.dragActive = YES;
			self.dragOffsetFromCenter = CGSizeMake(dragPoint.x-iconLocation.x, dragPoint.y-iconLocation.y);
			self.activeDragIndex = [self.iconLocations indexOfObject:dict];								// index of selected object
			Stratum *stratum = self.activeDocument.strata[self.activeDragIndex];						// selected stratum
			self.dragConstraint = CGPointMake(stratum.frame.origin.x, stratum.frame.origin.y);
			[self.locationLabel setHidden:NO];															// display location and dimension coordinate text
			[self.dimensionLabel setHidden:NO];
			[self updateCoordinateText:iconLocation stratum:stratum];
			[self setNeedsDisplay];
			break;
		}
	}
	for (Stratum *stratum in self.activeDocument.strata) {												// check info icons
		if (stratum != self.activeDocument.strata.lastObject) {
			CGPoint iconLocation = CGPointMake(stratum.frame.origin.x+stratum.frame.size.width-.12, stratum.frame.origin.y+.1);
			if ((dragPoint.x-iconLocation.x)*(dragPoint.x-iconLocation.x)+
				(dragPoint.y-iconLocation.y)*(dragPoint.y-iconLocation.y) < HIT_DISTANCE*HIT_DISTANCE) {// hit detected
				self.selectedStratum = stratum;															// for our delegate's use
				self.infoSelectionPoint = CGPointMake(VX(iconLocation.x), VY(iconLocation.y));			// for our delegate's use
				[self.delegate handleStratumInfo:self];													// tell our delegate to create the navigation controller for managing stratum properties
			} else {																					// look for paleocurrents in the stratum
				for (PaleoCurrent *paleo in stratum.paleoCurrents) {
					CGPoint paleoLocation = CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y);
					if ((dragPoint.x-paleoLocation.x)*(dragPoint.x-paleoLocation.x)+
						(dragPoint.y-paleoLocation.y)*(dragPoint.y-paleoLocation.y) < HIT_DISTANCE*HIT_DISTANCE) {// hit detected
						self.selectedPaleoCurrent = paleo;
						self.selectedStratum = stratum;
						self.dragConstraint = CGPointMake(stratum.frame.size.width, stratum.frame.origin.y);
					}
				}
			}
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	CGPoint dragPoint = [self getDragPoint:event];
	if (self.dragActive) {																				// if dragging is active, modify the selected stratum
		CGPoint offsetDragPoint = CGPointMake(dragPoint.x-self.dragOffsetFromCenter.width, dragPoint.y-self.dragOffsetFromCenter.height);	// coordinates of icon center
		if (offsetDragPoint.x < self.dragConstraint.x) offsetDragPoint.x = self.dragConstraint.x;		// constrain the dragged icon
		if (offsetDragPoint.y < self.dragConstraint.y) offsetDragPoint.y = self.dragConstraint.y;
		Stratum *stratum = self.activeDocument.strata[self.activeDragIndex];							// selected stratum
		CFDictionaryRef dict = CGPointCreateDictionaryRepresentation(offsetDragPoint);
		[self.iconLocations replaceObjectAtIndex:self.activeDragIndex withObject:(__bridge id)(dict)];
		CFRelease(dict);
		[self updateCoordinateText:offsetDragPoint stratum:stratum];
		[self setNeedsDisplay];
	} else if (self.selectedPaleoCurrent) {
		CGPoint newOrigin = CGPointMake(dragPoint.x-self.selectedStratum.frame.size.width, dragPoint.y-self.selectedStratum.frame.origin.y);
		if (newOrigin.x < 0) newOrigin.x = 0;
		if (newOrigin.y < 0) newOrigin.y = 0;
		if (newOrigin.y > self.selectedStratum.frame.size.height) newOrigin.y = self.selectedStratum.frame.size.height;
		self.selectedPaleoCurrent.origin = newOrigin;
		[self setNeedsDisplay];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[self.locationLabel setHidden:YES];
	[self.dimensionLabel setHidden:YES];
	if (self.dragActive && self.activeDragIndex == self.activeDocument.strata.count-1 &&
		((Stratum *)self.activeDocument.strata.lastObject).frame.size.width &&
		((Stratum *)self.activeDocument.strata.lastObject).frame.size.height) {							// user has modified last (empty) stratum, create a new empty stratum
		Stratum *lastStratum = self.activeDocument.strata.lastObject;
		Stratum *newStratum = [[Stratum alloc] initWithFrame:CGRectMake(0, lastStratum.frame.origin.y+lastStratum.frame.size.height, 0, 0)];
		newStratum.materialNumber = lastStratum.materialNumber;											// arbitrary material, for now
		[self.activeDocument.strata addObject:newStratum];
	}
	self.dragActive = NO;
	self.selectedPaleoCurrent = nil;
	[self populateIconLocations];																		// re-populate move icon coordinates
	[self setNeedsDisplay];
}

//	when is this called?

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
}
					
- (void)drawRect:(CGRect)rect
{
	[self drawGraphPaper:rect];
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(currentContext, YES);
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
	for (Stratum *stratum in self.activeDocument.strata) {									// for each stratum
		if (self.dragActive && [self.activeDocument.strata indexOfObject:stratum] == self.activeDragIndex) {	// adjust strata dimensions, based on selected move icon's coordinates
			CGPoint iconLocation;
			CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(self.iconLocations[self.activeDragIndex]), &iconLocation);
			CGSize newSize = CGSizeMake(iconLocation.x-stratum.frame.origin.x, iconLocation.y-stratum.frame.origin.y);
			[self.activeDocument adjustStratumSize:newSize atIndex:self.activeDragIndex];	// here's where the work is done
		}
		CGRect myRect = CGRectMake(VX(stratum.frame.origin.x),								// stratum rectangle
								   VY(stratum.frame.origin.y),
								   VDX(stratum.frame.size.width),
								   VDY(stratum.frame.size.height));
		// setup fill pattern, must do for each stratum
		if (!self.dragActive) {
			CGPatternRef pattern = CGPatternCreate((void *)stratum.materialNumber, CGRectMake(0, 0, 54, 54), CGAffineTransformMakeScale(1., -1.), 54, 54, kCGPatternTilingConstantSpacing, YES, &patternCallbacks);
			CGContextSetFillPattern(currentContext, pattern, &alpha);
			gScale = self.scale;
			CGContextFillRect(currentContext, myRect);											// draw fill pattern
		}
		CGContextStrokeRect(currentContext, myRect);										// draw boundary
		if (stratum.hasPageCutter) [self.scissorsIcon drawAtPoint:CGPointMake(-0.25, stratum.frame.origin.y) scale:self.scale];
		if (stratum.hasAnchor) [self.anchorIcon drawAtPoint:CGPointMake(-0.5, stratum.frame.origin.y) scale:self.scale];
		for (PaleoCurrent *paleo in stratum.paleoCurrents) {
//			[self.arrowIcon drawAtPointWithRotation:CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y) scale:1 rotation:M_PI_4*.8];
//			[self.arrowIcon drawAtPointWithRotation:CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y) scale:1 rotation:M_PI_4*.9];
//			[self.arrowIcon drawAtPointWithRotation:CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y) scale:1 rotation:M_PI_4];
//			[self.arrowIcon drawAtPointWithRotation:CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y) scale:1 rotation:M_PI_4*1.1];
//			[self.arrowIcon drawAtPointWithRotation:CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y) scale:1 rotation:M_PI_4*1.2];
//			[self.arrowIcon drawAtPoint:CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y) scale:1];
			[self.arrowIcon drawAtPointWithRotation:CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y) scale:1 rotation:paleo.rotation];
		}
		if (!self.dragActive && stratum != self.activeDocument.strata.lastObject)			// draw info icon, unless this is the last (empty) stratum
			[self.infoIcon drawAtPoint:CGPointMake(stratum.frame.origin.x+stratum.frame.size.width-.12, stratum.frame.origin.y+.1) scale:self.scale];
	}
	for (NSDictionary *dict in self.iconLocations) {										// draw move icons
		CGPoint iconLocation;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(dict), &iconLocation);
		if (self.dragActive) {
			if (self.activeDragIndex == [self.iconLocations indexOfObject:dict])
				[self.moveIconSelected drawAtPoint:iconLocation scale:self.scale];			// draw icon in selected state if it's selected and dragging is active
		} else
			[self.moveIcon drawAtPoint:iconLocation scale:self.scale];
	}
}

- (void)drawGraphPaper:(CGRect)rect
{
	// paper background
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, NO);
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


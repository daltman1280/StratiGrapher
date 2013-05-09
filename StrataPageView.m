//
//  StrataPageView.m
//  Strata Recorder
//
//  Created by Don Altman on 11/16/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#define XORIGIN 0.0												// distance in inches of origin from LL of view
#define YORIGIN 0.0												// distance in inches of origin from LL of view

#import "StrataPageView.h"
#import "StrataView.h"											// pattern drawing
#import "Graphics.h"
#import "StrataNotifications.h"

@implementation StrataPageView

- (void)setActiveDocument:(StrataDocument *)activeDocument
{
	_activeDocument = activeDocument;
	self.bounds = CGRectMake(0, 0, self.activeDocument.pageDimension.width*PPI, self.activeDocument.pageDimension.height*PPI);
	self.arrowIcon.bounds = self.bounds;						// bounds for icons must also be updated
}

//	do initialization here

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	self.origin = CGPointMake(XORIGIN, YORIGIN);
	self.arrowIcon = [[IconImage alloc] initWithImageName:@"paleocurrent greyscale.png" offset:CGPointMake(.5, .5) width:25 viewBounds:self.bounds viewOrigin:self.origin];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleActiveDocumentSelectionChanged:) name:SRActiveDocumentSelectionChanged object:nil];
	return self;
}

- (void)handleActiveDocumentSelectionChanged:(NSNotification *)notification
{
	self.activeDocument = [notification.userInfo objectForKey:@"activeDocument"];
}

// convert from unit to view coordinates

- (CGRect)RectUtoV:(CGRect)rect
{
	return CGRectMake(VX(rect.origin.x), VY(rect.origin.y), VDX(rect.size.width), VDY(rect.size.height));
}

- (void)drawRect:(CGRect)rect
{
	if (self.mode == PDFMode) {
		NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *pdfFile = [documentsFolder stringByAppendingFormat:@"/%@.pdf", self.activeDocument.name];
		PPI = 72.;																			// this is the default resolution of PDF format
		self.bounds = CGRectMake(0, 0, self.activeDocument.pageDimension.width*PPI, self.activeDocument.pageDimension.height*PPI);
		UIGraphicsBeginPDFContextToFile(pdfFile, self.bounds, nil);
	}
	if (self.mode == PDFMode)
		UIGraphicsBeginPDFPage();
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGFloat colorComponentsBlack[4] = {0, 0, 0, 1.};
	CGFloat colorComponentsWhite[4] = {1, 1, 1, 1.};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef colorBlack = CGColorCreate(colorSpace, colorComponentsBlack);
	CGColorRef colorWhite = CGColorCreate(colorSpace, colorComponentsWhite);
	CGContextSetStrokeColorWithColor(currentContext, colorBlack);
	CFRelease(colorSpace);
	// draw page boundaries
	CGContextSetLineWidth(currentContext, 3);
	CGContextStrokeRect(currentContext, self.bounds);
	// draw scale indicator
	CGContextBeginPath(currentContext);
	CGContextMoveToPoint(currentContext, VX(self.activeDocument.pageMargins.width), VY(self.activeDocument.pageMargins.height));
	CGContextAddLineToPoint(currentContext, VX(self.activeDocument.pageMargins.width), VY(self.activeDocument.pageMargins.height+1/self.activeDocument.scale));
	CGContextClosePath(currentContext);
	CGContextStrokePath(currentContext);
	CGContextSaveGState(currentContext);
	CGContextTranslateCTM(currentContext, VDX(self.activeDocument.pageMargins.width), -VDY(self.activeDocument.pageDimension.height-self.activeDocument.pageMargins.height));
	CGContextRotateCTM(currentContext, -M_PI_2);
	[[self.activeDocument.units isEqualToString:@"Metric"] ? @"1 Meter" : @"1 Foot" drawAtPoint:CGPointZero withFont:[UIFont systemFontOfSize:10]];
	CGContextRestoreGState(currentContext);
	// calculate maximum width of strata
	CGFloat maxWidth = 0;
	for (Stratum *stratum in self.activeDocument.strata)
		if (stratum.frame.size.width > maxWidth) maxWidth = stratum.frame.size.width;
	maxWidth /= self.activeDocument.scale;													//  maxWidth now in inches
	// setup patterns
	struct CGPatternCallbacks patternCallbacks = {
		0, &patternDrawingCallback, 0
	};
	CGFloat alpha = 1;
	gPageArray = self.patternsPageArray;															// global variable used by pattern drawing callback
	// apparently, we need to do this in the current context, can't cache it
	CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
	CGContextSetFillColorSpace(currentContext, patternSpace);
	CGColorSpaceRelease(patternSpace);
	// setup graphic attributes for drawing strata rectangles
	CGContextSetLineWidth(currentContext, self.activeDocument.lineThickness);
	gScale = 1;
	float scale = self.activeDocument.scale;
	float pageTop = self.activeDocument.pageDimension.height-self.activeDocument.pageMargins.height;
	// horizontal and vertical adjustments, in inches, which take into account column membership of a stratum
	CGPoint offset = CGPointMake(self.activeDocument.pageDimension.width-self.activeDocument.pageMargins.width-maxWidth, self.activeDocument.pageMargins.height);
	// draw strata
	for (Stratum *stratum in self.activeDocument.strata) {
		CGRect stratumRect = CGRectMake(stratum.frame.origin.x/scale, stratum.frame.origin.y/scale, stratum.frame.size.width/scale, stratum.frame.size.height/scale);
		stratumRect = CGRectStandardize(stratumRect);
		stratumRect = CGRectOffset(stratumRect, offset.x, offset.y);
		float stratumTop = stratumRect.origin.y+stratumRect.size.height;
		if (stratumTop > pageTop || stratum.hasPageCutter) {
			stratumRect = CGRectOffset(stratumRect, -offset.x, -offset.y);					// undo the offset from current column
			offset.x -= maxWidth+self.activeDocument.pageMargins.width/2.0;					// horizontal adjustment using maxwidth, and adding horizontal page margin
			offset.y = -stratumRect.origin.y+self.activeDocument.pageMargins.height;		// vertical adjustment to make stratum sit on base page margin
			stratumRect = CGRectOffset(stratumRect, offset.x, offset.y);					// give it the same offset as succeeding strata in next column
		}
		for (PaleoCurrent *paleo in stratum.paleoCurrents) {
			CGPoint paleoOrigin = CGPointMake(stratumRect.origin.x+stratumRect.size.width+paleo.origin.x/scale, stratumRect.origin.y+paleo.origin.y/scale);
			[self.arrowIcon drawAtPointWithRotation:paleoOrigin scale:1 rotation:paleo.rotation];
		}
		if ([self.activeDocument.strata indexOfObject:stratum] == self.activeDocument.strata.count-1) break;	// don't draw last empty stratum
		CGPatternRef pattern = CGPatternCreate((void *)stratum.materialNumber, CGRectMake(0, 0, 54, 54), CGAffineTransformMakeScale(1., -1.), 54, 54, kCGPatternTilingConstantSpacing, YES, &patternCallbacks);
		CGContextSetFillPattern(currentContext, pattern, &alpha);
		if (stratum.outlineTop == nil && stratum.outlineRight == nil && stratum.outlineBottom == nil) {		// no outline, treat it as a rectangle
			stratumRect = [self RectUtoV:stratumRect];											// convert to view coordinates
#if 0
			if (self.mode == PDFMode) {															// fill it with white
				CGContextSetFillColorWithColor(currentContext, colorWhite);
				CGContextFillRect(currentContext, stratumRect);
				CGContextSetStrokeColorWithColor(currentContext, colorBlack);
				CGContextStrokeRect(currentContext, stratumRect);
			}
#endif
			CGContextFillRect(currentContext, stratumRect);
			CGContextStrokeRect(currentContext, stratumRect);
		} else {																			// has an outline
			CGContextSetFillPattern(currentContext, pattern, &alpha);
			CGContextSetLineWidth(currentContext, self.activeDocument.lineThickness);
			CGContextSetStrokeColorWithColor(currentContext, colorBlack);
			[self addOutline:stratum offset:offset];
			CGContextDrawPath(currentContext, kCGPathFillStroke);
		}
	}
	if (self.mode == PDFMode) {
		UIGraphicsEndPDFContext();
		self.mode = graphMode;
		PPI = 160.;																			// reset it from PDF to graphics resolution
	}
	CFRelease(colorWhite);
	CFRelease(colorBlack);
}

static int outlineCount = 50;

- (void)addOutline:(Stratum *)stratum offset:(CGPoint)offset
{
	float scale = self.activeDocument.scale;
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGMutablePathRef mPath = CGPathCreateMutable();
	// draw left boundary
	CGContextBeginPath(currentContext);
	CGPathMoveToPoint(mPath, NULL, VX(offset.x+stratum.frame.origin.x/scale), VY(offset.y+stratum.frame.origin.y/scale));
	CGPathAddLineToPoint(mPath, NULL, VX(offset.x+stratum.frame.origin.x/scale), VY(offset.y+(stratum.frame.origin.y+stratum.frame.size.height)/scale));
	
	for (int i=0; i<outlineCount; ++i) {												// top
		// unadusted point, proceeding from top/left to top/right
		CGPoint uPoint = CGPointMake(offset.x+(stratum.frame.origin.x+((float)i*stratum.frame.size.width/(float)outlineCount))/scale, offset.y+(stratum.frame.origin.y+stratum.frame.size.height)/scale);
		if (stratum.outlineTop[i] != [NSNull null]) uPoint.y += [stratum.outlineTop[i] floatValue];
		CGPathAddLineToPoint(mPath, NULL, VX(uPoint.x), VY(uPoint.y));
	}
	for (int i=0; i<outlineCount; ++i) {												// right
		// unadjusted point, proceeding from top/right to bottom/right
		CGPoint uPoint = CGPointMake(offset.x+(stratum.frame.origin.x+stratum.frame.size.width)/scale, offset.y+(stratum.frame.origin.y+stratum.frame.size.height-((float)i*stratum.frame.size.height/(float)outlineCount))/scale);
		if (stratum.outlineRight[i] != [NSNull null]) uPoint.x += [stratum.outlineRight[i] floatValue];
		CGPathAddLineToPoint(mPath, NULL, VX(uPoint.x), VY(uPoint.y));
	}
	for (int i=0; i<outlineCount; ++i) {												// bottom
		// unadjusted point, proceeding from bottm/right to bottom/left
		CGPoint uPoint = CGPointMake(offset.x+(stratum.frame.origin.x+stratum.frame.size.width-((float)i*stratum.frame.size.width/(float)outlineCount))/scale, offset.y+stratum.frame.origin.y/scale);
		if (stratum.outlineBottom[i] != [NSNull null]) uPoint.y += [stratum.outlineBottom[i] floatValue];
		CGPathAddLineToPoint(mPath, NULL, VX(uPoint.x), VY(uPoint.y));
	}
//	CGPathCloseSubpath(mPath);
	CGContextAddPath(currentContext, mPath);
	CGContextSetLineWidth(currentContext, self.activeDocument.lineThickness);
	CGPathRelease(mPath);
//	[[UIColor blackColor] setStroke];
//	[[UIColor whiteColor] setFill];
}

@end

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

- (void)drawCrossmark:(float)x y:(float)y
{
	float scale = self.activeDocument.scale;
	UIBezierPath *bleed = [UIBezierPath bezierPath];
	[bleed moveToPoint:CGPointMake(VX(x-.1/scale), VY(y))];
	[bleed addLineToPoint:CGPointMake(VX(x+.1/scale), VY(y))];
	[bleed moveToPoint:CGPointMake(VX(x), VY(y-.1/scale))];
	[bleed addLineToPoint:CGPointMake(VX(x), VY(y+.1/scale))];
	BOOL drawCrossmarks = NO;
	if (drawCrossmarks)
		[bleed stroke];
}

- (void)drawRect:(CGRect)rect
{
	gTransparent = NO;
	if (self.mode == PDFMode) {
		NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *pdfFile = [documentsFolder stringByAppendingFormat:@"/%@.pdf", self.activeDocument.name];
		CGContextScaleCTM(UIGraphicsGetCurrentContext(), 72./132., 72./132.);
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
	// draw bleeds
	{
		CGContextSetLineWidth(currentContext, 1);
		float marginWidth = self.activeDocument.pageMargins.width;
		float marginHeight = self.activeDocument.pageMargins.height;
		float pageWidth = self.activeDocument.pageDimension.width;
		float pageHeight = self.activeDocument.pageDimension.height;
		[self drawCrossmark:marginWidth y:marginHeight];
		[self drawCrossmark:marginWidth y:pageHeight-marginHeight];
		[self drawCrossmark:pageWidth-marginWidth y:marginHeight];
		[self drawCrossmark:pageWidth-marginWidth y:pageHeight-marginHeight];
	}
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
	// horizontal and vertical adjustments, in inches, which take into account column membership of a stratum
	CGPoint offset = CGPointMake(0, self.activeDocument.pageMargins.height);						// don't need x offset at this point, just calculating column widths
	float scale = self.activeDocument.scale;
	float pageTop = self.activeDocument.pageDimension.height-self.activeDocument.pageMargins.height;
	float sectionLabelsMargin = self.activeDocument.sectionLabels.count > 0 ? .1 : 0;				// in inches
	// calculate maximum width of each strata column
	NSMutableArray *maxWidths = [[NSMutableArray alloc] init];
	float maxWidthTemp = 0;
	for (Stratum *stratum in self.activeDocument.strata) {
		CGRect stratumRect = CGRectMake(stratum.frame.origin.x/scale, stratum.frame.origin.y/scale, stratum.frame.size.width/scale, stratum.frame.size.height/scale);
		stratumRect = CGRectStandardize(stratumRect);
		stratumRect = CGRectOffset(stratumRect, offset.x, offset.y);
		float stratumTop = stratumRect.origin.y+stratumRect.size.height;
		if (stratumTop > pageTop || stratum.hasPageCutter) {								// reached top of column, need to start a new column
			stratumRect = CGRectOffset(stratumRect, -offset.x, -offset.y);					// undo the offset from current column
			offset.y = -stratumRect.origin.y+self.activeDocument.pageMargins.height;		// vertical adjustment to make stratum sit on base page margin
			stratumRect = CGRectOffset(stratumRect, offset.x, offset.y);					// give it the same offset as succeeding strata in next column
			[maxWidths addObject:[NSNumber numberWithFloat:maxWidthTemp/scale+sectionLabelsMargin]];	// in inches
			maxWidthTemp = stratum.frame.size.width;										// reinitialize it with width of current stratum
		} else
			if (stratum.frame.size.width > maxWidthTemp) maxWidthTemp = stratum.frame.size.width;
	}
	[maxWidths addObject:[NSNumber numberWithFloat:maxWidthTemp/scale+sectionLabelsMargin]];// last column
	gScale = 1;
	int sectionIndex = 0;
	int stratumSectionLower = -1;
	int stratumSectionUpper = -1;
	if (self.activeDocument.sectionLabels.count > 0) {
		stratumSectionLower = stratumSectionUpper + 1;
		stratumSectionUpper = stratumSectionLower + ((SectionLabel *)self.activeDocument.sectionLabels[sectionIndex]).numberOfStrataSpanned-1;
	}
	// initial offset
	offset = CGPointMake(self.activeDocument.pageDimension.width-self.activeDocument.pageMargins.width-[maxWidths[0] floatValue], self.activeDocument.pageMargins.height);
	int columnIndex = 0;
	// draw strata
	for (Stratum *stratum in self.activeDocument.strata) {
		CGRect stratumRect = CGRectMake(stratum.frame.origin.x/scale, stratum.frame.origin.y/scale, stratum.frame.size.width/scale, stratum.frame.size.height/scale);
		stratumRect = CGRectStandardize(stratumRect);
		stratumRect = CGRectOffset(stratumRect, offset.x, offset.y);
		float stratumTop = stratumRect.origin.y+stratumRect.size.height;
		// need to draw a section label?
		if (stratumSectionUpper > -1 && (stratumTop > pageTop || stratum.hasPageCutter || [self.activeDocument.strata indexOfObject:stratum] == stratumSectionUpper)) {
			float xSectionBottom, ySectionBottom, xSectionTop, ySectionTop;
			NSString *labelText = ((SectionLabel *)self.activeDocument.sectionLabels[sectionIndex]).labelText;
			UIFont *font = [UIFont systemFontOfSize:18.0];
			CGSize size = [labelText sizeWithFont:font];
			if (stratumTop > pageTop || stratum.hasPageCutter) {							// we're at the end of a column, need to draw section label, even if more strata remain
				xSectionBottom = ((Stratum *)self.activeDocument.strata[stratumSectionLower]).frame.origin.x/scale + offset.x + [maxWidths[columnIndex] floatValue];
				ySectionBottom = ((Stratum *)self.activeDocument.strata[stratumSectionLower]).frame.origin.y/scale + offset.y;
				xSectionTop = stratum.frame.origin.x/scale + offset.x + [maxWidths[columnIndex] floatValue];
				ySectionTop = stratum.frame.origin.y/scale + offset.y;						// use bottom of stratum
			} else {
				xSectionBottom = ((Stratum *)self.activeDocument.strata[stratumSectionLower]).frame.origin.x/scale + offset.x + [maxWidths[columnIndex] floatValue];
				ySectionBottom = ((Stratum *)self.activeDocument.strata[stratumSectionLower]).frame.origin.y/scale + offset.y;
				xSectionTop = stratum.frame.origin.x/scale + offset.x + [maxWidths[columnIndex] floatValue];
				ySectionTop = stratum.frame.origin.y/scale + stratum.frame.size.height/scale + offset.y;
				++sectionIndex;
			}
			UIBezierPath *sectionLabelLine = [UIBezierPath bezierPath];
			[sectionLabelLine moveToPoint:CGPointMake(VX(xSectionBottom), VY(ySectionBottom))];
			[sectionLabelLine addLineToPoint:CGPointMake(VX(xSectionTop), VY(ySectionTop))];
			[sectionLabelLine stroke];
			[sectionLabelLine moveToPoint:CGPointMake(VX(xSectionBottom-0.05), VY(ySectionBottom))];
			[sectionLabelLine addLineToPoint:CGPointMake(VX(xSectionBottom+0.05), VY(ySectionBottom))];
			[sectionLabelLine stroke];
			[sectionLabelLine moveToPoint:CGPointMake(VX(xSectionTop-0.05), VY(ySectionTop))];
			[sectionLabelLine addLineToPoint:CGPointMake(VX(xSectionTop+0.05), VY(ySectionTop))];
			[sectionLabelLine stroke];
			// temporary graphics context, rotated, translated, color fill pattern space
			CGPoint center = CGPointMake(VX(xSectionBottom), VY(ySectionTop-(ySectionTop-ySectionBottom)/2.0));
			CGContextRef tempContext = UIGraphicsGetCurrentContext();
			CGContextSaveGState(tempContext);
			CGContextTranslateCTM(UIGraphicsGetCurrentContext(), center.x-size.height/2.0, center.y+size.width/2.0);
			CGContextRotateCTM(UIGraphicsGetCurrentContext(), -M_PI/2.0);
			CGContextSetFillColorWithColor(tempContext, colorWhite);						// to counteract CGContextSetFillColorSpace and CGContextSetFillPattern
			CGContextFillRect(tempContext, CGRectMake(0, 0, size.width, size.height));
			CGContextSetFillColorWithColor(tempContext, colorBlack);						// to counteract CGContextSetFillColorSpace and CGContextSetFillPattern
			[labelText drawAtPoint:CGPointZero withFont:font];
			CGContextRestoreGState(tempContext);
			// end temporary graphics context
			if (sectionIndex < self.activeDocument.sectionLabels.count) {
				if ((stratumTop > pageTop || stratum.hasPageCutter) && stratumSectionUpper > [self.activeDocument.strata indexOfObject:stratum]) {	// will continue label in next column
					stratumSectionLower = [self.activeDocument.strata indexOfObject:stratum];
				} else {																	// next label
					stratumSectionLower = stratumSectionUpper + 1;
					stratumSectionUpper = stratumSectionLower + ((SectionLabel *)self.activeDocument.sectionLabels[sectionIndex]).numberOfStrataSpanned-1;
				}
			} else
				stratumSectionUpper = -1;													// disable further stratum section labels
		}
		if (stratumTop > pageTop || stratum.hasPageCutter) {								// reached top of column, need to start a new column
			stratumRect = CGRectOffset(stratumRect, -offset.x, -offset.y);					// undo the offset from current column
			offset.x -= [maxWidths[++columnIndex] floatValue]+self.activeDocument.pageMargins.width;	// horizontal adjustment using maxwidth, and adding horizontal page margin
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
		if (stratum.outline == nil) {														// no outline, treat it as a rectangle
			stratumRect = [self RectUtoV:stratumRect];										// convert to view coordinates
			CGContextFillRect(currentContext, stratumRect);
			CGContextStrokeRect(currentContext, stratumRect);
		} else {																			// has an outline
			CGContextSaveGState(currentContext);
			CGContextSetFillPattern(currentContext, pattern, &alpha);
			CGContextSetLineWidth(currentContext, self.activeDocument.lineThickness);
			CGContextSetStrokeColorWithColor(currentContext, colorBlack);
			// draw left boundary, before setting clipping path
			CGContextMoveToPoint(currentContext, VX(offset.x+stratum.frame.origin.x/scale), VY(offset.y+stratum.frame.origin.y/scale));
			CGContextAddLineToPoint(currentContext, VX(offset.x+stratum.frame.origin.x/scale), VY(offset.y+(stratum.frame.origin.y+stratum.frame.size.height)/scale));
			CGContextStrokePath(currentContext);
			// set clipping rectangle
			CGContextBeginPath(currentContext);
			// it's larger than the stratum boundary
			CGContextAddRect(currentContext, CGRectMake(VX(offset.x+stratum.frame.origin.x/scale), VY(offset.y+(stratum.frame.origin.y-kPencilMargin)/scale), VDX((stratum.frame.size.width+kPencilMargin)/scale), VDY((stratum.frame.size.height+2*kPencilMargin)/scale)));
			CGContextClip(currentContext);
			[self addOutline:stratum offset:offset];
			CGContextDrawPath(currentContext, kCGPathFillStroke);							// fills and strokes path
			CGContextRestoreGState(currentContext);
		}
	}
	if (self.mode == PDFMode) {
		UIGraphicsEndPDFContext();
		self.mode = graphMode;
	}
	CFRelease(colorWhite);
	CFRelease(colorBlack);
}

- (void)addOutline:(Stratum *)stratum offset:(CGPoint)offset
{
	float scale = self.activeDocument.scale;
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(currentContext, self.activeDocument.lineThickness);
	NSMutableArray *controlPoints = [StrataView populateControlPoints:stratum];
	CGMutablePathRef mPath = CGPathCreateMutable();
	CGPoint point;
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[0]), &point);
	CGPathMoveToPoint(mPath, NULL, VX(offset.x+(point.x+stratum.frame.origin.x)/scale), VY(offset.y+(point.y+stratum.frame.origin.y)/scale));
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[1]), &point);
	CGPoint cPoint;
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[0]), &cPoint);
	// first and last curves have only a single control point
	CGPathAddQuadCurveToPoint(mPath, NULL, VX(offset.x+(cPoint.x+stratum.frame.origin.x)/scale), VY(offset.y+(cPoint.y+stratum.frame.origin.y)/scale), VX(offset.x+(point.x+stratum.frame.origin.x)/scale), VY(offset.y+(point.y+stratum.frame.origin.y)/scale));
	int cpIndex = 1;
	for (int index = 2; index < stratum.outline.count-3; ++index) {
		CGPoint cPoint1, cPoint2;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[index]), &point);
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[cpIndex++]), &cPoint1);
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[cpIndex++]), &cPoint2);
		// grab the next pair of control points and use them for the next curve
		CGPathAddCurveToPoint(mPath, NULL, VX(offset.x+(cPoint1.x+stratum.frame.origin.x)/scale), VY(offset.y+(cPoint1.y+stratum.frame.origin.y)/scale), VX(offset.x+(cPoint2.x+stratum.frame.origin.x)/scale), VY(offset.y+(cPoint2.y+stratum.frame.origin.y)/scale), VX(offset.x+(point.x+stratum.frame.origin.x)/scale), VY(offset.y+(point.y+stratum.frame.origin.y)/scale));
	}
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[cpIndex]), &cPoint);
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([stratum.outline lastObject]), &point);
	// last curve again has a single control point
	CGPathAddQuadCurveToPoint(mPath, NULL, VX(offset.x+(cPoint.x+stratum.frame.origin.x)/scale), VY(offset.y+(cPoint.y+stratum.frame.origin.y)/scale), VX(offset.x+(point.x+stratum.frame.origin.x)/scale), VY(offset.y+(point.y+stratum.frame.origin.y)/scale));
	CGPathCloseSubpath(mPath);
	CGContextAddPath(currentContext, mPath);
	CGPathRelease(mPath);
}

@end

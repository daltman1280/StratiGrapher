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

@implementation StrataPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setActiveDocument:(StrataDocument *)activeDocument
{
	_activeDocument = activeDocument;
	self.bounds = CGRectMake(0, 0, self.activeDocument.pageDimension.width*PPI, self.activeDocument.pageDimension.height*PPI);
}

- (void)drawRect:(CGRect)rect
{
#if 0
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGFloat colorComponents[4] = {0, 0, 0, 1.};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef color = CGColorCreate(colorSpace, colorComponents);
	CGContextSetStrokeColorWithColor(currentContext, color);
	CFRelease(color);
	CFRelease(colorSpace);
	// draw page boundaries
	CGContextSetLineWidth(currentContext, 3);
	CGContextStrokeRect(currentContext, self.bounds);
	// draw strata
	CGContextSetLineWidth(currentContext, self.activeDocument.lineThickness);
	CGFloat maxWidth = 0;
	for (Stratum *stratum in self.activeDocument.strata)
		if (stratum.frame.size.width > maxWidth) maxWidth = stratum.frame.size.width;
	maxWidth /= self.activeDocument.scale;													//  maxWidth now in inches
	CGPoint columnOrigin = CGPointMake(self.activeDocument.pageDimension.width-self.activeDocument.pageMargins.width-maxWidth, self.activeDocument.pageMargins.height);
	// setup patterns
	struct CGPatternCallbacks patternCallbacks = {
		0, &patternDrawingCallback, 0
	};
	CGFloat alpha = 1;
	gPage = self.patternsPage;																// global variable used by pattern drawing callback
	// apparently, we need to do this in the current context, can't cache it
	CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
	CGContextSetFillColorSpace(currentContext, patternSpace);
	CGColorSpaceRelease(patternSpace);
	// setup graphic attributes for drawing strata rectangles
	CGContextSetLineWidth(currentContext, 1);
	colorSpace = CGColorSpaceCreateDeviceRGB();
	color = CGColorCreate(colorSpace, colorComponents);
	CGContextSetStrokeColorWithColor(currentContext, color);
	CFRelease(color);
	CFRelease(colorSpace);
	gScale = 1;
	for (Stratum *stratum in self.activeDocument.strata) {
		CGPatternRef pattern = CGPatternCreate(NULL, CGRectMake(0, 0, 54, 54), CGAffineTransformMakeScale(1., -1.), 54, 54, kCGPatternTilingConstantSpacing, YES, &patternCallbacks);
		CGContextSetFillPattern(currentContext, pattern, &alpha);
		gPatternNumber = stratum.materialNumber;											// global variables used by pattern drawing callback
		CGRect stratumRect = CGRectMake(VX(columnOrigin.x), VY(columnOrigin.y+stratum.frame.origin.y/self.activeDocument.scale), VDX(stratum.frame.size.width/self.activeDocument.scale), VDY(stratum.frame.size.height/self.activeDocument.scale));
		CGContextFillRect(currentContext, stratumRect);
		CGContextStrokeRect(currentContext, stratumRect);
	}
#endif
}

@end

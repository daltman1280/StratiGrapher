//
//  MaterialPatternView.m
//  Strata Recorder
//
//  Created by Don Altman on 11/15/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "MaterialPatternView.h"
#import "StrataView.h"																		// pattern drawing

@implementation MaterialPatternView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	// setup patterns
	struct CGPatternCallbacks patternCallbacks = {
		0, &patternDrawingCallback, 0
	};
	CGFloat alpha = 1;
	// apparently, we need to do this in the current context, can't cache it
	CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
	CGContextSetFillColorSpace(currentContext, patternSpace);
	CGColorSpaceRelease(patternSpace);
	// setup graphic attributes for drawing strata rectangles
	CGContextSetLineWidth(currentContext, 1);
	CGFloat colorComponents[4] = {0, 0, 0, 1.};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef color = CGColorCreate(colorSpace, colorComponents);
	CGContextSetStrokeColorWithColor(currentContext, color);
	CFRelease(colorSpace);
	CFRelease(color);
	CGPatternRef pattern = CGPatternCreate((void *)self.patternNumber, CGRectMake(0, 0, 54, 54), CGAffineTransformMakeScale(1., -1.), 54, 54, kCGPatternTilingConstantSpacing, YES, &patternCallbacks);
	CGContextSetFillPattern(currentContext, pattern, &alpha);
	gScale = 1;
	CGContextFillRect(currentContext, self.bounds);										// draw fill pattern
	CGContextStrokeRect(currentContext, self.bounds);									// draw boundary
}

@end

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
	float scale = (self.patternScale != 0) ? self.patternScale : 1;
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
	CGContextSetLineWidth(currentContext, 2);
	CGFloat colorComponents[4] = {0, 0, 0, 1.};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef color = CGColorCreate(colorSpace, colorComponents);
	CGContextSetStrokeColorWithColor(currentContext, color);
	CFRelease(colorSpace);
	CFRelease(color);
	CGPatternRef pattern = CGPatternCreate((void *)self.patternNumber, CGRectMake(1, 0, 53, 54), CGAffineTransformMakeScale(scale, -scale), 53, 54, kCGPatternTilingConstantSpacingMinimalDistortion, YES, &patternCallbacks);
	CGContextSetFillPattern(currentContext, pattern, &alpha);
	gScale = 1;
	CGContextFillRect(currentContext, self.bounds);										// draw fill pattern
	CGRect bounds = self.bounds;
	bounds.origin.x++;
	bounds.origin.y++;
	bounds.size.width -= 2;
	bounds.size.height -= 2;
	CGContextStrokeRect(currentContext, bounds);									// draw boundary
}

@end

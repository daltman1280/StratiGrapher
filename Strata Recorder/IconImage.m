//
//  IconImage.m
//  Strata Recorder
//
//  Created by Don Altman on 11/1/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#define XORIGIN .75												// distance in inches of origin from LL of view
#define YORIGIN .5												// distance in inches of origin from LL of view

#import "IconImage.h"
#import "Graphics.h"

@interface IconImage()

@property (nonatomic) CGPoint offset;	// offset of origin w respect to UL corner, in fraction of width
@property (nonatomic) UIImage *image;
@property (nonatomic) CGFloat width;	// width to display icon

@end

@implementation IconImage

//	designated initializer

- (id)initWithImageName:(NSString *)imageName offset:(CGPoint)offset width:(CGFloat)width viewBounds:(CGRect)bounds viewOrigin:(CGPoint)viewOrigin
{
	if (self = [super init]) {
		self.offset = offset;
		// scale and resample from image file
		UIImage *image = [UIImage imageNamed:imageName];
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, 0);
		[image drawInRect:CGRectMake(0, 0, width, width)];
		UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		self.image = scaledImage;
		self.width = width;
		self.imageName = imageName;
		self.bounds = bounds;									// must be updated whenever parent view's bounds change
		self.origin = viewOrigin;								// must be updated whenever parent view's bounds change
	}
	return self;
}

//	point in user coordinates

- (void)drawAtPoint:(CGPoint)point scale:(CGFloat)scale
{
	scale = 1;		// temporary: always display at this scale
	[self.image drawInRect:CGRectMake(VX(point.x)-self.offset.x*self.width, VY(point.y)-self.width+self.offset.y*self.width, self.width, self.width)];
}

- (void)drawAtPointWithRotation:(CGPoint)point scale:(CGFloat)scale rotation:(CGFloat)rotation
{
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(currentContext);
	CGContextTranslateCTM(currentContext, VX(point.x), VY(point.y));
	CGContextRotateCTM(currentContext, rotation);
	[self.image drawInRect:CGRectMake(-self.width/2.0, -self.width/2, self.width, self.width)];
	CGContextRestoreGState(currentContext);
}

@end

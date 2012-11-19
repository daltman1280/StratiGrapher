//
//  IconImage.m
//  Strata Recorder
//
//  Created by Don Altman on 11/1/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "IconImage.h"
#import "Graphics.h"

@interface IconImage()

@property (nonatomic) CGPoint offset;	// offset of origin w respect to UL corner, in fraction of width
@property (weak, nonatomic) UIImage *image;
@property (nonatomic) CGFloat width;	// width to display icon
@property CGRect bounds;

@end

@implementation IconImage

//	designated initializer

- (id)initWithImageName:(NSString *)imageName offset:(CGPoint)offset width:(CGFloat)width viewBounds:(CGRect)bounds
{
	if ([super init]) {
		self.offset = offset;
		self.image = [UIImage imageNamed:imageName];
		self.width = width;
		self.bounds = bounds;
	}
	return self;
}

//	point in user coordinates

- (void)drawAtPoint:(CGPoint)point scale:(CGFloat)scale
{
	scale = 1;		// temporary: always display at this scale
	[self.image drawInRect:CGRectMake(VX(point.x)-self.offset.x*self.width, VY(point.y)-self.width+self.offset.y*self.width, self.width, self.width)];
}

@end

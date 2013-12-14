//
//  IconImage.h
//  Strata Recorder
//
//  Created by Don Altman on 11/1/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconImage : NSObject

- (id)initWithImageName:(NSString *)imageName offset:(CGPoint)offset width:(CGFloat)width viewBounds:(CGRect)bounds viewOrigin:(CGPoint)viewOrigin;
- (void)drawAtPoint:(CGPoint)point scale:(CGFloat)scale inContext:(CGContextRef)context;
- (void)drawAtPointWithRotation:(CGPoint)point scale:(CGFloat)scale rotation:(CGFloat)rotation inContext:(CGContextRef)context;

// for graphics.h, since we don't have a view of our own, we cache our parent view's bounds and origin

@property CGRect				bounds;				// this must be updated whenever parent view's bounds change
@property CGPoint				origin;				// ditto. This is the distance, in user units, from the LL of view
@property BOOL					scalesWithZoom;		// when the zoom factor is changed, does its drawn size reflect the new zoom factor
@property NSString*				imageName;			// in case we need to resample it
@property (nonatomic) CGFloat	width;				// width to display icon

@end


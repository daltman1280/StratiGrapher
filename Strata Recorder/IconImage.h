//
//  IconImage.h
//  Strata Recorder
//
//  Created by Don Altman on 11/1/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconImage : NSObject

- (id)initWithImageName:(NSString *)imageName offset:(CGPoint)offset width:(CGFloat)width viewBounds:(CGRect)bounds;
- (void)drawAtPoint:(CGPoint)point scale:(CGFloat)scale;
- (void)drawAtPointWithRotation:(CGPoint)point scale:(CGFloat)scale rotation:(CGFloat)rotation;

@property CGRect bounds;				// this must be updated whenever parent view's bounds change

@end


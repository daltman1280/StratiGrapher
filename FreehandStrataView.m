//
//  FreehandStrataView.m
//  Strata Recorder
//
//  Created by daltman on 12/31/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "FreehandStrataView.h"

#define XORIGIN .75												// distance in inches of origin from LL of view
#define YORIGIN .5												// distance in inches of origin from LL of view

#import "Graphics.h"
#import "StrataNotifications.h"

@implementation FreehandStrataView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 initWithCoder and initWithFrame are not reliably called, so we call this from the view controller in its UIApplicationDidBecomeActiveNotification
 This is to be called once.
 */

- (void)initialize
{
	self.origin = CGPointMake(XORIGIN, YORIGIN);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleActiveDocumentSelectionChanged:) name:SRActiveDocumentSelectionChanged object:nil];
}

- (void)handleActiveDocumentSelectionChanged:(NSNotification *)notification
{
	self.activeDocument = [notification.userInfo objectForKey:@"activeDocument"];
}

- (void)setActiveDocument:(StrataDocument *)activeDocument
{
	_activeDocument = activeDocument;
}

//	return in user coordinates

- (CGPoint)getDragPoint:(UIEvent *)event
{
	CGPoint dragPoint = CGPointMake(UX([(UITouch *)[[event touchesForView:self] anyObject] locationInView:self].x),
									UY([(UITouch *)[[event touchesForView:self] anyObject] locationInView:self].y));
	return dragPoint;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

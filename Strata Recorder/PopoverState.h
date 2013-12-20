//
//  PopoverState.h
//  StratiGrapher
//
//  Created by daltman on 12/19/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopoverState;

static PopoverState *gState;

typedef enum {
	nonePopoverState,
	documentPopoverState,
	settingsPopoverState,
	stratumPopoverState
} popoverState;

@interface PopoverState : NSObject

+ (PopoverState *)defaultState;

@property popoverState currentState;

@end

//
//  PopoverState.m
//  StratiGrapher
//
//  Created by daltman on 12/19/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "PopoverState.h"

@implementation PopoverState

+ (PopoverState *)defaultState
{
	if (!gState) gState = [[PopoverState alloc] init];
	gState.currentState = nonePopoverState;
	return gState;
}

@end

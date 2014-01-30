//
//  StrataModelState.m
//  StratiGrapher
//
//  Created by daltman on 1/29/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import "StrataModelState.h"

static StrataModelState *gCurrentState = 0;

@implementation StrataModelState

+ (StrataModelState *)currentState {
	if (!gCurrentState)
		gCurrentState = [[StrataModelState alloc] init];
	return gCurrentState;
}

@end

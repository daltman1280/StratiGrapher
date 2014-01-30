//
//  StrataModelState.h
//  StratiGrapher
//
//  Created by daltman on 1/29/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StrataModelState : NSObject

@property BOOL					dirty;					// whether the model has been changed, to require Page views to be redrawn

+ (StrataModelState *)currentState;

@end

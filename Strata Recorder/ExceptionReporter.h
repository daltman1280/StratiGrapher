//
//  ExceptionReporter.h
//  StratiGrapher
//
//  Created by daltman on 3/5/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExceptionReporter : NSObject

@property BOOL hasLogged;										// keep track of whether any exceptions have been generated when terminating

+ (ExceptionReporter *)defaultReporter;
- (void)reportException:(NSException *)exception failure:(NSString *)failure;

@end

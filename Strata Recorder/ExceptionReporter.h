//
//  ExceptionReporter.h
//  StratiGrapher
//
//  Created by daltman on 3/5/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExceptionReporter : NSObject

+ (ExceptionReporter *)defaultReporter;
- (void)reportException:(NSException *)exception failure:(NSString *)failure;

@end

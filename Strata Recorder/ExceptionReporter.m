//
//  ExceptionReporter.m
//  StratiGrapher
//
//  Created by daltman on 3/5/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import "ExceptionReporter.h"
#import <Crashlytics/Crashlytics.h>

@implementation ExceptionReporter

+ (ExceptionReporter *)defaultReporter
{
	static ExceptionReporter *reporter;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		reporter = [[ExceptionReporter alloc] init];
		reporter.hasLogged = NO;
	});
	return reporter;
}

- (void)reportException:(NSException *)exception failure:(NSString *)failure
{
	self.hasLogged = YES;																	// force Crashlytics to report logs by crashing at termination
	CLSNSLog(@"exception %@, reason: %@", exception.name, exception.reason);
	CLSNSLog(@"%@", failure);
	CLSNSLog(@"call stack symbols %@", exception.callStackSymbols);
}

@end

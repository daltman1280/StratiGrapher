//
//  StrataAppDelegate.m
//  Strata Recorder
//
//  Created by Don Altman on 10/29/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "StrataAppDelegate.h"
#import "StrataNotifications.h"
#import "StrataModel.h"
#import "StrataModelState.h"
#import "StrataViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <Crashlytics/Crashlytics.h>


@implementation StrataAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	DBSession *dbSession = [[DBSession alloc] initWithAppKey:@"es8mm9m7zdulbpw" appSecret:@"xlp44xohqeyhh9g" root:kDBRootAppFolder];
	[DBSession setSharedSession:dbSession];
	if (![[DBSession sharedSession] isLinked])
		[[DBSession sharedSession] linkFromController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
	[StrataModelState currentState].dirty = YES;
	[Crashlytics startWithAPIKey:@"3a5d33a7fbf7ecf443588919477cd2b62d50cafa"];
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

/*
 Following two methods called successively when user taps home
 */

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[StrataDocument saveState];
	[StrataViewController handleEnterBackground];
}

/*
 Following two methods called successively when user reactivates after home
 */

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[StrataViewController handleEnterForeground];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
	return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
	return YES;
}

@end

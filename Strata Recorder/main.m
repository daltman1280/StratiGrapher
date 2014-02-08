//
//  main.m
//  Strata Recorder
//
//  Created by Don Altman on 10/29/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StrataAppDelegate.h"

@interface StackItem : NSObject {
	NSNumber* _value;
}
@property NSNumber* value;
@end

@implementation StackItem

- (id)initWithValue:(int)value
{
	if (self = [super init])
		_value = [NSNumber numberWithInteger:value];
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<stackItem value = %d>\n", [self.value integerValue]];
}

@end

/*
 A simple-minded way to implement a stack
 */

@interface Stack : NSObject {
	NSMutableArray *stackArray;
}

- (void)push:(StackItem *)item;
- (StackItem *)pop;
- (StackItem *)find:(int)index;

@end

@implementation Stack

- (id)init {
	if (self = [super init]) {
		stackArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSString *)description
{
	NSMutableString *s = [[NSMutableString alloc] init];
	for (StackItem *item in stackArray)
		[s appendString:[item description]];
	return s;
}

- (void)push:(StackItem *)item
{
	[stackArray addObject:item];
}

- (StackItem *)pop
{
	if (stackArray.count > 0) {
		StackItem *item = [stackArray lastObject];
		[stackArray removeLastObject];
		return item;
	}
	return nil;
}

//	Recursive stack iterator that returns the stack to its original state

- (StackItem *)find:(int)index
{
	StackItem *item, *temp = [self pop];							// always do a pop on entry
	if (!temp) return nil;											// no more items to compare, return nil, to indicate "not found", and back out of recursion
	if ([temp.value integerValue] != index)							// is this what we're looking for?
		item = [self find:index];									// normal (failure) case, recursive call, obtaining result
	[self push:temp];												// always push item we popped locally, after the recursive call
	return ([temp.value integerValue] == index) ? temp : item;		// return result of recursive call, or item we popped locally (depending on results of comparison)
}

@end

void stackDemo()
{
	Stack *stack = [[Stack alloc] init];
	StackItem *item1 = [[StackItem alloc] initWithValue:1];
	[stack push:item1];
	StackItem *item2 = [[StackItem alloc] initWithValue:2];
	[stack push:item2];
	StackItem *item3 = [[StackItem alloc] initWithValue:3];
	[stack push:item3];
	StackItem *item4 = [[StackItem alloc] initWithValue:4];
	[stack push:item4];
	StackItem *item5 = [[StackItem alloc] initWithValue:5];
	[stack push:item5];
	StackItem *item6 = [[StackItem alloc] initWithValue:6];
	[stack push:item6];
	NSLog(@"original = %@", stack);
	NSLog(@"found = %@", [stack find:3]);
	NSLog(@"found = %@", [stack find:7]);
	NSLog(@"processed = %@", stack);
}

int main(int argc, char *argv[])
{
	@autoreleasepool {
#if 0	// sample code
		char *cString = "abcdefghijklmno";
		char string[50];
		strcpy(string, cString);
		// reverse string
		for (char *s=string, *t=string+strlen(string)-1; s<=string+strlen(string)/2; ++s, --t) {
			char temp = *s;
			*s = *t;
			*t = temp;
		}
		char *pString = "abcdefghijklmnopqrstuvwxyz";
		strcpy(string, pString);
		// copy string
		char *source = string+8;
		char *dest = string+10;
		int len = 5;
		if (dest > source) {
			for (char *s=source+len-1, *t=dest+len-1; s-source>=0; --s, --t)
				*t = *s;
		} else {
			for (char *s=source, *t=dest; s-source<len; ++s, ++t)
				*t = *s;
		}
#endif
#if 0
		stackDemo();
#endif
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([StrataAppDelegate class]));
	}
}

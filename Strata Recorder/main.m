//
//  main.m
//  Strata Recorder
//
//  Created by Don Altman on 10/29/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StrataAppDelegate.h"

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
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([StrataAppDelegate class]));
	}
}

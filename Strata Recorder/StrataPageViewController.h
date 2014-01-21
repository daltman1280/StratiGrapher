//
//  StrataPageViewController.h
//  StratiGrapher
//
//  Created by daltman on 1/4/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataPageView.h"

@interface StrataPageViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource> {
	int _pageIndex;
}

@property int				pageIndex;
@property StrataPageView*	strataPageView;
@property UIScrollView*		strataMultiPageScrollView;

#if 0
- (id)initWithEnclosingScrollView:(UIScrollView *)enclosingScrollView;
#endif

@end

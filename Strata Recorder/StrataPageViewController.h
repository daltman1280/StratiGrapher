//
//  StrataPageViewController.h
//  StratiGrapher
//
//  Created by daltman on 1/4/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataPageView.h"
#import "ContainerPageViewController.h"

@interface StrataPageViewController : UIViewController <UIScrollViewDelegate> {
	int _pageIndex;
	ContainerPageViewController* _parent;
}

@property (nonatomic) int									pageIndex;
@property int												maxPages;
@property (strong, nonatomic) IBOutlet StrataPageView*		strataPageView;
@property (strong, nonatomic) IBOutlet UIScrollView*		strataPageScrollView;
@property (nonatomic) ContainerPageViewController*			parent;

@end

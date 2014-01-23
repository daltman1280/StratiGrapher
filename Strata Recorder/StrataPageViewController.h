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

@interface StrataPageViewController : UIViewController {
	int _pageIndex;
	ContainerPageViewController* _parent;
}

@property (nonatomic) int									pageIndex;
@property int												maxPages;
@property (strong, nonatomic) IBOutlet StrataPageView*		strataPageView;
@property (weak, nonatomic) IBOutlet UIScrollView*			strataPageScrollView;
@property UIScrollView*										strataMultiPageScrollView;
@property (nonatomic) ContainerPageViewController*			parent;

@end

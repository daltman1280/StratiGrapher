//
//  ContainerPageViewController.h
//  StratiGrapher
//
//  Created by daltman on 1/16/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LegendView.h"

@interface ContainerPageViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property NSMutableArray*			patternsPageArray;
@property (strong, nonatomic) LegendView*		legendView;
//	view content to help drawing column adornments

@property (strong, nonatomic) UILabel*			columnNumber;
@property (strong, nonatomic) UILabel*			grainSizeLegend;
@property (strong, nonatomic) UIView*			strataColumn;
@property (strong, nonatomic) UILabel*			grainSizeLines;
@property StrataDocument*						activeDocument;

@property (strong) UIPageControl*				pageControl;
@property int									maxPages;
@end

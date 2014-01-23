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
@property (weak, nonatomic) LegendView*			legendView;
//	view content to help drawing column adornments

@property (weak, nonatomic) UILabel*			columnNumber;
@property (weak, nonatomic) UILabel*			grainSizeLegend;
@property (weak, nonatomic) UIView*				strataColumn;
@property (weak, nonatomic) UILabel*			grainSizeLines;
@property StrataDocument*						activeDocument;

@property (weak) UIPageControl*					pageControl;
@property int									maxPages;
@end

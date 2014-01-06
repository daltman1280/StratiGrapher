//
//  StrataPageViewController.m
//  StratiGrapher
//
//  Created by daltman on 1/4/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import "StrataPageViewController.h"

@interface StrataPageViewController ()

@property UIScrollView*			strataPageScrollView;

@end

@implementation StrataPageViewController

- (void)awakeFromNib
{
}

- (id)initWithEnclosingScrollView:(UIScrollView *)enclosingScrollView
{
	self = [super init];
	if (self) {
		self.strataPageView = [[StrataPageView alloc] initWithFrame:self.view.bounds];
		NSLog(@"self.view = %@, %s, class = %@", self.view, object_getClassName(self.view), [self.view class]);
//		self.strataPageView = (StrataPageView *)self.view;
//		self.view = self.strataPageView;
		self.strataPageView.backgroundColor = [UIColor whiteColor];
		self.strataMultiPageScrollView = enclosingScrollView;
		self.strataPageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
		NSLog(@"StrataPageViewController, initWithEnclosingScrollView, self.stratapagescrollview = %s, class = %@, item = %@", object_getClassName(self.strataPageScrollView), [self.strataPageScrollView class], self.strataPageScrollView);
//		self.view = self.strataPageView;
		self.strataPageScrollView.delegate = self;
		self.strataPageScrollView.contentSize = self.view.bounds.size;
		self.strataPageScrollView.contentOffset = CGPointZero;
		self.strataPageScrollView.minimumZoomScale = 1;
		self.strataPageScrollView.maximumZoomScale = 2;
		self.strataPageScrollView.multipleTouchEnabled = YES;
		self.strataPageScrollView.backgroundColor = [UIColor blueColor];
		[self.strataPageScrollView addSubview:self.strataPageView];
		[self.strataMultiPageScrollView addSubview:self.strataPageScrollView];
		self.strataMultiPageScrollView.contentSize = self.view.bounds.size;
	}
	return self;
}

- (void)setPageIndex:(int)pageIndex
{
	_pageIndex = pageIndex;
	[self.strataPageView setupPages];
	self.strataPageView.pageIndex = pageIndex;
	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width)/2.0, 0);
	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height)/2.0, 0);
	NSLog(@"verticalInset = %f, horizontalInset = %f", verticalInset, horizontalInset);
	self.strataPageScrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

- (int)pageIndex
{
	return self.pageIndex;
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
	NSLog(@"StrataPageViewController viewForZoomingInScrollView, sender = %@", sender);
	return self.strataPageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	NSLog(@"scrollViewDidEndZooming");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	NSLog(@"scrollViewDidScroll");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

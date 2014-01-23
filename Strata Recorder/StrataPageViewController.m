//
//  StrataPageViewController.m
//  StratiGrapher
//
//  Created by daltman on 1/4/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import "StrataPageViewController.h"

@interface StrataPageViewController ()

@end

@implementation StrataPageViewController

- (void)awakeFromNib
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//	self.strataPageView = (StrataPageView *) self.view;
	if (self.parent) {
		self.strataPageView.patternsPageArray = self.parent.patternsPageArray;
		self.strataPageView.legendView = self.parent.legendView;
		self.strataPageView.columnNumber = self.parent.columnNumber;
		self.strataPageView.grainSizeLegend = self.parent.grainSizeLegend;
		self.strataPageView.grainSizeLines = self.parent.grainSizeLines;
		self.strataPageView.strataColumn = self.parent.strataColumn;
		self.strataPageView.activeDocument = self.parent.activeDocument;						// updates bounds
		[self.strataPageView setupPages];
		self.maxPages = self.strataPageView.maxPageIndex+1;
		self.strataPageView.pageIndex = _pageIndex;
		// UIScrollView setup
		self.strataPageScrollView.contentSize = self.view.bounds.size;
		self.strataPageScrollView.contentOffset = CGPointZero;
		float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width*self.strataPageScrollView.zoomScale)/2.0, 0);
		float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height*self.strataPageScrollView.zoomScale)/2.0, 0);
		NSLog(@"viewDidLoad, horizontalInset = %f, verticalInset = %f", horizontalInset, verticalInset);
		self.strataPageScrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
	}
}

- (void)setParent:(ContainerPageViewController *)parent
{
	_parent = parent;
	if (self.strataPageView) {
		self.strataPageView.patternsPageArray = self.parent.patternsPageArray;
		self.strataPageView.legendView = self.parent.legendView;
		self.strataPageView.columnNumber = self.parent.columnNumber;
		self.strataPageView.grainSizeLegend = self.parent.grainSizeLegend;
		self.strataPageView.grainSizeLines = self.parent.grainSizeLines;
		self.strataPageView.strataColumn = self.parent.strataColumn;
		self.strataPageView.activeDocument = self.parent.activeDocument;						// updates bounds
		[self.strataPageView setupPages];
		self.maxPages = self.strataPageView.maxPageIndex+1;
		self.strataPageView.pageIndex = _pageIndex;
		// UIScrollView setup
		self.strataPageScrollView.contentSize = self.view.bounds.size;
		self.strataPageScrollView.contentOffset = CGPointZero;
		float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width*self.strataPageScrollView.zoomScale)/2.0, 0);
		float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height*self.strataPageScrollView.zoomScale)/2.0, 0);
		NSLog(@"setParent, horizontalInset = %f, verticalInset = %f", horizontalInset, verticalInset);
		self.strataPageScrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
	}
}

- (void)setPageIndex:(int)pageIndex
{
	_pageIndex = pageIndex;
	self.strataPageView.pageIndex = pageIndex;
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
	return self.strataPageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width*self.strataPageScrollView.zoomScale)/2.0, 0);
	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height*self.strataPageScrollView.zoomScale)/2.0, 0);
	NSLog(@"scrollViewDidEndZooming, horizontalInset = %f, verticalInset = %f", horizontalInset, verticalInset);
	self.strataPageScrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	[self setStrataPageScrollView:nil];
	[self setStrataPageScrollView:nil];
	[self setStrataPageView:nil];
	[super viewDidUnload];
}
@end

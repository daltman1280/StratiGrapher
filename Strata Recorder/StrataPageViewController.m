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
		self.strataPageView.activeDocument = self.parent.activeDocument;
		[self.strataPageView setupPages];
		self.maxPages = self.strataPageView.maxPageIndex+1;
		self.strataPageView.pageIndex = _pageIndex;
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
		self.strataPageView.activeDocument = self.parent.activeDocument;
		[self.strataPageView setupPages];
		self.maxPages = self.strataPageView.maxPageIndex+1;
		self.strataPageView.pageIndex = _pageIndex;
	}
}

- (void)setPageIndex:(int)pageIndex
{
	_pageIndex = pageIndex;
	self.strataPageView.pageIndex = pageIndex;
}

#if 0			// make this part of initialization
- (id)initWithEnclosingScrollView:(UIScrollView *)enclosingScrollView
{
	self = [super init];
	if (self) {
		self.strataPageView = [[StrataPageView alloc] initWithFrame:self.view.bounds];
		NSLog(@"initWithEnclosingScrollView view = %@", [self.view class]);
		self.strataPageView.backgroundColor = [UIColor whiteColor];
		self.strataMultiPageScrollView = enclosingScrollView;
		self.strataPageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
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

#if 0
- (void)setPageIndex:(int)pageIndex
{
	_pageIndex = pageIndex;
	[self.strataPageView setupPages];
	self.strataPageView.pageIndex = pageIndex;
//	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width)/2.0, 0);
//	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height)/2.0, 0);
	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width*self.strataPageScrollView.zoomScale)/2.0, 0);
	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height*self.strataPageScrollView.zoomScale)/2.0, 0);
	self.strataPageScrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

- (int)pageIndex
{
	return self.pageIndex;
}
#endif

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
	return self.strataPageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
//	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width)/2.0, 0);
//	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height)/2.0, 0);
	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width*self.strataPageScrollView.zoomScale)/2.0, 0);
	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height*self.strataPageScrollView.zoomScale)/2.0, 0);
	self.strataPageScrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}
#endif

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

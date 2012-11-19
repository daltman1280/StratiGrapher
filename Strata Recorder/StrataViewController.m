//
//  StrataViewController.m
//  Strata Recorder
//
//  Created by Don Altman on 10/29/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "StrataViewController.h"
#import "StrataView.h"
#import "StratumMaterialsTableController.h"
#import "StrataPageView.h"
#import "StrataModel.h"

@interface StrataViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet StrataView *strataView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dimensionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *strataGraphScrollView;
@property UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIScrollView *strataPageScrollView;
@property (weak, nonatomic) IBOutlet StrataPageView *strataPageView;

@end

@implementation StrataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.scrollView.contentSize = self.strataView.bounds.size;
	self.scrollView.contentOffset = CGPointMake(0, self.strataView.bounds.size.height-self.scrollView.bounds.size.height);
	self.strataView.scale = self.scrollView.zoomScale;
	self.strataView.locationLabel = self.locationLabel;
	self.strataView.dimensionLabel = self.dimensionLabel;
	self.strataView.delegate = self;
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"patterns1" withExtension:@"pdf"];
	CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)(url));
	CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
	self.strataView.patternsPage = page;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationResigning:) name:@"applicationResigning" object:nil];
}

- (void)handleApplicationResigning:(id)sender
{
	[self.strataView.activeDocument save];
}

- (IBAction)handleModeSwitch:(id)sender {
	int selection = [(UISegmentedControl *)sender selectedSegmentIndex];
	if (selection == 1) {																						// switching to page mode
		[self.strataView resignFirstResponder];
//		[self.strataPageScrollView invalidate];
		[UIView beginAnimations:@"GraphToPageTransition" context:nil];
		[UIView setAnimationDuration:0.5];
		self.strataGraphScrollView.alpha = 0.0;
		self.strataPageScrollView.alpha = 1.0;
		[UIView commitAnimations];
	} else {																									// switching to graph mode
		[UIView beginAnimations:@"PageToGraphTransition" context:nil];
		[UIView setAnimationDuration:0.5];
		self.strataGraphScrollView.alpha = 1.0;
		self.strataPageScrollView.alpha = 0.0;
		[UIView commitAnimations];
	}
}

/*
 Create a popover which contains a navigation controller, containing a table controller for managing the material number
 */

- (void)handleStratumInfo:(id)sender
{
	// get the UITableController and initialize its properties, so it can manage the properties of the selected stratum
	UINavigationController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StratumInfoNavigationController"];
	StratumMaterialsTableController *tableController = viewController.viewControllers[0];
	tableController.stratum = ((StrataView *)sender).selectedStratum;											// tell the table controller what stratum is selected
	tableController.patternsPage = ((StrataView *)sender).patternsPage;											// give it the page of patterns
	tableController.delegate = self;
	self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
	[self.popover setPopoverContentSize:CGSizeMake(380, 500)];
	[self.popover presentPopoverFromRect:CGRectMake(self.strataView.infoSelectionPoint.x, self.strataView.infoSelectionPoint.y, 1, 1) inView:self.strataView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)dismissPopoverContainer:(id)sender
{
	[self.popover dismissPopoverAnimated:YES];
	[self.strataView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
	return self.strataView;
}

#if 0
//	continuous, if we want to continuously vary the drawn detail
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	NSLog(@"scrollViewDidZoom");
	[self.strataView setNeedsDisplay];
}
#endif

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	self.strataView.scale = self.scrollView.zoomScale;
	[self.strataView setNeedsDisplay];
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
	[self setLocationLabel:nil];
	[self setDimensionLabel:nil];
    [self setGraphPageToggle:nil];
	[self setToolbar:nil];
	[self setStrataPageScrollView:nil];
	[self setStrataPageView:nil];
	[self setStrataGraphScrollView:nil];
	[super viewDidUnload];
}
@end

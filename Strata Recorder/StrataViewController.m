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
#import "DocumentListTableViewController.h"
#import "SettingsTableController.h"
#import "StrataNotifications.h"
#import "Graphics.h"

@interface StrataViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet StrataView *strataView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dimensionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *strataGraphScrollView;
@property UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIScrollView *strataPageScrollView;
@property (weak, nonatomic) IBOutlet StrataPageView *strataPageView;
@property StrataDocument *activeDocument;
@property (weak, nonatomic) IBOutlet StrataPageView *renameDialog;
@property (weak, nonatomic) IBOutlet UITextField *renameText;
@property (weak, nonatomic) IBOutlet UIButton *renameOKButton;
@property (weak, nonatomic) IBOutlet UIButton *renameCancelButton;
@property UINavigationController* stratumMaterialsNavigationController;
@property StratumMaterialsTableController* stratumMaterialsTableController;
@property SettingsTableController* settingsTableController;
@property (weak, nonatomic) IBOutlet UIImageView *scissorsIcon;

@end

@implementation StrataViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"documents"])
		((DocumentListTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController).delegate = self;			// set up ourselves as delegate
	else if ([segue.identifier isEqualToString:@"settings"]) {
		UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
		self.settingsTableController = ((SettingsTableController *)((UINavigationController *)segue.destinationViewController).topViewController);
		self.settingsTableController.delegate = self;																								// set up ourselves as delegate
		self.settingsTableController.activeDocument = self.activeDocument;
		self.popover = popoverSegue.popoverController;																								// so we can dismiss the popover
	} else
		NSAssert1(NO, @"Unexpected segue, ID = %@", segue.identifier);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// settings from user preferences
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"activeDocument"])
		self.activeDocument = [StrataDocument loadFromFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"activeDocument"]];
	else {
		self.activeDocument = [[StrataDocument alloc] init];
	}
	if (!self.activeDocument)
		self.activeDocument = [[StrataDocument alloc] init];
	CGRect frame = CGRectMake(0, 0, self.strataView.frame.size.width, self.activeDocument.strataHeight*PPI);
	self.strataView.frame = frame;														// modifying bounds would affect frame origin
	self.toolbarTitle.title = self.activeDocument.name;
	self.strataView.activeDocument = self.activeDocument;
	self.scrollView.contentSize = self.strataView.bounds.size;
	self.scrollView.contentOffset = CGPointMake(0, self.strataView.bounds.size.height-self.scrollView.bounds.size.height);
	self.strataView.scale = self.scrollView.zoomScale;
	self.strataView.locationLabel = self.locationLabel;
	self.strataView.dimensionLabel = self.dimensionLabel;
	self.strataView.delegate = self;
	
	self.strataPageView.activeDocument = self.activeDocument;
	self.strataPageScrollView.contentSize = self.strataPageView.bounds.size;
	self.strataPageScrollView.contentOffset = CGPointMake(0, self.strataPageView.bounds.size.height-self.strataPageScrollView.bounds.size.height);
	self.strataPageScrollView.hidden = YES;
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"patterns1 multipage" withExtension:@"pdf"];
	CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)(url));
	CGPDFPageRef page;
	self.strataView.patternsPageArray = [[NSMutableArray alloc] init];
	for (int i=1; i<=28; ++i) {
		page = CGPDFDocumentGetPage(document, i);
		[self.strataView.patternsPageArray addObject:[NSValue valueWithPointer:page]];
		CFRetain(page);
	}
	CGPDFDocumentRelease(document);
	self.strataPageView.patternsPageArray = self.strataView.patternsPageArray;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationEnteredBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationBecameActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStrataHeightChanged:) name:SRStrataHeightChangedNotification object:nil];
}

- (void)handleApplicationBecameActive:(id)sender
{
	[self.strataView initialize];
}

- (void)handleStrataHeightChanged:(id)sender
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"strataHeight"]) {
		CGRect frame = CGRectMake(0, 0, self.strataView.frame.size.width, [[[NSUserDefaults standardUserDefaults] objectForKey:@"strataHeight"] floatValue]*PPI);
		self.strataView.frame = frame;														// modifying bounds would affect frame origin
		self.strataView.bounds = frame;
	}
	self.scrollView.contentSize = self.strataView.bounds.size;
	[self.strataView handleStrataHeightChanged:self];
	[self.scrollView setNeedsDisplay];														// TODO: unsuccessful at displaying new view height
	[self.strataView setNeedsDisplay];
}

- (void)handleApplicationEnteredBackground:(id)sender
{
	[self.strataView.activeDocument save];
	[[NSUserDefaults standardUserDefaults] setObject:self.activeDocument.name forKey:@"activeDocument"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)handleModeSwitch:(id)sender {
	int selection = [(UISegmentedControl *)sender selectedSegmentIndex];
	if (selection == 1) {																						// switching to page mode
		[self.strataView resignFirstResponder];
		self.strataPageScrollView.hidden = NO;
		[UIView beginAnimations:@"GraphToPageTransition" context:nil];
		[UIView setAnimationDuration:0.5];
		self.strataGraphScrollView.alpha = 0.0;
		self.strataPageScrollView.alpha = 1.0;
		[UIView commitAnimations];
		[self.strataPageView setNeedsDisplay];
	} else {																									// switching to graph mode
		self.strataPageScrollView.hidden = YES;
		[UIView beginAnimations:@"PageToGraphTransition" context:nil];
		[UIView setAnimationDuration:0.5];
		self.strataGraphScrollView.alpha = 1.0;
		self.strataPageScrollView.alpha = 0.0;
		[UIView commitAnimations];
	}
}

#pragma mark strata info popover

/*
 Create a popover which contains a navigation controller, containing a table controller for managing the material number
 */

- (void)handleStratumInfo:(id)sender
{
	// get the UITableController and initialize its properties, so it can manage the properties of the selected stratum
	self.stratumMaterialsNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"StratumInfoNavigationController"];
	self.stratumMaterialsTableController = self.stratumMaterialsNavigationController.viewControllers[0];
	self.stratumMaterialsTableController.stratum = ((StrataView *)sender).selectedStratum;					// tell the table controller what stratum is selected
	self.stratumMaterialsTableController.delegate = self;
	self.popover = [[UIPopoverController alloc] initWithContentViewController:self.stratumMaterialsNavigationController];
	[self.popover setPopoverContentSize:CGSizeMake(380, 500)];
	[self.popover presentPopoverFromRect:CGRectMake(self.strataView.infoSelectionPoint.x, self.strataView.infoSelectionPoint.y, 1, 1) inView:self.strataView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)handleStratumInfoComplete:(id)sender
{
	[self.popover dismissPopoverAnimated:YES];
	[self.strataView setNeedsDisplay];
}

#pragma mark SettingsControllerDelegate

- (void)handleSettingsTableComplete:(id)sender;
{
	[self.popover dismissPopoverAnimated:YES];
	if ([((UIBarButtonItem *)sender).title isEqualToString:@"Save"]) {
		self.activeDocument.pageDimension = CGSizeMake(self.settingsTableController.paperWidth, self.settingsTableController.paperHeight);
		self.activeDocument.pageMargins = CGSizeMake(self.settingsTableController.marginWidth, self.settingsTableController.marginHeight);
		self.activeDocument.scale = self.settingsTableController.pageScale;
		self.activeDocument.lineThickness = self.settingsTableController.lineThickness;
		self.activeDocument.units = self.settingsTableController.units;
		self.activeDocument.strataHeight = self.settingsTableController.strataHeight;
	}
}

#pragma mark DocumentListControllerDelegate

- (void)handleExportPDFButton:(id)sender
{
	[self.strataPageView setNeedsDisplayInRect:self.strataPageView.bounds];
	self.strataPageView.mode = PDFMode;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
	if (sender == self.scrollView)
		return self.strataView;
	else
		return self.strataPageView;
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
	[self setTitle:nil];
	[self setTitle:nil];
	[self setToolbarTitle:nil];
	[self setRenameDialog:nil];
	[self setRenameText:nil];
	[self setRenameOKButton:nil];
	[self setRenameCancelButton:nil];
	[self setScissorsIcon:nil];
	[super viewDidUnload];
}
@end

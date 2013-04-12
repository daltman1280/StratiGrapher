//
//  StrataViewController.m
//  Strata Recorder
//
//  Created by Don Altman on 10/29/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#define XORIGIN .75												// distance in inches of origin from LL of view
#define YORIGIN .5												// distance in inches of origin from LL of view

#import "StrataViewController.h"
#import "StrataView.h"
#import "StratumMaterialsTableController.h"
#import "StrataPageView.h"
#import "StrataModel.h"
#import "DocumentListTableViewController.h"
#import "SettingsTableController.h"
#import "StrataNotifications.h"
#import "Graphics.h"
#import "FreehandStrataView.h"

@interface StrataViewController () <UIScrollViewDelegate>

@property (nonatomic) IBOutlet StrataView *strataView;
@property (weak, nonatomic) IBOutlet FreehandStrataView *freehandView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dimensionLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *strataGraphScrollView;
@property UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIScrollView *strataPageScrollView;
@property (nonatomic) IBOutlet StrataPageView *strataPageView;
@property (nonatomic) StrataDocument *activeDocument;
@property UINavigationController* stratumMaterialsNavigationController;
@property StratumMaterialsTableController* stratumMaterialsTableController;
@property SettingsTableController* settingsTableController;
// tools
@property (weak, nonatomic) IBOutlet UIImageView *scissorsView;
@property (weak, nonatomic) IBOutlet UIImageView *anchorView;
@property (weak, nonatomic) IBOutlet UIImageView *paleoCurrentView;
// equivalent icons in main view, for dragging
@property (nonatomic) IBOutlet UIImageView *scissorsDragView;
@property (nonatomic) IBOutlet UIImageView *anchorDragView;
@property (nonatomic) IBOutlet UIImageView *paleoCurrentDragView;
// for graphics.h
@property CGRect bounds;
@property CGPoint origin;
// for rotating paleocurrent
@property PaleoCurrent *selectedPaleoCurrent;
@property Stratum *selectedPaleoCurrentStratum;
@property float paleoCurrentInitialRotation;
@end

@implementation StrataViewController

/*
 Look for a paleocurrent icon that's located at the rotation center, and change its rotation based on the gesture.
 */

- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint locationInView = [gestureRecognizer locationInView:self.strataView];				// in StrataView coordinates
		CGPoint userLocation = CGPointMake(UX(locationInView.x), UY(locationInView.y));				// in user coordinates
		for (Stratum *stratum in self.strataView.activeDocument.strata) {
			for (PaleoCurrent *paleo in stratum.paleoCurrents) {
				if (fabs(userLocation.x-(stratum.frame.size.width+paleo.origin.x)) < 0.25 && fabs(userLocation.y-(stratum.frame.origin.y+paleo.origin.y) < 0.25)) {
					self.selectedPaleoCurrent = paleo;
					self.paleoCurrentInitialRotation = paleo.rotation;
					self.selectedPaleoCurrent.rotation = self.paleoCurrentInitialRotation + gestureRecognizer.rotation;
					[self.strataView setNeedsDisplay];
				}
			}
		}
	} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
		if (self.selectedPaleoCurrent) {
			self.selectedPaleoCurrent.rotation = self.paleoCurrentInitialRotation + gestureRecognizer.rotation;
			[self.strataView setNeedsDisplay];
		}
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		if (self.selectedPaleoCurrent) self.selectedPaleoCurrent = nil;
	}
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
	/*
	 Handle drags that originate in tool area.
	 Drags of tools that have been placed in model have their drags handled in StrataView touchesBegan:withEvent:
	 */
	if (gestureRecognizer.view == self.scissorsView || gestureRecognizer.view == self.anchorView || gestureRecognizer.view == self.paleoCurrentView) {
		if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {     // beginning a pan of a tool, make a copy in the main view to start dragging it
			if (gestureRecognizer.view == self.scissorsView) {
				self.scissorsDragView.hidden = NO;
				self.scissorsDragView.center = [self.scissorsView.superview convertPoint:self.scissorsView.center toView:self.view];	// reposition the drag icon to coincide with the tool icon
			} else if (gestureRecognizer.view == self.anchorView) {
				self.anchorDragView.hidden = NO;
				self.anchorDragView.center = [self.anchorView.superview convertPoint:self.anchorView.center toView:self.view];			// reposition the drag icon to coincide with the tool icon
			} else if (gestureRecognizer.view == self.paleoCurrentView) {
				self.paleoCurrentDragView.hidden = NO;
				self.paleoCurrentDragView.center = [self.paleoCurrentView.superview convertPoint:self.paleoCurrentView.center toView:self.view];	// reposition the drag icon to coincide with the tool icon
			} else
				NSAssert1(NO, @"Unexpected view attached to gesture recognizer, view = %@", gestureRecognizer.view);
		} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
			if (gestureRecognizer.view == self.scissorsView) {
				CGPoint translation = [gestureRecognizer translationInView:[self.scissorsDragView superview]];
				[self.scissorsDragView setCenter:CGPointMake([self.scissorsDragView center].x + translation.x, [self.scissorsDragView center].y + translation.y)];
			} else if (gestureRecognizer.view == self.anchorView) {
				CGPoint translation = [gestureRecognizer translationInView:[self.anchorDragView superview]];
				[self.anchorDragView setCenter:CGPointMake([self.anchorDragView center].x + translation.x, [self.anchorDragView center].y + translation.y)];
			} else if (gestureRecognizer.view == self.paleoCurrentView) {
				CGPoint translation = [gestureRecognizer translationInView:[self.paleoCurrentDragView superview]];
				[self.paleoCurrentDragView setCenter:CGPointMake([self.paleoCurrentDragView center].x + translation.x, [self.paleoCurrentDragView center].y + translation.y)];
			} else
				NSAssert1(NO, @"Unexpected view attached to gesture recognizer, view = %@", gestureRecognizer.view);
			[gestureRecognizer setTranslation:CGPointZero inView:self.view];
        } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
			if (gestureRecognizer.view == self.scissorsView) {
				[self handlePlaceToolAtStratumOrigin:ToolScissors usingView:self.scissorsDragView originalView:self.scissorsView];
			} else if (gestureRecognizer.view == self.anchorView) {
				[self handlePlaceToolAtStratumOrigin:ToolAnchor usingView:self.anchorDragView originalView:self.anchorView];
			} else if (gestureRecognizer.view == self.paleoCurrentView) {
				[self handlePlaceToolAtStratumOrigin:ToolArrow usingView:self.paleoCurrentDragView originalView:self.paleoCurrentView];
			} else
				NSAssert1(NO, @"Unexpected view attached to gesture recognizer, view = %@", gestureRecognizer.view);
		}
    }
}

typedef enum {
	ToolScissors,
	ToolAnchor,
	ToolArrow
} toolTypeEnum;

- (void)handlePlaceToolAtStratumOrigin:(toolTypeEnum)toolType usingView:(UIView *)view originalView:(UIView *)originalView
{
	CGPoint dropPoint = [self.view convertPoint:view.center toView:self.strataView];
	CGPoint dropPointUser = CGPointMake(UX(dropPoint.x), UY(dropPoint.y));														// in user coordinates
	if (toolType != ToolArrow && dropPointUser.x > 0.5)
		[self putAwayTool:view toOriginalView:originalView];																	// discard if not near left gutter
	else if (toolType != ToolArrow) {
		float distance = HUGE;
		Stratum *closestStratum;
		for (Stratum *stratum in self.strataView.activeDocument.strata) {
			if (fabsf(dropPointUser.y-stratum.frame.origin.y) < distance) {
				distance = fabsf(dropPointUser.y-stratum.frame.origin.y);
				closestStratum = stratum;
			}
		}
		if (distance != HUGE) {
			if ([self.strataView.activeDocument.strata indexOfObject:closestStratum] == 0) {									// can't attach these to first stratum
				[self putAwayTool:view toOriginalView:originalView];
				return;
			}
			if (toolType == ToolScissors)
				closestStratum.hasPageCutter = YES;
			else
				closestStratum.hasAnchor = YES;
			float xOrigin = toolType == ToolScissors ? -0.25 : -0.5;						// TODO: parametrize X origin in animation with StrataView drawRect:
			[UIView animateWithDuration:0.25
							 animations:^{
								 CGPoint viewOrigin = CGPointMake(VX(xOrigin), VY(closestStratum.frame.origin.y));				// in strataView coordinates
								 CGPoint viewOriginDragView = [self.strataView convertPoint:viewOrigin toView:self.view];
								 view.center = viewOriginDragView;
							 }
							 completion:^(BOOL fin) { view.alpha = 1; view.hidden = YES; [self.strataView setNeedsDisplay]; }];
		}
	} else if (toolType == ToolArrow) {
		for (Stratum *stratum in self.strataView.activeDocument.strata) {
			if (dropPointUser.y >= stratum.frame.origin.y && dropPointUser.y <= stratum.frame.origin.y+stratum.frame.size.height) {
				if (dropPointUser.x > stratum.frame.size.width) {
					PaleoCurrent *paleoCurrent = [[PaleoCurrent alloc] init];
					paleoCurrent.rotation = 0;
					paleoCurrent.origin = CGPointMake(dropPointUser.x-stratum.frame.size.width, dropPointUser.y-stratum.frame.origin.y);	// relative to LR corner of stratum
					if (!stratum.paleoCurrents) stratum.paleoCurrents = [[NSMutableArray alloc] init];
					[stratum.paleoCurrents addObject:paleoCurrent];
					view.hidden = YES;
					[self.strataView setNeedsDisplay];
					return;
				} else {
					[self putAwayTool:view toOriginalView:originalView];														// paleocurrent must be placed to the right of the stratum
					return;
				}
			}
		}
	}
}

- (void)putAwayTool:(UIView *)view toOriginalView:(UIView *)originalView
{
	[UIView animateWithDuration:0.5 delay:0
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 view.center = [originalView.superview convertPoint:originalView.center toView:self.view];	// reposition the drag icon to coincide with the tool
						 view.alpha = 0;
					 }
					 completion:^(BOOL fin){ view.alpha = 1; view.hidden = YES; }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"documents"]) {
		((DocumentListTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController).activeDocument = self.activeDocument;
		((DocumentListTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController).delegate = self;			// set up ourselves as delegate
		[self.activeDocument save];
	} else if ([segue.identifier isEqualToString:@"settings"]) {
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
	else
		self.activeDocument = [[StrataDocument alloc] init];							// empty document
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

- (void)setActiveDocument:(StrataDocument *)document
{
	_activeDocument = document;
	if (!_activeDocument)
		_activeDocument = [[StrataDocument alloc] init];
	// do necessary initialization when the current document is changed
	CGRect frame = CGRectMake(0, 0, self.strataView.frame.size.width, self.activeDocument.strataHeight*PPI);
	self.strataView.frame = frame;														// modifying bounds would affect frame origin
	self.freehandView.frame = frame;
	self.toolbarTitle.title = self.activeDocument.name;
	self.strataView.activeDocument = self.activeDocument;
	self.freehandView.activeDocument = self.activeDocument;
	self.strataGraphScrollView.contentSize = self.strataView.bounds.size;
	self.strataGraphScrollView.contentOffset = CGPointMake(0, self.strataView.bounds.size.height-self.strataGraphScrollView.bounds.size.height);
	self.strataView.scale = self.strataGraphScrollView.zoomScale;
	self.strataView.locationLabel = self.locationLabel;
	self.strataView.dimensionLabel = self.dimensionLabel;
	self.strataView.delegate = self;
	// for graphics.h
	self.bounds = self.strataView.bounds;
	self.origin = CGPointMake(XORIGIN, YORIGIN);
	
	self.strataPageView.activeDocument = self.activeDocument;
	self.strataPageScrollView.contentSize = self.strataPageView.bounds.size;
	self.strataPageScrollView.contentOffset = CGPointMake(0, self.strataPageView.bounds.size.height-self.strataPageScrollView.bounds.size.height);
	self.strataPageScrollView.hidden = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SRActiveDocumentSelectionChanged object:self userInfo:[NSDictionary dictionaryWithObject:self.activeDocument forKey:@"activeDocument"]];
	[self.strataView setNeedsDisplay];
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
		self.bounds = frame;
	}
	self.strataGraphScrollView.contentSize = self.strataView.bounds.size;
	[self.strataView handleStrataHeightChanged:self];
	[self.strataGraphScrollView setNeedsDisplay];														// TODO: unsuccessful at displaying new view height
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

- (void)setActiveStrataDocument:(NSString *)name
{
	self.activeDocument = [StrataDocument loadFromFile:name];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
	if (sender == self.strataGraphScrollView)
		return self.strataView;
	else
		return self.strataPageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	view.contentScaleFactor = scale * [UIScreen mainScreen].scale;
//	self.strataView.scale = self.scrollView.zoomScale;
//	[self.strataView setNeedsDisplay];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
	[self setScissorsView:nil];
	[self setAnchorView:nil];
	[self setPaleoCurrentView:nil];
	[self setScissorsDragView:nil];
	[self setAnchorDragView:nil];
	[self setPaleoCurrentDragView:nil];
	[self setFreehandView:nil];
	[super viewDidUnload];
}
@end

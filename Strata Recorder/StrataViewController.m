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

typedef enum {
	tapStateNoneSelected,
	tapStatePaleoSelected,
	tapStateAnchorSelected,
	tapStatePencilSelected,
	tapStateInfoSelected,
	tapStateScissorsSelected
} tapState;

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
@property (weak, nonatomic) IBOutlet UIImageView *paleoCurrentSelectedView;
// equivalent icons in main view, for dragging
@property (nonatomic) IBOutlet UIImageView *scissorsDragView;
@property (nonatomic) IBOutlet UIImageView *anchorDragView;
@property (nonatomic) IBOutlet UIImageView *paleoCurrentDragView;
// for graphics.h
@property CGRect bounds;
@property CGPoint origin;
// for dragging and rotating paleocurrent
@property PaleoCurrent *selectedPaleoCurrent;
@property Stratum *selectedStratum;
@property float paleoCurrentInitialRotation;
@property BOOL paleoCurrentDragStarted;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) IBOutlet UIRotationGestureRecognizer *rotationGestureRecognizer;
@property tapState currentTapState;
@end

@implementation StrataViewController

#define HIT_DISTANCE 1./6.

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
	CGPoint hitPoint = CGPointMake(UX([gestureRecognizer locationInView:gestureRecognizer.view].x), UY([gestureRecognizer locationInView:gestureRecognizer.view].y));
	if (self.currentTapState == tapStateNoneSelected) {
		for (Stratum *stratum in self.activeDocument.strata) {
			CGPoint infoIconLocation = CGPointMake(stratum.frame.origin.x+stratum.frame.size.width-.12, stratum.frame.origin.y+.1);
			CGPoint pencilIconLocation = CGPointMake(stratum.frame.origin.x+stratum.frame.size.width/2.0, stratum.frame.origin.y+stratum.frame.size.height/2.0);
			if ((hitPoint.x-infoIconLocation.x)*(hitPoint.x-infoIconLocation.x)+
				(hitPoint.y-infoIconLocation.y)*(hitPoint.y-infoIconLocation.y) < HIT_DISTANCE*HIT_DISTANCE) {					// hit detected on info icon
				self.strataView.selectedStratum = stratum;																		// for our delegate's use
				self.strataView.infoSelectionPoint = CGPointMake(VX(infoIconLocation.x), VY(infoIconLocation.y));				// for our delegate's use
				[self handleStratumInfo:self.strataView];													// tell our delegate to create the navigation controller for managing stratum properties
			} else if ((hitPoint.x-pencilIconLocation.x)*(hitPoint.x-pencilIconLocation.x)+
					   (hitPoint.y-pencilIconLocation.y)*(hitPoint.y-pencilIconLocation.y) < HIT_DISTANCE*HIT_DISTANCE) {		// hit detected on pencil icon
				self.currentTapState = tapStatePencilSelected;
				self.selectedStratum = stratum;
				[self.strataView handlePencilTap:stratum];
				self.strataView.touchesEnabled = NO;
				self.strataGraphScrollView.pinchGestureRecognizer.enabled = NO;													// temporary: should depend on location of touchesBegan
				self.strataGraphScrollView.scrollEnabled = NO;																	// ditto
				self.strataView.overlayContainer.overlayVisible = YES;
			} else {																											// look for paleocurrents in each stratum
				for (PaleoCurrent *paleo in stratum.paleoCurrents) {
					CGPoint paleoLocation = CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y);
					if ((hitPoint.x-paleoLocation.x)*(hitPoint.x-paleoLocation.x)+
						(hitPoint.y-paleoLocation.y)*(hitPoint.y-paleoLocation.y) < HIT_DISTANCE*HIT_DISTANCE &&
						self.selectedPaleoCurrent == nil) {																		// hit detected on paleocurrent
						self.currentTapState = tapStatePaleoSelected;
						self.paleoCurrentSelectedView.hidden = NO;
						self.paleoCurrentSelectedView.center = [self.strataView convertPoint:CGPointMake(VX(paleoLocation.x), VY(paleoLocation.y)) toView:self.view];
						self.paleoCurrentSelectedView.transform = CGAffineTransformMakeRotation(paleo.rotation);
						self.paleoCurrentInitialRotation = paleo.rotation;
						[self.strataView handlePaleoTap:paleo inStratum:stratum];
						self.selectedPaleoCurrent = paleo;
						self.selectedStratum = stratum;
						self.strataView.selectedStratum = stratum;																// clone it
						self.panGestureRecognizer.enabled = YES;
						self.rotationGestureRecognizer.enabled = YES;
						self.paleoCurrentDragStarted = NO;
						self.strataView.touchesEnabled = NO;
						self.strataGraphScrollView.pinchGestureRecognizer.enabled = NO;
						self.strataGraphScrollView.scrollEnabled = NO;
						break;
					}
				}
			}
			if (self.currentTapState != tapStateNoneSelected) break;
		}
	} else if (self.currentTapState == tapStatePaleoSelected) {
		self.paleoCurrentSelectedView.hidden = YES;
		self.strataGraphScrollView.userInteractionEnabled = YES;
		self.panGestureRecognizer.enabled = NO;
		self.rotationGestureRecognizer.enabled = NO;
		self.selectedPaleoCurrent.rotation = self.paleoCurrentInitialRotation;
		CGPoint point = [self.view convertPoint:self.paleoCurrentSelectedView.center toView:self.strataView];
		self.selectedPaleoCurrent.origin = CGPointMake(UX(point.x)-self.selectedStratum.frame.size.width, UY(point.y)-self.selectedStratum.frame.origin.y);
		self.selectedPaleoCurrent = nil;
		self.currentTapState = tapStateNoneSelected;
		self.strataView.touchesEnabled = YES;
		self.strataGraphScrollView.scrollEnabled = YES;
		self.strataGraphScrollView.pinchGestureRecognizer.enabled = YES;
		[self.strataView setNeedsDisplay];
	} else if (self.currentTapState == tapStatePencilSelected) {
		Stratum *stratum = self.selectedStratum;
		CGPoint pencilIconLocation = CGPointMake(stratum.frame.origin.x+stratum.frame.size.width/2.0, stratum.frame.origin.y+stratum.frame.size.height/2.0);
		if ((hitPoint.x-pencilIconLocation.x)*(hitPoint.x-pencilIconLocation.x)+
			(hitPoint.y-pencilIconLocation.y)*(hitPoint.y-pencilIconLocation.y) < HIT_DISTANCE*HIT_DISTANCE) {// hit detected on pencil icon
			self.currentTapState = tapStateNoneSelected;
			[self.strataView handlePencilTap:stratum];
			self.strataView.touchesEnabled = YES;
			self.strataGraphScrollView.pinchGestureRecognizer.enabled = YES;												// temporary: should depend on location of touchesBegan
			self.strataGraphScrollView.scrollEnabled = YES;																	// ditto
			self.strataView.overlayContainer.overlayVisible = NO;
			[self.strataView setNeedsDisplay];
		}
	}
}

/*
 Look for a paleocurrent icon that's located at the rotation center, and change its rotation based on the gesture.
 */

- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		self.paleoCurrentInitialRotation = self.selectedPaleoCurrent.rotation;
	} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		self.paleoCurrentSelectedView.transform = CGAffineTransformMakeRotation(self.selectedPaleoCurrent.rotation+gestureRecognizer.rotation);
		self.paleoCurrentInitialRotation = self.selectedPaleoCurrent.rotation+gestureRecognizer.rotation;
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
				CGPoint translation = [gestureRecognizer translationInView:self.scissorsDragView.superview];
				self.scissorsDragView.center = CGPointMake(self.scissorsDragView.center.x + translation.x, self.scissorsDragView.center.y + translation.y);
			} else if (gestureRecognizer.view == self.anchorView) {
				CGPoint translation = [gestureRecognizer translationInView:self.anchorDragView.superview];
				self.anchorDragView.center = CGPointMake(self.anchorDragView.center.x + translation.x, self.anchorDragView.center.y + translation.y);
			} else if (gestureRecognizer.view == self.paleoCurrentView) {
				CGPoint translation = [gestureRecognizer translationInView:self.paleoCurrentDragView.superview];
				self.paleoCurrentDragView.center = CGPointMake(self.paleoCurrentDragView.center.x + translation.x, self.paleoCurrentDragView.center.y + translation.y);
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
    } else if (gestureRecognizer.view == self.paleoCurrentSelectedView) {					// this is an existing selected paleocurrent, self.paleoCurrentView is new paleocurrent
		CGPoint hitPoint = CGPointMake([gestureRecognizer locationInView:self.view].x, [gestureRecognizer locationInView:self.view].y);
		CGPoint paleoLocation = CGPointMake(self.paleoCurrentSelectedView.center.x, self.paleoCurrentSelectedView.center.y);
		BOOL hit = (hitPoint.x-paleoLocation.x)*(hitPoint.x-paleoLocation.x)+(hitPoint.y-paleoLocation.y)*(hitPoint.y-paleoLocation.y)<VX(HIT_DISTANCE)*VX(HIT_DISTANCE);
		if (gestureRecognizer.state == UIGestureRecognizerStateBegan && hit) {
			self.paleoCurrentDragStarted = YES;
		} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged && self.paleoCurrentDragStarted) {
			if (self.selectedPaleoCurrent) {
				CGPoint translation = [gestureRecognizer translationInView:self.paleoCurrentSelectedView.superview];
				self.paleoCurrentSelectedView.center = CGPointMake(self.paleoCurrentSelectedView.center.x + translation.x, self.paleoCurrentSelectedView.center.y + translation.y);
				[gestureRecognizer setTranslation:CGPointZero inView:self.view];
			}
		} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
			CGPoint dropPoint = [self.view convertPoint:self.paleoCurrentSelectedView.center toView:self.strataView];
			CGPoint dropPointUser = CGPointMake(UX(dropPoint.x), UY(dropPoint.y));														// in user coordinates
			Stratum *stratum = self.selectedStratum;
			// user is discarding paleocurrent
			if (dropPointUser.x < stratum.frame.size.width || dropPointUser.x > stratum.frame.size.width + 1 || dropPointUser.y < stratum.frame.origin.y || dropPointUser.y > stratum.frame.origin.y+stratum.frame.size.height) {
				[self putAwayTool:self.paleoCurrentSelectedView toOriginalView:self.paleoCurrentView];
				[stratum.paleoCurrents removeObject:self.selectedPaleoCurrent];
				[self.strataView setNeedsDisplay];
			}
			self.paleoCurrentDragStarted = NO;
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
	self.rotationGestureRecognizer.enabled = NO;
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
	[self setPanGestureRecognizer:nil];
	[self setPaleoCurrentSelectedView:nil];
	[self setRotationGestureRecognizer:nil];
	[super viewDidUnload];
}
@end

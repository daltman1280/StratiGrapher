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
#import "StratumInfoTableViewController.h"
#import "StratumMaterialsPaletteTableViewController.h"
#import "StratumMaterialsTableController.h"
#import "StrataPageView.h"
#import "StrataPageViewController.h"
#import "StrataModel.h"
#import "DocumentListTableViewController.h"
#import "SettingsNavigationController.h"
#import "SettingsTableController.h"
#import "StrataNotifications.h"
#import "Graphics.h"
#import "LegendView.h"
#import "MaterialPatternView.h"
#import "ContainerPageViewController.h"
#import "StrataModelState.h"

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
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *dimensionLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *strataGraphScrollView;
@property UIPopoverController *popover;
@property (nonatomic) IBOutlet StrataPageView *strataPageView;																	// hosts the page view, used to render PDF pages
@property NSMutableArray* strataPageViewControllerArray;
@property (nonatomic) StrataDocument *activeDocument;
@property StratumInfoNavigationController* stratumInfoNavigationController;
@property StratumMaterialsTableController* stratumMaterialsTableController;
@property StratumInfoTableViewController* stratumInfoTableViewController;
@property SettingsNavigationController* settingsNavigationController;
@property SettingsTableController* settingsTableController;
// tools
@property (strong, nonatomic) IBOutlet UIImageView *scissorsView;
@property (strong, nonatomic) IBOutlet UIImageView *anchorView;
@property (strong, nonatomic) IBOutlet UIImageView *paleoCurrentView;
@property (strong, nonatomic) IBOutlet UIImageView *paleoCurrentSelectedView;
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
// legend properties
@property (strong, nonatomic) IBOutlet LegendView *legendView;
@property (strong, nonatomic) IBOutlet UIView *legendLineContainer;
@property (strong, nonatomic) IBOutlet UILabel *legendLineLabel;
@property (strong, nonatomic) IBOutlet MaterialPatternView *legendLineMaterial;
// page view strata column adornments
@property (strong, nonatomic) IBOutlet UILabel *columnNumber;
@property (strong, nonatomic) IBOutlet UILabel *grainSizeLegend;
@property (strong, nonatomic) IBOutlet UIView *strataColumn;
@property (strong, nonatomic) IBOutlet UILabel *grainSizeLines;

@property ContainerPageViewController *containerPageViewController;
@property BOOL							doOnce;
@end

@implementation StrataViewController

+ (void)handleEnterBackground
{
	StrataViewController *controller = (StrataViewController *) [[[UIApplication sharedApplication] keyWindow] rootViewController];
	/*
	 The following emulates code from handleTapGesture. Must be kept in sync.
	 */
	if (controller.currentTapState == tapStatePencilSelected) {
		controller.currentTapState = tapStateNoneSelected;
		[controller.strataView handlePencilTap:controller.selectedStratum];
		controller.strataView.touchesEnabled = YES;
		controller.strataGraphScrollView.pinchGestureRecognizer.enabled = YES;
		controller.strataGraphScrollView.scrollEnabled = YES;
		controller.strataView.overlayContainer.overlayVisible = NO;
		[controller.strataView setNeedsDisplay];
		[controller.strataView.overlayContainer removeFromSuperlayer];
	}
}

+ (void)handleEnterForeground
{
	StrataViewController *controller = (StrataViewController *) [[[UIApplication sharedApplication] keyWindow] rootViewController];
#pragma unused(controller)
}

#define HIT_DISTANCE 1./6.

//	Action method for TapGestureRecognizer attached to StrataView.

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
	CGPoint hitPoint = CGPointMake(UX([gestureRecognizer locationInView:gestureRecognizer.view].x), UY([gestureRecognizer locationInView:gestureRecognizer.view].y));
	if (self.currentTapState == tapStateNoneSelected) {																			// we're not currently in a mode state
		for (Stratum *stratum in self.activeDocument.strata) {
			if ([self.activeDocument.strata indexOfObject:stratum] == self.activeDocument.strata.count-1)						// don't process tap gestures for last empty stratum
				continue;
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
				self.strataView.overlayContainer.overlayVisible = YES;
			} else {																											// look for paleocurrents in each stratum
				NSMutableArray *paleoCurrentCandidates = [[NSMutableArray alloc] init];
				for (PaleoCurrent *paleo in stratum.paleoCurrents) {
					CGPoint paleoLocation = CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y);
					if ((hitPoint.x-paleoLocation.x)*(hitPoint.x-paleoLocation.x)+
						(hitPoint.y-paleoLocation.y)*(hitPoint.y-paleoLocation.y) < HIT_DISTANCE*HIT_DISTANCE &&
						self.selectedPaleoCurrent == nil) {																		// hit detected on paleocurrent, add it to list of selection candidates
						[paleoCurrentCandidates addObject:paleo];
					}
				}
				if (paleoCurrentCandidates.count > 0) {
					float hitDistance = MAXFLOAT;
					PaleoCurrent *bestHit;
					for (PaleoCurrent *paleo in paleoCurrentCandidates) {
						CGPoint paleoLocation = CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y);
						if ((hitPoint.x-paleoLocation.x)*(hitPoint.x-paleoLocation.x)+(hitPoint.y-paleoLocation.y)*(hitPoint.y-paleoLocation.y) < hitDistance) {
							hitDistance = (hitPoint.x-paleoLocation.x)*(hitPoint.x-paleoLocation.x)+(hitPoint.y-paleoLocation.y)*(hitPoint.y-paleoLocation.y);
							bestHit = paleo;
						}
					}
					PaleoCurrent *paleo = bestHit;
					CGPoint paleoLocation = CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y);
					self.currentTapState = tapStatePaleoSelected;
					self.paleoCurrentSelectedView.hidden = NO;
					self.paleoCurrentSelectedView.center = [self.strataView convertPoint:CGPointMake(VX(paleoLocation.x), VY(paleoLocation.y)) toView:self.view];
					self.paleoCurrentSelectedView.transform = CGAffineTransformMakeRotation(paleo.rotation);
					self.paleoCurrentSelectedView.transform = CGAffineTransformScale(self.paleoCurrentSelectedView.transform, self.strataGraphScrollView.zoomScale*.5, self.strataGraphScrollView.zoomScale*.5);
					self.paleoCurrentInitialRotation = paleo.rotation;
					[self.strataView handlePaleoTap:paleo inStratum:stratum];
					self.selectedPaleoCurrent = paleo;
					self.selectedStratum = stratum;
					self.strataView.selectedStratum = stratum;																// clone it
					self.panGestureRecognizer.enabled = YES;
					self.rotationGestureRecognizer.enabled = YES;
					self.paleoCurrentDragStarted = NO;
					self.strataView.touchesEnabled = NO;
					[StrataModelState currentState].dirty = YES;
					break;
				}
			}
			if (self.currentTapState != tapStateNoneSelected) break;
		}
	} else if (self.currentTapState == tapStatePaleoSelected) {																	// deselecting paleocurrent
		self.paleoCurrentSelectedView.hidden = YES;
		self.strataGraphScrollView.userInteractionEnabled = YES;
		self.panGestureRecognizer.enabled = NO;
		self.rotationGestureRecognizer.enabled = NO;
		self.selectedPaleoCurrent.rotation = self.paleoCurrentInitialRotation;
		CGPoint point = [self.view convertPoint:self.paleoCurrentSelectedView.center toView:self.strataView];
		self.selectedPaleoCurrent.origin = CGPointMake(UX(point.x)-self.selectedStratum.frame.size.width, UY(point.y)-self.selectedStratum.frame.origin.y);
		self.selectedPaleoCurrent = nil;
		[StrataModelState currentState].dirty = YES;
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
 Action method for UiRotationGestureRecognizer attached to StrataView.
 Look for a paleocurrent icon that's located at the rotation center, and change its rotation based on the gesture.
 */

- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		self.paleoCurrentInitialRotation = self.selectedPaleoCurrent.rotation;
	} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		self.paleoCurrentSelectedView.transform = CGAffineTransformMakeRotation(self.selectedPaleoCurrent.rotation+gestureRecognizer.rotation);
		self.paleoCurrentSelectedView.transform = CGAffineTransformScale(self.paleoCurrentSelectedView.transform, self.strataGraphScrollView.zoomScale*.5, self.strataGraphScrollView.zoomScale*.5);
		self.paleoCurrentInitialRotation = self.selectedPaleoCurrent.rotation+gestureRecognizer.rotation;
	}
	[StrataModelState currentState].dirty = YES;
}

/*
 Action method for UIPanGestureRecognizers that are attached to the following:
 
 Anchor, Arrow, and Scissors tools;
 Selected Arrow, in drawing area.
 */

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
				[StrataModelState currentState].dirty = YES;
			} else if (gestureRecognizer.view == self.anchorView) {
				[self handlePlaceToolAtStratumOrigin:ToolAnchor usingView:self.anchorDragView originalView:self.anchorView];
			} else if (gestureRecognizer.view == self.paleoCurrentView) {
				[self handlePlaceToolAtStratumOrigin:ToolArrow usingView:self.paleoCurrentDragView originalView:self.paleoCurrentView];
				[StrataModelState currentState].dirty = YES;
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
				self.strataGraphScrollView.scrollEnabled = YES;
				self.strataGraphScrollView.pinchGestureRecognizer.enabled = YES;
				[self.strataView setNeedsDisplay];
			}
			self.paleoCurrentDragStarted = NO;
			[StrataModelState currentState].dirty = YES;
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
		// doesn't belong to any stratum
		[self putAwayTool:view toOriginalView:originalView];																	// paleocurrent must be placed to the right of the stratum
		return;
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
	[StrataModelState currentState].dirty = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"documents"]) {
		UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
		((DocumentListTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController).activeDocument = self.activeDocument;
		((DocumentListTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController).delegate = self;			// set up ourselves as delegate
		[self.activeDocument save];
		((UIStoryboardPopoverSegue *)segue).popoverController.delegate = (id) self;																	// popover controller delegate
		self.popover = popoverSegue.popoverController;																								// so we can dismiss the popover
	} else if ([segue.identifier isEqualToString:@"settings"]) {
		UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
		self.settingsNavigationController = segue.destinationViewController;
		self.settingsNavigationController.delegate = self.settingsNavigationController;				// this is where we setup the UINavigationControllerDelegate (can't do this from IB)
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
	self.doOnce = NO;
	// settings from user preferences
	NSArray *existingStrataDocuments = [StrataDocument existingStrataDocuments];
	if (existingStrataDocuments.count > 0) {
		NSString *documentName = [[NSUserDefaults standardUserDefaults] objectForKey:@"activeDocument"];
		if (documentName) {
			self.activeDocument = [StrataDocument loadFromFile:documentName];
			if (!self.activeDocument) {																	// doesn't exist, load another, otherwise, we're finished
				self.activeDocument = [StrataDocument loadFromFile:existingStrataDocuments[0]];		// load the first one
				[[NSUserDefaults standardUserDefaults] setObject:self.activeDocument.name forKey:@"activeDocument"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
		}
		
	} else {																					// no existing documents
		self.activeDocument = [[StrataDocument alloc] init];									// empty document
		[self.activeDocument save];
		self.activeDocument = [StrataDocument loadFromFile:self.activeDocument.name];
		[[NSUserDefaults standardUserDefaults] setObject:self.activeDocument.name forKey:@"activeDocument"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"patterns1 multipage" withExtension:@"pdf"];
	CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)(url));
	CGPDFPageRef page;
	self.strataView.patternsPageArray = [[NSMutableArray alloc] init];
	for (int i=1; i<=28; ++i) {
		page = CGPDFDocumentGetPage(document, i);
		[self.strataView.patternsPageArray addObject:[NSValue valueWithPointer:page]];
		CFRetain(page);
	}
	CGPDFDocumentRelease(document);
	self.strataPageView.patternsPageArray = self.strataView.patternsPageArray;
	self.strataView.controller = self;
	self.rotationGestureRecognizer.enabled = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationEnteredBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationBecameActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStrataHeightChanged:) name:SRStrataHeightChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStrataViewScrollerScrollToTop:) name:SRStrataViewScrollerScrollToTopNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEditingOperationStarted:) name:SREditingOperationStartedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEditingOperationEnded:) name:SREditingOperationEndedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePopupVisible:) name:SRPopupVisibleNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePopupNotVisible:) name:SRPopupNotVisibleNotification object:nil];
	// initialize legend
	self.legendView.legendLineContainer = self.legendLineContainer;
	self.legendView.legendLineLabel = self.legendLineLabel;
	self.legendView.legendLineMaterial = self.legendLineMaterial;
	[self.legendView populateLegend];
	self.strataPageView.legendView = self.legendView;
	// initialize page view properties
	self.strataPageView.columnNumber = self.columnNumber;
	self.strataPageView.grainSizeLegend = self.grainSizeLegend;
	self.strataPageView.grainSizeLines = self.grainSizeLines;
	self.strataPageView.strataColumn = self.strataColumn;
	// set up the page view complex
	[self.strataPageView removeFromSuperview];											// we'll just use as a template, populating its parent programmatically
	self.strataPageViewControllerArray = [[NSMutableArray alloc] init];					// used to retain references to page view view controllers
	self.containerPageViewController = [[ContainerPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:[NSDictionary dictionaryWithObjectsAndKeys:UIPageViewControllerOptionInterPageSpacingKey, [NSNumber numberWithFloat:50.0], nil]];
	self.containerPageViewController.pageControl = self.pageControl;
	[self addChildViewController:self.containerPageViewController];						// required when embedding container VCs
	[self.view insertSubview:self.containerPageViewController.view belowSubview:self.toolbar];	// required when embedding container VCs, we want it behind the toolbar
	[self.containerPageViewController didMoveToParentViewController:self];				// required when embedding container VCs
	// set the UIPageController's frame
	CGRect pageViewRect = self.view.bounds;
	pageViewRect.origin.y += 44;														// height of toolbar
	pageViewRect.size.height -= 44;
	self.containerPageViewController.view.frame = pageViewRect;
	self.containerPageViewController.view.hidden = YES;
}

- (void)setActiveDocument:(StrataDocument *)document
{
	_activeDocument = document;
	if (!_activeDocument)
		_activeDocument = [[StrataDocument alloc] init];
	// do necessary initialization when the current document is changed
	[self.strataGraphScrollView setZoomScale:self.strataGraphScrollView.minimumZoomScale];
	CGRect frame = CGRectMake(0, 0, self.strataView.frame.size.width, self.activeDocument.strataHeight*PPI);
	self.strataView.frame = frame;														// modifying bounds would affect frame origin
	self.toolbarTitle.title = self.activeDocument.name;
	self.strataView.activeDocument = self.activeDocument;
	self.strataGraphScrollView.contentSize = self.strataView.bounds.size;
	self.strataGraphScrollView.contentOffset = CGPointMake(0, self.strataView.bounds.size.height-self.strataGraphScrollView.bounds.size.height);
	self.strataView.scale = self.strataGraphScrollView.zoomScale;
	self.strataView.locationLabel = self.locationLabel;
	self.strataView.dimensionLabel = self.dimensionLabel;
	self.strataView.delegate = self;
	// for graphics.h
	self.bounds = self.strataView.bounds;
	self.origin = CGPointMake(XORIGIN, YORIGIN);
	
	self.strataPageView.activeDocument = self.activeDocument;							// this will initialize the view's bounds
	
	if (((UISegmentedControl *)self.modeControl).selectedSegmentIndex != 0) {
		((UISegmentedControl *)self.modeControl).selectedSegmentIndex = 0;				// switch to draft mode
		[self handleModeSwitch:self.modeControl];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:SRActiveDocumentSelectionChangedNotification object:self userInfo:[NSDictionary dictionaryWithObject:self.activeDocument forKey:@"activeDocument"]];
	[self.strataView setNeedsDisplay];
	[self.strataGraphScrollView setNeedsDisplay];
}

- (void)handleApplicationBecameActive:(id)sender
{
	[self.strataView initialize];
}

- (void)handleStrataHeightChanged:(id)sender
{
	// update strata view frame
	CGRect frame = CGRectMake(0, 0, self.strataView.frame.size.width, self.activeDocument.strataHeight*PPI*self.strataGraphScrollView.zoomScale);
	self.strataView.frame = frame;														// modifying bounds would affect frame origin
	float oldScrollviewContentHeight = self.strataGraphScrollView.contentSize.height;	// for adjusting offset of scroll view
	CGSize contentSize = self.strataView.frame.size;
	self.strataGraphScrollView.contentSize = contentSize;								// set contentSize of scroll view
	float newScrollviewContentHeight = self.strataGraphScrollView.contentSize.height;	// for adjusting offset of scroll view
	[self.strataView handleStrataHeightChanged:self];									// adjust locations of icons, because icon locations are measured from bottom left
	CGPoint contentOffset = self.strataGraphScrollView.contentOffset;
	contentOffset.y += newScrollviewContentHeight-oldScrollviewContentHeight;
	if (contentOffset.y < 0) contentOffset.y = 0;										// should be pinned to top of view
	self.strataGraphScrollView.contentOffset = contentOffset;							// set content offset of scroll view
	// for graphics.h
	self.bounds = self.strataView.bounds;
	self.origin = CGPointMake(XORIGIN, YORIGIN);
	[self.strataView setNeedsDisplay];
}

- (void)handlePopupVisible:(id)sender
{
	self.documentsButton.enabled = NO;
	self.settingsButton.enabled = NO;
	self.modeButton.enabled = NO;
}

- (void)handlePopupNotVisible:(id)sender
{
	self.documentsButton.enabled = YES;
	self.settingsButton.enabled = YES;
	self.modeButton.enabled = YES;
}

- (void)handleStrataViewScrollerScrollToTop:(id)sender
{
	CGPoint contentOffset = self.strataGraphScrollView.contentOffset;
	contentOffset.y = 0;
	self.strataGraphScrollView.contentOffset = contentOffset;							// set content offset of scroll view
}

- (void)handleEditingOperationStarted:(id)sender
{
	self.strataGraphScrollView.scrollEnabled = NO;
}

- (void)handleEditingOperationEnded:(id)sender
{
	self.strataGraphScrollView.scrollEnabled = YES;
}

- (void)handleApplicationEnteredBackground:(id)sender
{
	[self.strataView.activeDocument save];
	[[NSUserDefaults standardUserDefaults] setObject:self.activeDocument.name forKey:@"activeDocument"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)handleModeSwitch:(id)sender {
	NSInteger selection = [(UISegmentedControl *)sender selectedSegmentIndex];
	if (selection == 1) {																						// switching to page mode
		if ([StrataModelState currentState].dirty) {
			[StrataModelState currentState].dirty = NO;
			// initialize properties that are needed in StrataPageView
			self.containerPageViewController.patternsPageArray = self.strataView.patternsPageArray;
			self.containerPageViewController.legendView = self.legendView;
			self.containerPageViewController.columnNumber = self.columnNumber;
			self.containerPageViewController.grainSizeLegend = self.grainSizeLegend;
			self.containerPageViewController.grainSizeLines = self.grainSizeLines;
			self.containerPageViewController.strataColumn = self.strataColumn;
			self.containerPageViewController.activeDocument = self.activeDocument;								// this will update the view's bounds
			[self.legendView populateLegend];
			StrataPageViewController *controller = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"strataPageViewController"];
			[self.strataPageViewControllerArray removeAllObjects];												// from previous mode switch
			[self.strataPageViewControllerArray addObject:controller];
			[self.containerPageViewController setViewControllers:self.strataPageViewControllerArray direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
			controller.parent = self.containerPageViewController;
			controller.pageIndex = 0;																			// make it the first page (might want to change later to restore current page)
			self.pageControl.currentPage = 0;
			self.pageControl.numberOfPages = controller.maxPages;
			self.containerPageViewController.maxPages = controller.maxPages;
		}
		[UIView transitionFromView:self.strataGraphScrollView toView:self.containerPageViewController.view duration:0.5 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionCrossDissolve completion:NULL];
		self.pageViewBackground.hidden = NO;
		self.pageControl.hidden = NO;
	} else {																									// switching to draft mode
		self.pageViewBackground.hidden = YES;
		self.pageControl.hidden = YES;
		[UIView transitionFromView:self.containerPageViewController.view toView:self.strataGraphScrollView duration:0.5 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionCrossDissolve completion:NULL];
	}
}

#pragma mark stratum info popover

/*
 Create a popover which contains a navigation controller, containing a table controller for managing the material number
 */

- (void)handleStratumInfo:(id)sender
{
	// get the UITableController and initialize its properties, so it can manage the properties of the selected stratum
	self.stratumInfoNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"StratumInfoNavigationController"];
	self.stratumInfoTableViewController = self.stratumInfoNavigationController.viewControllers[0];
	self.stratumInfoTableViewController.stratum = ((StrataView *)sender).selectedStratum;
	self.stratumInfoTableViewController.materialNumber = self.stratumInfoTableViewController.stratum.materialNumber;
	self.stratumInfoTableViewController.activeDocument = self.activeDocument;
	self.stratumInfoTableViewController.grainSizeIndex = self.stratumInfoTableViewController.stratum.grainSizeIndex;
	self.stratumInfoTableViewController.stratumInfoNavigationController = self.stratumInfoNavigationController;
	self.stratumInfoTableViewController.delegate = self;
	self.popover = [[UIPopoverController alloc] initWithContentViewController:self.stratumInfoNavigationController];
	[self.popover presentPopoverFromRect:CGRectMake(self.strataView.infoSelectionPoint.x, self.strataView.infoSelectionPoint.y, 1, 1) inView:self.strataView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)handleStratumInfoComplete:(id)sender
{
	[self.popover dismissPopoverAnimated:YES];
	[self.strataView populateMoveIconLocations];
	[self.strataView setNeedsDisplay];
}

#pragma mark SettingsControllerDelegate

- (void)handleSettingsTableComplete:(id)sender;
{
	[self.popover dismissPopoverAnimated:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:SRPopupNotVisibleNotification object:self];
	if ([((UIBarButtonItem *)sender).title isEqualToString:@"Save"]) {
		self.activeDocument.pageDimension = CGSizeMake(self.settingsTableController.paperWidth, self.settingsTableController.paperHeight);
		self.activeDocument.pageMargins = CGSizeMake(self.settingsTableController.marginWidth, self.settingsTableController.marginHeight);
		self.activeDocument.scale = self.settingsTableController.pageScale;
		self.activeDocument.lineThickness = self.settingsTableController.lineThickness;
		self.activeDocument.units = self.settingsTableController.units;
		self.activeDocument.strataHeight = self.settingsTableController.strataHeight;
		self.activeDocument.patternScale = self.settingsTableController.patternScale;
		self.activeDocument.legendScale = self.settingsTableController.legendScale;
		self.activeDocument.sectionLabels = self.settingsTableController.sectionLabels;
		// update the page views
		NSInteger selection = [(UISegmentedControl *)self.modeControl selectedSegmentIndex];
		if (selection == 1)																					// if we're in page mode, refresh, with page 1
			[self handleModeSwitch:self.modeControl];
		[[NSNotificationCenter defaultCenter] postNotificationName:SRStrataHeightChangedNotification object:self];
	}
}

#pragma mark DocumentListControllerDelegate

- (void)handleExportPDFButton:(id)sender
{
	[self.strataPageView exportPDF];
}

- (void)setActiveStrataDocument:(NSString *)name
{
	float previousDocumentHeight = self.activeDocument.strataHeight;
	self.activeDocument = [StrataDocument loadFromFile:name];
	if (self.activeDocument.strataHeight > previousDocumentHeight + 7) {									// need to dismiss popover to get it to redraw
		[self.popover dismissPopoverAnimated:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:SRPopupNotVisibleNotification object:self];
	}
}

#pragma mark Document List Popover Controller Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[[NSNotificationCenter defaultCenter] postNotificationName:SRPopupNotVisibleNotification object:self];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
	return self.strataView;
}

//	Maintain the current screen position of selected paleocurrent

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView == self.strataGraphScrollView && self.selectedPaleoCurrent) {
		Stratum *stratum = self.selectedStratum;
		PaleoCurrent *paleo = self.selectedPaleoCurrent;
		CGPoint paleoLocation = CGPointMake(stratum.frame.size.width+paleo.origin.x, stratum.frame.origin.y+paleo.origin.y);
		self.paleoCurrentSelectedView.center = [self.strataView convertPoint:CGPointMake(VX(paleoLocation.x), VY(paleoLocation.y)) toView:self.view];
		self.strataView.scale = self.strataGraphScrollView.zoomScale;
	}
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
	NSLog(@"StrataViewController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 In iOS 6 and above, if the initial orientation isn't portrait, didRotateFromInterfaceOrientation does not get called
 for initial rotation, so we use this callback (only want to do this once, when view controller first gets initialized).
 */

- (void)viewWillLayoutSubviews
{
	if (!self.doOnce) {
		self.doOnce = YES;
		[self didRotateFromInterfaceOrientation:(UIInterfaceOrientation) nil];
	}
}

/*
 Adjust views to account for rotation
 */

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	CGRect frame = CGRectMake(0, 0, self.strataView.frame.size.width*self.strataGraphScrollView.zoomScale, self.activeDocument.strataHeight*PPI*self.strataGraphScrollView.zoomScale);
	self.strataView.frame = frame;															// modifying bounds would affect frame origin
	self.strataGraphScrollView.contentSize = CGSizeMake(self.strataView.bounds.size.width*self.strataGraphScrollView.zoomScale, self.strataView.bounds.size.height*self.strataGraphScrollView.zoomScale);
	self.strataGraphScrollView.contentOffset = CGPointMake(0, self.strataView.bounds.size.height-self.strataGraphScrollView.bounds.size.height);
	// for graphics.h
	self.bounds = self.strataView.bounds;
	self.origin = CGPointMake(XORIGIN, YORIGIN);
	self.strataPageView.activeDocument = self.activeDocument;							// this will initialize the view's bounds
	[self.strataView.overlayContainer setNeedsLayout];
	[self.strataView setNeedsDisplay];
	// update the page views
	[StrataModelState currentState].dirty = YES;
	NSInteger selection = [(UISegmentedControl *)self.modeControl selectedSegmentIndex];
	if (selection == 1)																					// if we're in page mode, refresh, with page 1
		[self handleModeSwitch:self.modeControl];
}

- (void)viewDidUnload {
	[self setStrataView:nil];
	[self setLocationLabel:nil];
	[self setDimensionLabel:nil];
	[self setToolbar:nil];
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
	[self setPanGestureRecognizer:nil];
	[self setPaleoCurrentSelectedView:nil];
	[self setRotationGestureRecognizer:nil];
	[self setLegendView:nil];
	[self setLegendLineContainer:nil];
	[self setLegendLineLabel:nil];
	[self setLegendLineMaterial:nil];
	[self setColumnNumber:nil];
	[self setGrainSizeLegend:nil];
	[self setStrataColumn:nil];
	[self setGrainSizeLines:nil];
	[self setSettingsButton:nil];
	[self setDocumentsButton:nil];
	[self setModeButton:nil];
	[self setModeControl:nil];
	[self setPageControl:nil];
	[self setPageViewBackground:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidUnload];
}
@end

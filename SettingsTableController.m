//
//  SettingsTableController.m
//  Strata Recorder
//
//  Created by daltman on 11/25/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "SettingsTableController.h"
#import "TabbingTextField.h"
#import "StrataNotifications.h"
#import "SectionLabelsTableViewController.h"
#import "MaterialPatternView.h"
#import "StrataModelState.h"

extern TabbingTextField *gFirstResponder;

@interface SettingsTableController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelItem;
@property (strong, nonatomic) IBOutlet UISlider *pageScaleSlider;
//@property (strong, nonatomic) IBOutlet UITextField *strataHeightText;
@property (strong, nonatomic) IBOutlet UILabel *strataHeightText;
@property (strong, nonatomic) IBOutlet UISegmentedControl *unitsSelector;
@property (strong, nonatomic) IBOutlet TabbingTextField *paperWidthText;
@property (strong, nonatomic) IBOutlet TabbingTextField *paperHeightText;
@property (strong, nonatomic) IBOutlet TabbingTextField *marginWidthText;
@property (strong, nonatomic) IBOutlet TabbingTextField *marginHeightText;
@property (strong, nonatomic) IBOutlet TabbingTextField *pageScaleText;
@property (strong, nonatomic) IBOutlet TabbingTextField *lineThicknessText;
@property (strong, nonatomic) IBOutlet UISlider *lineThicknessSlider;
@property (strong, nonatomic) IBOutlet TabbingTextField *patternScaleText;
@property (strong, nonatomic) IBOutlet UISlider *patternScaleSlider;
@property (strong, nonatomic) IBOutlet MaterialPatternView *patternSampleView;
@property (strong, nonatomic) IBOutlet UISlider *legendScaleSlider;
@property (strong, nonatomic) IBOutlet TabbingTextField *legendScaleText;
@end

@implementation SettingsTableController

- (IBAction)handleStrataHeightText:(id)sender {
	self.strataHeightText.text = [NSString stringWithFormat:@"%d", (int) self.strataHeightText.text.floatValue];
}

- (IBAction)handlePageScaleText:(id)sender {
	self.pageScaleSlider.value = self.pageScaleText.text.floatValue;
}

- (IBAction)handlePatternScaleText:(id)sender {
	self.patternScaleSlider.value = self.patternScaleText.text.floatValue;
	self.patternSampleView.patternScale = self.patternScaleSlider.value;
	[self.patternSampleView setNeedsDisplay];
}

- (IBAction)handleLegendScaleText:(id)sender {
	self.legendScaleSlider.value = self.legendScaleText.text.floatValue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	id destinationViewController = segue.destinationViewController;
	if ([destinationViewController isKindOfClass:[SectionLabelsTableViewController class]]) {
		((SectionLabelsTableViewController *)destinationViewController).activeDocument = self.activeDocument;
		((SectionLabelsTableViewController *)destinationViewController).sectionLabels = self.sectionLabels;
	} else
		NSAssert1(FALSE, @"Unexpected controller for segue: %@", destinationViewController);
}

- (IBAction)handleSave:(id)sender {
	// initialize our properties from our current control settings, so our SettingsControllerDelegate can use them to propagate changes made
	// only post notifications for properties that have changed
	if (self.strataHeightText.text.floatValue) {
		if (self.strataHeightText.text.intValue != self.strataHeight) {
			self.strataHeight = self.strataHeightText.text.intValue;
		}
	}
	if (![self.units isEqualToString:(self.unitsSelector.selectedSegmentIndex) ? @"English" : @"Metric"]) {
		self.units = (self.unitsSelector.selectedSegmentIndex) ? @"English" : @"Metric";
		[[NSNotificationCenter defaultCenter] postNotificationName:SRUnitsChangedNotification object:self];
	}
	if (self.paperWidthText.text.floatValue) {
		if (self.paperWidthText.text.floatValue != self.paperWidth) {
			self.paperWidth = self.paperWidthText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRPaperWidthChangedNotification object:self];
		}
	}
	if (self.paperHeightText.text.floatValue) {
		if (self.paperHeightText.text.floatValue != self.paperHeight) {
			self.paperHeight = self.paperHeightText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRPaperHeightChangedNotification object:self];
		}
	}
	if (self.marginWidthText.text.floatValue) {
		if (self.marginWidthText.text.floatValue != self.marginWidth) {
			self.marginWidth = self.marginWidthText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRMarginWidthChangedNotification object:self];
		}
	}
	if (self.marginHeightText.text.floatValue) {
		if (self.marginHeightText.text.floatValue != self.marginHeight) {
			self.marginHeight = self.marginHeightText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRMarginHeightChangedNotification object:self];
		}
	}
	if (self.pageScaleText.text.floatValue) {
		if (self.pageScaleText.text.floatValue != self.pageScale) {
			self.pageScale = self.pageScaleText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRPageScaleChangedNotification object:self];
		}
	}
	if (self.lineThicknessText.text.intValue) {
		if (self.lineThicknessText.text.floatValue != self.lineThickness) {
			self.lineThickness = self.lineThicknessText.text.intValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRLineThicknessChangedNotification object:self];
		}
	}
	if (self.patternScaleText.text.floatValue) {
		if (self.patternScaleText.text.floatValue != self.patternScale) {
			self.patternScale = self.patternScaleText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRPatternScaleChangedNotification object:self];
		}
	}
	if (self.legendScaleText.text.floatValue) {
		if (self.legendScaleText.text.floatValue != self.legendScale) {
			self.legendScale = self.legendScaleText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRLegendScaleChangedNotification object:self];
		}
	}
	[StrataModelState currentState].dirty = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:SRLegendScaleChangedNotification object:self];	// TODO: temporary blanket notification
	[self.delegate performSelector:@selector(handleSettingsTableComplete:) withObject:sender];					// let the delegate deal with the changed properties
}

- (IBAction)handleCancel:(id)sender {
	[self.delegate performSelector:@selector(handleSettingsTableComplete:) withObject:sender];
}

- (IBAction)handlePageScaleSlider:(id)sender {
	self.pageScaleText.text = [NSString stringWithFormat:@"%.1f", self.pageScaleSlider.value];
}

- (IBAction)handlePatternScaleSlider:(id)sender {
	self.patternScaleText.text = [NSString stringWithFormat:@"%.1f", self.patternScaleSlider.value];
	self.patternSampleView.patternScale = self.patternScaleSlider.value;
	[self.patternSampleView setNeedsDisplay];
}

- (IBAction)handleLegendScaleSlider:(id)sender {
	self.legendScaleText.text = [NSString stringWithFormat:@"%.1f", self.legendScaleSlider.value];
}

- (IBAction)handleLineThicknessSlider:(id)sender {
	self.lineThicknessText.text = [NSString stringWithFormat:@"%d", (int) self.lineThicknessSlider.value];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.toolbarItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], self.cancelItem, self.saveItem, nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleActiveDocumentSelectionChanged:) name:SRActiveDocumentSelectionChangedNotification object:nil];
	// populate the properties from active document
	self.strataHeight = self.activeDocument.strataHeight;
	self.units = self.activeDocument.units;
	self.paperWidth = self.activeDocument.pageDimension.width;
	self.paperHeight = self.activeDocument.pageDimension.height;
	self.marginWidth = self.activeDocument.pageMargins.width;
	self.marginHeight = self.activeDocument.pageMargins.height;
	self.pageScale = self.activeDocument.scale;
	self.lineThickness = self.activeDocument.lineThickness;
	self.patternScale = self.activeDocument.patternScale;
	self.legendScale = self.activeDocument.legendScale;
	self.title = [NSString stringWithFormat:@"%@ Settings", self.activeDocument.name];
	self.sectionLabels = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.activeDocument.sectionLabels]];	// deep copy
	// populate the table's controls from property values
	self.strataHeightText.text = [NSString stringWithFormat:@"%d", self.strataHeight];
	self.unitsSelector.selectedSegmentIndex = [self.units isEqualToString:@"Metric"] ? 0 : 1;

	self.paperWidthText.text = [NSString stringWithFormat:@"%.1f", self.paperWidth];
    self.paperWidthText.inputAccessoryView = self.accessoryView;
	self.paperWidthText.next = self.paperHeightText;
	self.paperWidthText.prev = self.patternScaleText;

	self.paperHeightText.text = [NSString stringWithFormat:@"%.1f", self.paperHeight];
	self.paperHeightText.inputAccessoryView = self.accessoryView;
	self.paperHeightText.next = self.marginWidthText;
	self.paperHeightText.prev = self.paperWidthText;

	self.marginWidthText.text = [NSString stringWithFormat:@"%.1f", self.marginWidth];
	self.marginWidthText.inputAccessoryView = self.accessoryView;
	self.marginWidthText.next = self.marginHeightText;
	self.marginWidthText.prev = self.paperHeightText;

	self.marginHeightText.text = [NSString stringWithFormat:@"%.1f", self.marginHeight];
	self.marginHeightText.inputAccessoryView = self.accessoryView;
	self.marginHeightText.next = self.pageScaleText;
	self.marginHeightText.prev = self.marginWidthText;

	self.pageScaleText.text = [NSString stringWithFormat:@"%.1f", self.pageScale];
	self.pageScaleText.inputAccessoryView = self.accessoryView;
	self.pageScaleText.next = self.lineThicknessText;
	self.pageScaleText.prev = self.marginHeightText;

	self.pageScaleSlider.value = self.pageScale;

	self.lineThicknessText.text = [NSString stringWithFormat:@"%d", self.lineThickness];
	self.lineThicknessText.inputAccessoryView = self.accessoryView;
	self.lineThicknessText.next = self.legendScaleText;
	self.lineThicknessText.prev = self.pageScaleText;
	
	self.lineThicknessSlider.value = self.lineThickness;

	self.patternSampleView.patternNumber = 643;															// arbitrary pattern
	self.patternSampleView.patternScale = self.patternScale;
	[self.patternSampleView setNeedsDisplay];
	self.legendScaleSlider.value = self.legendScale;

	self.legendScaleText.text = [NSString stringWithFormat:@"%.1f", self.legendScale];
	self.legendScaleText.inputAccessoryView = self.accessoryView;
	self.legendScaleText.next = self.patternScaleText;
	self.legendScaleText.prev = self.lineThicknessText;

	self.patternScaleSlider.value = self.patternScale;

	self.patternScaleText.text = [NSString stringWithFormat:@"%.1f", self.patternScale];
	self.patternScaleText.inputAccessoryView = self.accessoryView;
	self.patternScaleText.next = self.paperWidthText;
	self.patternScaleText.prev = self.legendScaleText;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.modalInPopover = YES;									// make this view modal (if it's in a popover, ignore outside clicks)
//	self.preferredContentSize = CGSizeMake(460, 577);		// TODO: get the appropriate size
	[[NSNotificationCenter defaultCenter] postNotificationName:SRPopupVisibleNotification object:self];
}

- (void)handleActiveDocumentSelectionChanged:(NSNotification *)notification
{
	self.activeDocument = [notification.userInfo objectForKey:@"activeDocument"];
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"SettingsTableController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectNextResponder:(id)sender {
	[gFirstResponder.next becomeFirstResponder];
	[gFirstResponder selectAll:self];
}

- (IBAction)selectPrevResponder:(id)sender
{
	[gFirstResponder.prev becomeFirstResponder];
	[gFirstResponder selectAll:self];
}

- (void)viewDidUnload {
	[self setStrataHeightText:nil];
	[self setUnitsSelector:nil];
	[self setPaperWidthText:nil];
	[self setPaperHeightText:nil];
	[self setPageScaleText:nil];
	[self setSaveItem:nil];
	[self setPageScaleSlider:nil];
	[self setLineThicknessText:nil];
	[self setPatternScaleText:nil];
	[self setCancelItem:nil];
	[self setMarginWidthText:nil];
	[self setMarginHeightText:nil];
	[self setPatternScaleSlider:nil];
	[self setPatternSampleView:nil];
	[self setLegendScaleSlider:nil];
	[self setLegendScaleText:nil];
	[super viewDidUnload];
}
@end

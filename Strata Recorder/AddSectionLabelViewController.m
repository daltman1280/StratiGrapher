//
//  AddSectionLabelViewController.m
//  Strata Recorder
//
//  Created by daltman on 5/28/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "AddSectionLabelViewController.h"

@interface AddSectionLabelViewController ()

@end

@implementation AddSectionLabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)handleSave:(id)sender {
	[self.delegate handleAddSectionLabel:self];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)handleCancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIImage *buttonImageNormal = [UIImage imageNamed:@"blueButton.png"];
	UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImagePressed = [UIImage imageNamed:@"darkBlueButton.png"];
	UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImageCancelNormal = [UIImage imageNamed:@"redButton.png"];
	UIImage *stretchableButtonImageCancelNormal = [buttonImageCancelNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImageCancelPressed = [UIImage imageNamed:@"darkRedButton.png"];
	UIImage *stretchableButtonImageCancelPressed = [buttonImageCancelPressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	
	[self.saveButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
	[self.saveButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
	[self.cancelButton setBackgroundImage:stretchableButtonImageCancelNormal forState:UIControlStateNormal];
	[self.cancelButton setBackgroundImage:stretchableButtonImageCancelPressed forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
 	NSLog(@"AddSectionLabelViewController didReceiveMemoryWarning");
   [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSectionLabelText:nil];
	[self setSaveButton:nil];
	[self setCancelButton:nil];
    [super viewDidUnload];
}
@end

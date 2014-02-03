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
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleCancel:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.sectionLabelText becomeFirstResponder];
	self.saveButton.enabled = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(labelTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (IBAction)labelTextDidChange:(id)sender
{
	self.saveButton.enabled = self.sectionLabelText.text.length > 0 ? YES : NO;
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}
@end

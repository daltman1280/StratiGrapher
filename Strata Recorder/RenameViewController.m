//
//  RenameViewController.m
//  Strata Recorder
//
//  Created by daltman on 11/19/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "RenameViewController.h"

@interface RenameViewController ()

@property (nonatomic) IBOutlet UIButton *renameOKButton;
@property (nonatomic) IBOutlet UIButton *renameCancelButton;

@end

@implementation RenameViewController

- (IBAction)handleRenameConfirm:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
	if (sender != self.renameOKButton) return;
	self.currentName = self.renameText.text;
	[self.delegate performSelector:@selector(handleRenameDocument:) withObject:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// setup Rename buttons
	UIImage *buttonImageNormal = [UIImage imageNamed:@"redButton.png"];
	UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImagePressed = [UIImage imageNamed:@"darkRedButton.png"];
	UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImageCancelNormal = [UIImage imageNamed:@"blueButton.png"];
	UIImage *stretchableButtonImageCancelNormal = [buttonImageCancelNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImageCancelPressed = [UIImage imageNamed:@"darkBlueButton.png"];
	UIImage *stretchableButtonImageCancelPressed = [buttonImageCancelPressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	
	[self.renameOKButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
	[self.renameOKButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
	self.renameOKButton.enabled = NO;
	[self.renameCancelButton setBackgroundImage:stretchableButtonImageCancelNormal forState:UIControlStateNormal];
	[self.renameCancelButton setBackgroundImage:stretchableButtonImageCancelPressed forState:UIControlStateHighlighted];
	
	self.renameText.text = self.currentName;												// should have been initialized in prepareForSegue
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (IBAction)renameTextDidChange:(id)sender
{
	if (self.renameText.text.length == 0)
		self.renameOKButton.enabled = NO;
	else if ([self.strataFiles containsObject:self.renameText.text])
		self.renameOKButton.enabled = NO;
	else
		self.renameOKButton.enabled = YES;
}


- (void)didReceiveMemoryWarning
{
	NSLog(@"RenameViewController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	self.renameOKButton = nil;
	[self setRenameOKButton:nil];
	[self setRenameCancelButton:nil];
	[self setRenameText:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self setRenameText:nil];
	[super viewDidUnload];
}
@end

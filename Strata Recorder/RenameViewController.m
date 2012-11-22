//
//  RenameViewController.m
//  Strata Recorder
//
//  Created by daltman on 11/19/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "RenameViewController.h"

@interface RenameViewController ()

@property (weak, nonatomic) IBOutlet UIButton *renameOKButton;
@property (weak, nonatomic) IBOutlet UIButton *renameCancelButton;
@property (weak, nonatomic) IBOutlet UITextField *renameText;

@end

@implementation RenameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)handleRenameConfirm:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
	if (sender != self.renameOKButton) return;
//	[[TermPaperModel activeTermPaper] rename:renameText.text];
//	[self.tableView reloadData];
//	[self handlePaperPick:renameText.text];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
	[self.renameCancelButton setBackgroundImage:stretchableButtonImageCancelNormal forState:UIControlStateNormal];
	[self.renameCancelButton setBackgroundImage:stretchableButtonImageCancelPressed forState:UIControlStateHighlighted];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (IBAction)renameTextDidChange:(id)sender
{
	if (self.renameText.text.length == 0)
		self.renameOKButton.enabled = NO;
	else if ([self.modelNames containsObject:self.renameText.text])
		self.renameOKButton.enabled = NO;
	else
		self.renameOKButton.enabled = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	self.renameOKButton = nil;
	[self setRenameOKButton:nil];
	[self setRenameCancelButton:nil];
	[self setRenameText:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidUnload];
}
@end

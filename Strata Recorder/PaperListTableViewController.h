//
//  PaperListTableViewController.h
//  TermPaper
//
//  Created by daltman on 6/23/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
//#import "TermPaperModel.h"
//#import "PaperDetailTableViewController.h"
//#import "CitationListTableViewController.h"
//#import "TermPaperTextViewController.h"

@interface RenameViewController : UIViewController {

}

@end

@interface ModelListTableViewController : UITableViewController <UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {
//	IBOutlet TermPaperTextViewController*		viewController;
	NSArray*									paperNames;					// paper name strings
//	IBOutlet PaperDetailTableViewController*	paperDetailTableController;
//	IBOutlet CitationListTableViewController*	citationTableController;
	UIPopoverController*						popoverViewController;

	IBOutlet UIBarButtonItem*					addPaper;
	IBOutlet UIBarButtonItem*					deletePaper;
	IBOutlet UIBarButtonItem*					renamePaper;
	IBOutlet UIBarButtonItem*					duplicatePaper;
	IBOutlet UIBarButtonItem*					actionPaper;

	UIActionSheet*								deletePaperActionSheet;
	UIActionSheet*								exportPaperActionSheet;
	BOOL										exportPaperActionSheetVisible;
	
	IBOutlet UINavigationController*			parentNavigationController;
	RenameViewController*						renameDocumentViewController;
	IBOutlet UIView*							renameDialog;
	IBOutlet UITextField*						renameText;
	IBOutlet UIButton*							renameOKButton;
	IBOutlet UIButton*							renameCancelButton;
	
	IBOutlet UIToolbar*							toolbar;
}

- (void)setDeleteButtonEnabled;
- (IBAction)handleAddPaper:(id)sender;
- (IBAction)handleDeletePaper:(id)sender;
- (IBAction)handleRenamePaper:(id)sender;
- (IBAction)handleRenameConfirm:(id)sender;
- (IBAction)handleDuplicatePaper:(id)sender;
- (IBAction)handleActionPaper:(id)sender;
- (IBAction)handleEmailFeedbackButton:(id)sender;
- (IBAction)handleExportPDFButton:(id)sender;
- (IBAction)handleEmailPDFButton:(id)sender;
- (IBAction)handleExportDOCXButton:(id)sender;
- (IBAction)handleEmailDOCXButton:(id)sender;
- (IBAction)handlePaperPick:(NSString *)selectedPaperName;

// following properties are initialized by the owner after instantiation
@property (nonatomic, retain) NSArray* paperNames;
@property (nonatomic, retain) UIPopoverController *popoverViewController;
@property (nonatomic) BOOL exportPaperActionSheetVisible;
@end


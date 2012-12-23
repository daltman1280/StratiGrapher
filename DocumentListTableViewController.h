//
//  DocumentListTableViewController.h
//  Strata Recorder
//
//  Created by daltman on 11/18/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DocumentListTableViewController : UITableViewController <UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {
	
	UIActionSheet*								exportPaperActionSheet;
	UIActionSheet*								deletePaperActionSheet;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addDocument;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteDocument;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *renameDocument;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *duplicateDocument;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionDocument;
@property id									delegate;
@property StrataDocument*						activeDocument;

@end

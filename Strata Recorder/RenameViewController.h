//
//  RenameViewController.h
//  Strata Recorder
//
//  Created by daltman on 11/19/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RenameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField*	renameText;
@property NSString*									currentName;
@property NSArray*									strataFiles;
@property id										delegate;

@end

//
//  SettingsTableController.h
//  Strata Recorder
//
//  Created by daltman on 11/25/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataModel.h"

@interface SettingsTableController : UITableViewController {
	
}

@property id				delegate;
@property StrataDocument*	activeDocument;

//	document properties
@property int				strataHeight;
@property NSString*			units;
@property float				paperWidth;
@property float				paperHeight;
@property float				marginWidth;
@property float				marginHeight;
@property float				pageScale;
@property int				lineThickness;
@property float				patternScale;
@property float				legendScale;
@property NSMutableArray*	sectionLabels;
@property (strong, nonatomic) IBOutlet UIView *accessoryView;

@end

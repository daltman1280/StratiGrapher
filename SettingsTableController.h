//
//  SettingsTableController.h
//  Strata Recorder
//
//  Created by daltman on 11/25/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableController : UITableViewController {
	
}

@property id delegate;
@property (weak, nonatomic) IBOutlet UITextField *strataHeight;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSelector;
@property (weak, nonatomic) IBOutlet UITextField *paperWidth;
@property (weak, nonatomic) IBOutlet UITextField *paperHeight;
@property (weak, nonatomic) IBOutlet UITextField *pageScale;

@end

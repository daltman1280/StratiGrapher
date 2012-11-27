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

@property id		delegate;
@property int		strataHeight;
@property NSString*	units;
@property float		paperWidth;
@property float		paperHeight;
@property float		pageScale;
@property int		lineThickness;

@end

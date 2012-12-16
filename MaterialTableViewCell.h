//
//  MaterialTableViewCell.h
//  Strata Recorder
//
//  Created by Don Altman on 11/15/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaterialPatternView.h"

@interface MaterialTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet UITextField *title;
@property (nonatomic) IBOutlet UILabel *subtitle;
@property (nonatomic) IBOutlet MaterialPatternView *pattern;

@end

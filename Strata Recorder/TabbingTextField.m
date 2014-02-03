//
//  TabbingTextField.m
//  StratiGrapher
//
//  Created by daltman on 2/2/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import "TabbingTextField.h"

TabbingTextField *gFirstResponder;

@implementation TabbingTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 This UITextField subclass is used for the cell's accessoryView. It saves NSIndexPath to next and previous cell for tabbing. It saves the current first responder
 to be used when the user selects the Next or Previous keyboard accessory button.
 */

- (BOOL)becomeFirstResponder
{
	gFirstResponder = self;
	return [super becomeFirstResponder];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

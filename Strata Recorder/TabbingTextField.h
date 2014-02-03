//
//  TabbingTextField.h
//  StratiGrapher
//
//  Created by daltman on 2/2/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabbingTextField : UITextField

@property TabbingTextField*				next;
@property TabbingTextField*				prev;

@end

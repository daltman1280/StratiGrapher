//
//  BlueViewController.h
//  StratiGrapher
//
//  Created by daltman on 1/7/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlueViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (weak, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property int pageNumber;

@end

@interface BlueView : UIView

@end
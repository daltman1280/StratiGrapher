//
//  StrataPageView.h
//  Strata Recorder
//
//  Created by Don Altman on 11/16/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrataModel.h"

typedef enum {
	graphMode,
	PDFMode
} drawMode;

@interface StrataPageView : UIView

@property (nonatomic) StrataDocument*			activeDocument;
@property CGPDFPageRef							patternsPage;
@property drawMode								mode;

@end

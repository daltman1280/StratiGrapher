//
//  LegendView.m
//  Strata Recorder
//
//  Created by daltman on 6/16/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "LegendView.h"
#import "StrataNotifications.h"

@interface LegendView()

@property int					numberOfLines;
@property NSMutableArray*		addedLines;
@property float					initialHeight;

@end

@implementation LegendView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
	self.addedLines = [[NSMutableArray alloc] init];
	self.initialHeight = self.bounds.size.height;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleActiveDocumentSelectionChanged:) name:SRActiveDocumentSelectionChanged object:nil];
}

- (void)handleActiveDocumentSelectionChanged:(NSNotification *)notification
{
	self.activeDocument = [notification.userInfo objectForKey:@"activeDocument"];
}

/*
 
 Method of rendering UILabels in PDF in vector mode instead of bitmap mode:
 
 http://stackoverflow.com/questions/6423059/rendering-a-uiview-into-a-pdf-as-vectors-on-an-ipad-sometimes-renders-as-bitma
 
 The only way I found to make it so labels are rendered vectorized is to use a subclass of UILabel with the following method:
 
 // Overriding this CALayer delegate method is the magic that allows us to draw a vector version of the label into the layer instead of the default unscalable ugly bitmap
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    BOOL isPDF = !CGRectIsEmpty(UIGraphicsGetPDFContextBounds());
    if (!layer.shouldRasterize && isPDF)
        [self drawRect:self.bounds]; // draw unrasterized
    else
        [super drawLayer:layer inContext:ctx];
}

 */

- (void)addLineToLegend:(NSString *)materialName materialNumber:(int)materialNumber
{
	if (self.numberOfLines == 0) {
		self.legendLineMaterial.patternNumber = materialNumber;
		self.legendLineLabel.text = materialName;
		CGRect legendViewBounds = self.bounds;
		legendViewBounds.size.height = self.initialHeight;
		self.bounds = legendViewBounds;
		++self.numberOfLines;
	} else {
		NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:self.legendLineContainer];
		UIView *newLegendLine = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
		CGRect legendViewBounds = self.bounds;
		legendViewBounds.size.height += self.legendLineContainer.bounds.size.height;
		self.bounds = legendViewBounds;
		[self addSubview:newLegendLine];
		CGRect newLegendLineFrame = newLegendLine.frame;
		newLegendLineFrame.origin.y += newLegendLineFrame.size.height*self.numberOfLines;
		newLegendLine.frame = newLegendLineFrame;
		MaterialPatternView *newPatternView = (MaterialPatternView *)[newLegendLine viewWithTag:1];
		newPatternView.patternNumber = materialNumber;
		UILabel *newLabel = (UILabel *)[newLegendLine viewWithTag:2];
		newLabel.text = materialName;
		++self.numberOfLines;
		[self.addedLines addObject:newLegendLine];
	}
}

- (void)populateLegend
{
	if (!self.activeDocument) return;
	self.numberOfLines = 0;
	for (UIView *view in self.addedLines)
		[view removeFromSuperview];
	[self.addedLines removeAllObjects];
	NSMutableSet *materialNumbers = [[NSMutableSet alloc] init];
	for (Stratum *stratum in self.activeDocument.strata) {
		[materialNumbers addObject:[NSNumber numberWithInt:stratum.materialNumber]];
	}
	NSString *descriptions = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"patterns descriptive text" ofType:@"txt"] encoding:NSASCIIStringEncoding error:nil];
	for (NSNumber *materialNumber in materialNumbers) {
		for (NSString *line in [descriptions componentsSeparatedByString:@"\n"]) {										// look for a material whose number matches materialNumber
			if ([[line substringToIndex:3] intValue] == [materialNumber intValue]) {
				NSString *description = [line substringFromIndex:4];
				int materialNumberInt = [[line substringToIndex:3] intValue];
				[self addLineToLegend:description materialNumber:materialNumberInt];
			}
		}
	}
	[self setNeedsDisplay];
//	[self addLineToLegend:@"line 1" materialNumber:601];
//	[self addLineToLegend:@"line 2" materialNumber:602];
//	[self addLineToLegend:@"line 3" materialNumber:603];
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

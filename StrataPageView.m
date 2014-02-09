//
//  StrataPageView.m
//  Strata Recorder
//
//  Created by Don Altman on 11/16/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#define XORIGIN 0.0												// distance in inches of origin from LL of view
#define YORIGIN 0.0												// distance in inches of origin from LL of view

#import "StrataPageView.h"
#import "StrataView.h"											// pattern drawing
#import "Graphics.h"
#import "StrataNotifications.h"

@interface StrataPageView ()

@property float				columnVerticalMargin;
@property float				columnNumberHorizontalUnderhang;
@property float				columnNumberVerticalLocation;
@property NSMutableArray*	maxWidths;							// for each column, its width, in inches
@property NSMutableArray*	minGrainSizeIndices;				// for each column, the minimum grain size index
@property NSMutableArray*	maxGrainSizeIndices;				// for each column, the maximum grain size index
@property NSMutableArray*	maxStratumIndexForPage;				// initialized by setupPages, used by drawRect
@property NSMutableArray*	minColumnIndexForPage;				// initialized by setupPages, used by drawRect

@end

@implementation StrataPageView

- (void)setActiveDocument:(StrataDocument *)activeDocument
{
	_activeDocument = activeDocument;
	self.bounds = CGRectMake(0, 0, self.activeDocument.pageDimension.width*PPI, self.activeDocument.pageDimension.height*PPI);
	self.frame = self.bounds;
	self.arrowIcon.bounds = self.bounds;						// bounds for icons must also be updated
}

//	do initialization here

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	self.origin = CGPointMake(XORIGIN, YORIGIN);
	self.arrowIcon = [[IconImage alloc] initWithImageName:@"paleocurrent greyscale.png" offset:CGPointMake(.5, .5) width:25 viewBounds:self.bounds viewOrigin:self.origin];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleActiveDocumentSelectionChanged:) name:SRActiveDocumentSelectionChangedNotification object:nil];
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleActiveDocumentSelectionChanged:(NSNotification *)notification
{
	self.activeDocument = [notification.userInfo objectForKey:@"activeDocument"];
}

// convert from unit to view coordinates

- (CGRect)RectUtoV:(CGRect)rect
{
	return CGRectMake(VX(rect.origin.x), VY(rect.origin.y), VDX(rect.size.width), VDY(rect.size.height));
}

- (void)drawCrossmark:(float)x y:(float)y
{
	float scale = self.activeDocument.scale;
	UIBezierPath *bleed = [UIBezierPath bezierPath];
	[bleed moveToPoint:CGPointMake(VX(x-.1/scale), VY(y))];
	[bleed addLineToPoint:CGPointMake(VX(x+.1/scale), VY(y))];
	[bleed moveToPoint:CGPointMake(VX(x), VY(y-.1/scale))];
	[bleed addLineToPoint:CGPointMake(VX(x), VY(y+.1/scale))];
	BOOL drawCrossmarks = NO;
	if (drawCrossmarks)
		[bleed stroke];
}

/*
 Draw column number and grain size legend underneath strata column.
 
 columnNumber: 1 based
 columnOrigin: in user units
 minGrainSizeIndex: sets lower limit of grain size legend for this column (1 based)
 maxGrainSizeIndex: sets upper limit of grain size legend for this column (1 based)
 */

- (void)drawColumnAdornments:(int)columnNumber columnOrigin:(CGPoint)columnOrigin minGrainSizeIndex:(int)minGrainSizeIndex maxGrainSizeIndex:(int)maxGrainSizeIndex
{
	// fix, in case old versions of document do not have correct grainSizeIndex for each stratum
	if (maxGrainSizeIndex < 0) return;
	if (minGrainSizeIndex <= 0) minGrainSizeIndex = 1;
	if (maxGrainSizeIndex < minGrainSizeIndex) maxGrainSizeIndex = minGrainSizeIndex;
	{	// column number
		CGContextRef tempContext = UIGraphicsGetCurrentContext();
		CGContextSaveGState(tempContext);
		CGPoint columnTextOrigin;																		// in view units
		NSString *columnText = [NSString stringWithFormat:@"%d", columnNumber];
		UIFont *font = [UIFont systemFontOfSize:26.0];
		columnTextOrigin.x = VX(columnOrigin.x)+self.columnNumberHorizontalUnderhang;
		columnTextOrigin.y = self.columnNumberVerticalLocation;
		CGContextTranslateCTM(UIGraphicsGetCurrentContext(), columnTextOrigin.x, columnTextOrigin.y);
		CGFloat colorComponentsBlack[4] = {0, 0, 0, 1.};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGColorRef colorBlack = CGColorCreate(colorSpace, colorComponentsBlack);
		CGContextSetStrokeColorWithColor(tempContext, colorBlack);
		CFRelease(colorSpace);
		CGContextSetFillColorWithColor(tempContext, colorBlack);										// to counteract CGContextSetFillColorSpace and CGContextSetFillPattern
		CGColorRelease(colorBlack);
        [columnText drawAtPoint:CGPointZero withAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
		CGContextRestoreGState(tempContext);
	}
	{	// grain sizes
		CGContextRef tempContext = UIGraphicsGetCurrentContext();
		CGContextSaveGState(tempContext);
		CGPoint columnGrainPoint;
		UIFont *font = [UIFont systemFontOfSize:10.0];
		CGSize sizeOfGrainText = [@"dummy" sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
		// origin of first grain size legend text
		columnGrainPoint.x = VX(columnOrigin.x+(1.0+(float)(minGrainSizeIndex-1)/4.0)/self.activeDocument.scale)-sizeOfGrainText.height/2.0;	// split height of text in half to straddle line
		// the VY transform will account for page size, and the rest consists of offsets between labels, in view coordinates
		columnGrainPoint.y = VY(self.activeDocument.pageMargins.height)-
			self.columnNumber.frame.size.height-(self.columnNumber.frame.origin.y-self.grainSizeLegend.frame.origin.y)+self.grainSizeLegend.frame.size.height;
		CGContextTranslateCTM(UIGraphicsGetCurrentContext(), columnGrainPoint.x, columnGrainPoint.y);
		CGContextRotateCTM(UIGraphicsGetCurrentContext(), -M_PI_2);
		CGFloat colorComponentsBlack[4] = {0, 0, 0, 1.};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGColorRef colorBlack = CGColorCreate(colorSpace, colorComponentsBlack);
		CGContextSetStrokeColorWithColor(tempContext, colorBlack);
		CFRelease(colorSpace);
		CGContextSetFillColorWithColor(tempContext, colorBlack);										// to counteract CGContextSetFillColorSpace and CGContextSetFillPattern
		CGColorRelease(colorBlack);
		for (int i=minGrainSizeIndex; i<=maxGrainSizeIndex; ++i) {
			const NSString *grainText = gAbbreviatedGrainSizeNames[i-1];
            [grainText drawAtPoint:CGPointZero withAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]]; // text rotated by 90 degrees (rotated context)
			// vertical lines for each legend entry
			UIBezierPath *path = [UIBezierPath bezierPath];
			// use grainSizeLegend label to establish lower & upper limits of X coordinates (in our rotated context)
			[path moveToPoint:CGPointMake((self.grainSizeLegend.frame.origin.y+self.grainSizeLegend.frame.size.height)-(self.grainSizeLines.frame.origin.y+self.grainSizeLines.frame.size.height), sizeOfGrainText.height/2.0)];
			[path addLineToPoint:CGPointMake((self.grainSizeLegend.frame.origin.y+self.grainSizeLegend.frame.size.height)-(self.grainSizeLines.frame.origin.y), sizeOfGrainText.height/2.0)];
			[path stroke];
			CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, -VDY(0.25)/self.activeDocument.scale);		// our context is rotated 90 degrees, translate downwards to achieve horizontal spacing
		}
		CGContextRestoreGState(tempContext);
	}
}

- (void)setupPages
{
	// distance, in user units, from bottom page margin to bottom of strata column (to allow for column adornments)
	_columnVerticalMargin = -UDY(_columnNumber.frame.origin.y+_columnNumber.frame.size.height-_strataColumn.frame.origin.y-_strataColumn.frame.size.height);
	_columnNumberHorizontalUnderhang = _columnNumber.frame.origin.x-_strataColumn.frame.origin.x;					// in view units, column number is horizontally inset
	_columnNumberVerticalLocation = VY(_activeDocument.pageMargins.height)-_columnNumber.frame.size.height;			// at bottom page margin
	_maxPageIndex = 0;
	// horizontal and vertical stratum adjustments, in inches, which take into account column membership of a stratum
	CGPoint offset = CGPointMake(0, _activeDocument.pageMargins.height+_columnVerticalMargin);						// don't need x offset at this point, just calculating column widths
	float scale = _activeDocument.scale;
	float pageTop = _activeDocument.pageDimension.height-_activeDocument.pageMargins.height;
	float sectionLabelsMargin = _activeDocument.sectionLabels.count > 0 ? .1 : 0;									// horizontal distance between widest stratum and label, in inches
	
	// calculate maximum width of each strata column
	_maxWidths = [[NSMutableArray alloc] init];																		// for each column, its width, in inches
	float maxWidthTemp = 0;
	for (Stratum *stratum in _activeDocument.strata) {
		CGRect stratumRect = CGRectMake(stratum.frame.origin.x/scale, stratum.frame.origin.y/scale, stratum.frame.size.width/scale, stratum.frame.size.height/scale);
		stratumRect = CGRectStandardize(stratumRect);
		stratumRect = CGRectOffset(stratumRect, offset.x, offset.y);
		float stratumTop = stratumRect.origin.y+stratumRect.size.height;
		if (stratumTop > pageTop || stratum.hasPageCutter) {														// reached top of column, need to start a new column
			stratumRect = CGRectOffset(stratumRect, -offset.x, -offset.y);											// undo the offset from current column
			offset.y = -stratumRect.origin.y+_activeDocument.pageMargins.height+_columnVerticalMargin;				// vertical adjustment to make stratum sit on base page margin
			[_maxWidths addObject:[NSNumber numberWithFloat:maxWidthTemp/scale+sectionLabelsMargin]];				// in inches
			maxWidthTemp = stratum.frame.size.width;																// reinitialize it with width of current stratum
		} else
			if (stratum.frame.size.width > maxWidthTemp) maxWidthTemp = stratum.frame.size.width;
	}
	[_maxWidths addObject:[NSNumber numberWithFloat:maxWidthTemp/scale+sectionLabelsMargin]];						// last column
	
	// calculate minimum and maximum grain size indices of each strata column
	_minGrainSizeIndices = [[NSMutableArray alloc] init];															// for each column, the minimum grain size index
	_maxGrainSizeIndices = [[NSMutableArray alloc] init];															// for each column, the maximum grain size index
	_maxStratumIndexForPage = [[NSMutableArray alloc] init];														// for each page, the index of the last stratum that appears
	_minColumnIndexForPage = [[NSMutableArray alloc] init];															// for each page, the starting column index
	[_minColumnIndexForPage addObject:[NSNumber numberWithInt:0]];
	int minGrainSizeIndexTemp = 100;
	int maxGrainSizeIndexTemp = -1;
	int columnIndex = 0;
	// initial offset in user units
	offset = CGPointMake(_activeDocument.pageDimension.width-_activeDocument.pageMargins.width-[_maxWidths[columnIndex] floatValue], _activeDocument.pageMargins.height+_columnVerticalMargin);
	for (Stratum *stratum in _activeDocument.strata) {
		CGRect stratumRect = CGRectMake(stratum.frame.origin.x/scale, stratum.frame.origin.y/scale, stratum.frame.size.width/scale, stratum.frame.size.height/scale);
		stratumRect = CGRectStandardize(stratumRect);
		if (stratumRect.size.width == 0) break;																		// last stratum is empty, ignore it
		stratumRect = CGRectOffset(stratumRect, offset.x, offset.y);
		float stratumTop = stratumRect.origin.y+stratumRect.size.height;
		if (stratumTop > pageTop || stratum.hasPageCutter) {														// reached top of column, need to start a new column
			stratumRect = CGRectOffset(stratumRect, -offset.x, -offset.y);											// undo the offset from current column
			offset.x -= [_maxWidths[++columnIndex] floatValue]+_activeDocument.pageMargins.width/2.0;				// horizontal adjustment using maxwidth, and adding half of horizontal page margin
			if (offset.x < _activeDocument.pageMargins.width) {														// we've overflowed the current page, in horizontal direction
				[_maxStratumIndexForPage addObject:[NSNumber numberWithInt:[_activeDocument.strata indexOfObject:stratum]-1]];
				offset.x = _activeDocument.pageDimension.width-_activeDocument.pageMargins.width-[_maxWidths[columnIndex] floatValue];
				[_minColumnIndexForPage addObject:[NSNumber numberWithInt:columnIndex]];
				++_maxPageIndex;
			}
			offset.y = -stratumRect.origin.y+_activeDocument.pageMargins.height+_columnVerticalMargin;				// vertical adjustment to make stratum sit on base page margin
			[_minGrainSizeIndices addObject:[NSNumber numberWithInt:minGrainSizeIndexTemp]];
			[_maxGrainSizeIndices addObject:[NSNumber numberWithInt:maxGrainSizeIndexTemp]];
			minGrainSizeIndexTemp = maxGrainSizeIndexTemp = (int) stratum.grainSizeIndex;
		} else {
			int grainSizeIndex = stratum.grainSizeIndex;
			if (grainSizeIndex > maxGrainSizeIndexTemp) maxGrainSizeIndexTemp = grainSizeIndex;
			if (grainSizeIndex < minGrainSizeIndexTemp) minGrainSizeIndexTemp = grainSizeIndex;
		}
	}
	[_minGrainSizeIndices addObject:[NSNumber numberWithInt:minGrainSizeIndexTemp]];								// last column
	[_maxGrainSizeIndices addObject:[NSNumber numberWithInt:maxGrainSizeIndexTemp]];
	[_maxStratumIndexForPage addObject:[NSNumber numberWithInt:_activeDocument.strata.count-1]];					// last stratum
	++_maxPageIndex;																								// legend
}

- (void)exportPDF
{
	[self setupPages];
	_mode = PDFMode;
	NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *pdfFile = [documentsFolder stringByAppendingFormat:@"/%@.pdf", _activeDocument.name];
	CGRect bounds = CGRectMake(0, 0, _activeDocument.pageDimension.width*72., _activeDocument.pageDimension.height*72.);
	UIGraphicsBeginPDFContextToFile(pdfFile, bounds, [NSDictionary dictionaryWithObject:(id)kCGPDFContextMediaBox forKey:[NSData dataWithBytes:&bounds length:sizeof(bounds)]]);
	for (int pageIndex = 0; pageIndex < _maxPageIndex; ++pageIndex) {
		UIGraphicsBeginPDFPage();
		_pageIndex = pageIndex;
		[self drawRect:CGRectZero];
	}
	UIGraphicsBeginPDFPage();
	_pageIndex = _maxPageIndex;																					// legend on last page
	_legendView.hidden = NO;
	[self drawRect:CGRectZero];
	UIGraphicsEndPDFContext();
	_mode = graphMode;
}

- (void)dropboxPDF
{
	[self exportPDF];
	NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *pdfFile = [NSString stringWithFormat:@"%@.pdf", _activeDocument.name];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.restClient uploadFile:pdfFile toPath:@"/" withParentRev:nil fromPath:[documentsFolder stringByAppendingPathComponent:pdfFile]];
	});
}

- (DBRestClient *)restClient {
	if (!_restClient) {
		_restClient =
		[[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return _restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
			  from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
	
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Can\'t access Dropbox" delegate:nil cancelButtonTitle:@"" destructiveButtonTitle:@"OK" otherButtonTitles:@"", nil];
	sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[sheet showInView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view];
}

- (void)drawRect:(CGRect)rect
{
	if (_pageIndex == _maxPageIndex) {
		if (_mode == PDFMode) {
			CGContextTranslateCTM(UIGraphicsGetCurrentContext(), _activeDocument.pageMargins.width*72., _activeDocument.pageMargins.height*72.);
			CGContextScaleCTM(UIGraphicsGetCurrentContext(), 72./PPI*_activeDocument.legendScale, 72./PPI*_activeDocument.legendScale);
		} else {
			CGContextTranslateCTM(UIGraphicsGetCurrentContext(), _activeDocument.pageMargins.width*PPI, _activeDocument.pageMargins.height*PPI);
			CGContextScaleCTM(UIGraphicsGetCurrentContext(), _activeDocument.legendScale, _activeDocument.legendScale);
		}
		_legendView.hidden = NO;
		[_legendView.layer renderInContext:UIGraphicsGetCurrentContext()];										// render the legend on a separate page
		return;
	}
	_legendView.hidden = YES;
	gTransparent = NO;
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	if (_mode == PDFMode)																						// PDF context has different resolution (72 DPI) so it has to be scaled down
		CGContextScaleCTM(currentContext, 72./PPI, 72./PPI);
	// setup colors
	CGFloat colorComponentsBlack[4] = {0, 0, 0, 1.};
	CGFloat colorComponentsWhite[4] = {1, 1, 1, 1.};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef colorBlack = CGColorCreate(colorSpace, colorComponentsBlack);
	CGColorRef colorWhite = CGColorCreate(colorSpace, colorComponentsWhite);
	CGContextSetStrokeColorWithColor(currentContext, colorBlack);
	CFRelease(colorSpace);
	CGContextSetLineWidth(currentContext, 3);
	// draw scale indicator at lower left of page
	CGContextBeginPath(currentContext);
	CGContextMoveToPoint(currentContext, VX(_activeDocument.pageMargins.width), VY(_activeDocument.pageMargins.height));
	CGContextAddLineToPoint(currentContext, VX(_activeDocument.pageMargins.width), VY(_activeDocument.pageMargins.height+1/_activeDocument.scale));
	CGContextClosePath(currentContext);
	CGContextStrokePath(currentContext);
	CGContextSaveGState(currentContext);
	CGContextTranslateCTM(currentContext, VDX(_activeDocument.pageMargins.width), -VDY(_activeDocument.pageDimension.height-_activeDocument.pageMargins.height));
	CGContextRotateCTM(currentContext, -M_PI_2);
	[[_activeDocument.units isEqualToString:@"Metric"] ? @"1 Meter" : @"1 Foot" drawAtPoint:CGPointZero withAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:10] forKey:NSFontAttributeName]];
	CGContextRestoreGState(currentContext);
	// setup patterns
	struct CGPatternCallbacks patternCallbacks = {
		0, &patternDrawingCallback, 0
	};
	CGFloat alpha = 1;
	gPageArray = _patternsPageArray;																			// global variable used by pattern drawing callback
	// apparently, we need to do this in the current context, can't cache it
	CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
	CGContextSetFillColorSpace(currentContext, patternSpace);
	CGColorSpaceRelease(patternSpace);
	// setup graphic attributes for drawing strata rectangles
	CGContextSetLineWidth(currentContext, _activeDocument.lineThickness);
	float scale = _activeDocument.scale;
	float pageTop = _activeDocument.pageDimension.height-_activeDocument.pageMargins.height;
	gScale = 1;
	int indexOfInitialStratum = _pageIndex > 0 ? [_maxStratumIndexForPage[_pageIndex-1] intValue]+1 : 0;
	int sectionIndex = 0;																						// index of current section for current page
	int stratumSectionLower = -1;																				// index of first stratum for current section label
	int stratumSectionUpper = -1;																				// index of last stratum for current section label
	for (int i=0, accum=0; i<_activeDocument.sectionLabels.count; ++i) {										// iterate section labels to find index of first label that applies to this stratum
		accum += ((SectionLabel *)_activeDocument.sectionLabels[i]).numberOfStrataSpanned;
		sectionIndex = i;
		stratumSectionLower = stratumSectionUpper + 1;
		stratumSectionUpper = stratumSectionLower + ((SectionLabel *)_activeDocument.sectionLabels[sectionIndex]).numberOfStrataSpanned-1;
		if (accum >= indexOfInitialStratum) {
			stratumSectionLower = indexOfInitialStratum;														// first stratum of page
			break;
		}
	}
	int columnIndex = [_minColumnIndexForPage[_pageIndex] intValue];
	Stratum *initialStratum = _activeDocument.strata[indexOfInitialStratum];
	// initial offset in user units
	CGPoint offset = CGPointMake(_activeDocument.pageDimension.width-_activeDocument.pageMargins.width-[_maxWidths[columnIndex] floatValue], _activeDocument.pageMargins.height+_columnVerticalMargin- initialStratum.frame.origin.y/scale);
	
	// draw strata
	for (int indexOfStratum = indexOfInitialStratum; indexOfStratum <= [_maxStratumIndexForPage[_pageIndex] intValue]; ++indexOfStratum) {
		Stratum *stratum = _activeDocument.strata[indexOfStratum];
		Stratum *nextStratum = indexOfStratum < _activeDocument.strata.count-1 ? _activeDocument.strata[indexOfStratum+1] : nil;
		CGRect stratumRect = CGRectMake(stratum.frame.origin.x/scale, stratum.frame.origin.y/scale, stratum.frame.size.width/scale, stratum.frame.size.height/scale);
		stratumRect = CGRectStandardize(stratumRect);
		stratumRect = CGRectOffset(stratumRect, offset.x, offset.y);											// stratumRect is now offset (for column) and scaled, in user units
		float stratumTop = stratumRect.origin.y+stratumRect.size.height;
		if (indexOfStratum == indexOfInitialStratum)															// draw adornments for first column
			[self drawColumnAdornments:columnIndex+1 columnOrigin:stratumRect.origin minGrainSizeIndex:[_minGrainSizeIndices[columnIndex] intValue] maxGrainSizeIndex:[_maxGrainSizeIndices[columnIndex] intValue]];
		// offset stratum rectangle for new column
		if (stratumTop > pageTop || (stratum.hasPageCutter && indexOfStratum != indexOfInitialStratum)) {		// reached top of column, need to start a new column
			stratumRect = CGRectOffset(stratumRect, -offset.x, -offset.y);										// undo the offset from current column
			offset.x -= [_maxWidths[++columnIndex] floatValue]+_activeDocument.pageMargins.width/2.0;			// horizontal adjustment using maxwidth, and adding half of horizontal page margin
			offset.y = -stratumRect.origin.y+_activeDocument.pageMargins.height+_columnVerticalMargin;			// vertical adjustment to make stratum sit on base page margin
			stratumRect = CGRectOffset(stratumRect, offset.x, offset.y);										// give it the same offset as succeeding strata in next column
			stratumTop = stratumRect.origin.y+stratumRect.size.height;											// recalculate it in new column
			[self drawColumnAdornments:columnIndex+1 columnOrigin:stratumRect.origin
					 minGrainSizeIndex:[_minGrainSizeIndices[columnIndex] intValue]
					 maxGrainSizeIndex:[_maxGrainSizeIndices[columnIndex] intValue]];							// for subsequent columns
		}
		// need to draw a section label?
		if (stratumSectionUpper > -1 && (stratumTop > pageTop || nextStratum.hasPageCutter || indexOfStratum == stratumSectionUpper)) {
			float xSectionBottom, ySectionBottom, xSectionTop, ySectionTop;
			NSString *labelText = ((SectionLabel *)_activeDocument.sectionLabels[sectionIndex]).labelText;
			UIFont *font = [UIFont systemFontOfSize:18.0];
			CGSize sizeOfLabelText = [labelText sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
			xSectionBottom = ((Stratum *)_activeDocument.strata[stratumSectionLower]).frame.origin.x/scale + offset.x + [_maxWidths[columnIndex] floatValue];
			ySectionBottom = ((Stratum *)_activeDocument.strata[stratumSectionLower]).frame.origin.y/scale + offset.y;
			xSectionTop = stratum.frame.origin.x/scale + offset.x + [_maxWidths[columnIndex] floatValue];
			ySectionTop = stratum.frame.origin.y/scale + stratum.frame.size.height/scale + offset.y;
			if ((stratumTop > pageTop || nextStratum.hasPageCutter) && indexOfStratum < stratumSectionUpper)	// we're at the end of a column, need to draw section label, even if more strata remain
				;
			else																								// normal case
				++sectionIndex;
			// draw section lines
			UIBezierPath *sectionLabelLine = [UIBezierPath bezierPath];
			[sectionLabelLine moveToPoint:CGPointMake(VX(xSectionBottom), VY(ySectionBottom))];
			[sectionLabelLine addLineToPoint:CGPointMake(VX(xSectionTop), VY(ySectionTop))];
			[sectionLabelLine stroke];
			[sectionLabelLine moveToPoint:CGPointMake(VX(xSectionBottom-0.05), VY(ySectionBottom))];
			[sectionLabelLine addLineToPoint:CGPointMake(VX(xSectionBottom+0.05), VY(ySectionBottom))];
			[sectionLabelLine stroke];
			[sectionLabelLine moveToPoint:CGPointMake(VX(xSectionTop-0.05), VY(ySectionTop))];
			[sectionLabelLine addLineToPoint:CGPointMake(VX(xSectionTop+0.05), VY(ySectionTop))];
			[sectionLabelLine stroke];
			// temporary graphics context, rotated, translated, color fill pattern space
			CGPoint center = CGPointMake(VX(xSectionBottom), VY(ySectionTop-(ySectionTop-ySectionBottom)/2.0));
			CGContextRef tempContext = UIGraphicsGetCurrentContext();
			CGContextSaveGState(tempContext);
			CGContextTranslateCTM(UIGraphicsGetCurrentContext(), center.x-sizeOfLabelText.height/2.0, center.y+sizeOfLabelText.width/2.0);
			CGContextRotateCTM(UIGraphicsGetCurrentContext(), -M_PI/2.0);
			CGContextSetFillColorWithColor(tempContext, colorWhite);											// to counteract CGContextSetFillColorSpace and CGContextSetFillPattern
			CGContextFillRect(tempContext, CGRectMake(0, 0, sizeOfLabelText.width, sizeOfLabelText.height));
			CGContextSetFillColorWithColor(tempContext, colorBlack);											// to counteract CGContextSetFillColorSpace and CGContextSetFillPattern
			[labelText drawAtPoint:CGPointZero withAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
			CGContextRestoreGState(tempContext);
			// end temporary graphics context
			
			// adjust section label bounds indices
			if (indexOfStratum == stratumSectionUpper) {														// did we complete the current section label (no end of column to interrupt it)?
				if (sectionIndex < _activeDocument.sectionLabels.count) {										// are there any section labels left in the document to be drawn?
					stratumSectionLower = stratumSectionUpper + 1;												// adjust bounds indices
					stratumSectionUpper = stratumSectionLower + ((SectionLabel *)_activeDocument.sectionLabels[sectionIndex]).numberOfStrataSpanned-1;
				} else
					stratumSectionUpper = -1;																	// no more labels to be drawn, disable further stratum section labels
			} else																								// label continues in next column
				stratumSectionLower = indexOfStratum + 1;														// only adjust lower bounds index, upper bounds has not changed
		}	// end section label draw
		
		for (PaleoCurrent *paleo in stratum.paleoCurrents) {													// draw any paleocurrents owned by the stratum
			CGPoint paleoOrigin = CGPointMake(stratumRect.origin.x+stratumRect.size.width+paleo.origin.x/scale, stratumRect.origin.y+paleo.origin.y/scale);
			[_arrowIcon drawAtPointWithRotation:paleoOrigin scale:1 rotation:paleo.rotation inContext:currentContext];
		}
		// don't draw last empty stratum
		if ([_activeDocument.strata indexOfObject:stratum] == _activeDocument.strata.count-1) break;
		CGPatternRef pattern = CGPatternCreate((void *)stratum.materialNumber, CGRectMake(0, 0, 54, 54), CGAffineTransformMakeScale(1., -1.), 54, 54, kCGPatternTilingConstantSpacing, YES, &patternCallbacks);
		CGContextSetFillPattern(currentContext, pattern, &alpha);
		
		// draw stratum
		if (stratum.outline == nil || stratum.outline.count == 0) {												// no outline, treat it as a rectangle
			stratumRect = [self RectUtoV:stratumRect];															// convert to view coordinates
			CGContextFillRect(currentContext, stratumRect);
			CGContextStrokeRect(currentContext, stratumRect);
		} else {																								// has an outline
			CGContextSaveGState(currentContext);
			CGContextSetFillPattern(currentContext, pattern, &alpha);
			CGContextSetLineWidth(currentContext, _activeDocument.lineThickness);
			CGContextSetStrokeColorWithColor(currentContext, colorBlack);
			// draw left boundary, before setting clipping path
			CGContextMoveToPoint(currentContext, VX(offset.x+stratum.frame.origin.x/scale), VY(offset.y+stratum.frame.origin.y/scale));
			CGContextAddLineToPoint(currentContext, VX(offset.x+stratum.frame.origin.x/scale), VY(offset.y+(stratum.frame.origin.y+stratum.frame.size.height)/scale));
			CGContextStrokePath(currentContext);
			// set clipping rectangle
			CGContextBeginPath(currentContext);
			// it's larger than the stratum boundary
			CGContextAddRect(currentContext, CGRectMake(VX(offset.x+stratum.frame.origin.x/scale), VY(offset.y+(stratum.frame.origin.y-kPencilMargin)/scale), VDX((stratum.frame.size.width+kPencilMargin)/scale), VDY((stratum.frame.size.height+2*kPencilMargin)/scale)));
			CGContextClip(currentContext);
			[self addOutline:stratum offset:offset];															// add outline of stratum to current context
			CGContextDrawPath(currentContext, kCGPathFillStroke);												// fills and strokes the path
			CGContextRestoreGState(currentContext);
		}
	}
	CFRelease(colorWhite);
	CFRelease(colorBlack);
}

/*
 Add the outline of the current given stratum to the current context. Supports curved sections.
 */

- (void)addOutline:(Stratum *)stratum offset:(CGPoint)offset
{
	float scale = self.activeDocument.scale;
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(currentContext, self.activeDocument.lineThickness);
	NSMutableArray *controlPoints = [StrataView populateControlPoints:stratum];
	CGMutablePathRef mPath = CGPathCreateMutable();
	CGPoint point;
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[0]), &point);
	CGPathMoveToPoint(mPath, NULL, VX(offset.x+(point.x+stratum.frame.origin.x)/scale), VY(offset.y+(point.y+stratum.frame.origin.y)/scale));
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[1]), &point);
	CGPoint cPoint;
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[0]), &cPoint);
	// first and last curves have only a single control point
	CGPathAddQuadCurveToPoint(mPath, NULL, VX(offset.x+(cPoint.x+stratum.frame.origin.x)/scale), VY(offset.y+(cPoint.y+stratum.frame.origin.y)/scale), VX(offset.x+(point.x+stratum.frame.origin.x)/scale), VY(offset.y+(point.y+stratum.frame.origin.y)/scale));
	int cpIndex = 1;
	for (int index = 2; index < stratum.outline.count-3; ++index) {
		CGPoint cPoint1, cPoint2;
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(stratum.outline[index]), &point);
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[cpIndex++]), &cPoint1);
		CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[cpIndex++]), &cPoint2);
		// grab the next pair of control points and use them for the next curve
		CGPathAddCurveToPoint(mPath, NULL, VX(offset.x+(cPoint1.x+stratum.frame.origin.x)/scale), VY(offset.y+(cPoint1.y+stratum.frame.origin.y)/scale), VX(offset.x+(cPoint2.x+stratum.frame.origin.x)/scale), VY(offset.y+(cPoint2.y+stratum.frame.origin.y)/scale), VX(offset.x+(point.x+stratum.frame.origin.x)/scale), VY(offset.y+(point.y+stratum.frame.origin.y)/scale));
	}
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(controlPoints[cpIndex]), &cPoint);
	CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)([stratum.outline lastObject]), &point);
	// last curve again has a single control point
	CGPathAddQuadCurveToPoint(mPath, NULL, VX(offset.x+(cPoint.x+stratum.frame.origin.x)/scale), VY(offset.y+(cPoint.y+stratum.frame.origin.y)/scale), VX(offset.x+(point.x+stratum.frame.origin.x)/scale), VY(offset.y+(point.y+stratum.frame.origin.y)/scale));
	CGPathCloseSubpath(mPath);
	CGContextAddPath(currentContext, mPath);
	CGPathRelease(mPath);
}

@end

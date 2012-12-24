//
//  StrataModel.h
//  Strata Recorder
//
//  Created by Don Altman on 11/1/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StrataDocument : NSObject <NSCoding>

- (void)adjustStratumSize:(CGSize)size atIndex:(int)index;
- (void)save;
- (StrataDocument *)duplicate;
+ (id)loadFromFile:(NSString *)name;
+ (NSString *)documentsFolderPath;

@property NSString*			name;			// not a part of persistent document, just for housekeeping purposes
@property NSMutableArray*	strataFiles;	// similar
//	persistent properties
@property NSMutableArray*	strata;			// array of Strata*
@property CGSize			pageDimension;	// in inches
@property CGSize			pageMargins;	// in inches
@property CGFloat			scale;			// of page presentation, in physical units/inch
@property int				lineThickness;	// of page presentation, strata edges, in points
@property NSString*			units;			// English or Metric
@property float				strataHeight;	// height of model view (in physical units)

@end

@interface Stratum : NSObject <NSCoding>

- (id)initWithFrame:(CGRect)frame;

@property CGRect			frame;				// in user coordinates
@property int				materialNumber;
@property BOOL				hasPageCutter;		// does it have a page boundary attached?
@property BOOL				hasAnchor;			// does it have an anchor attached?
@property NSMutableArray*	paleoCurrents;		// of PaleoCurrent's

@end

@interface PaleoCurrent : NSObject <NSCoding>

@property float				rotation;			// in radians, counter-clockwise from vertical
@property CGPoint			origin;				// with respect to LR corner of stratum

@end

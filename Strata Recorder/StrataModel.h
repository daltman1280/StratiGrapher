//
//  StrataModel.h
//  Strata Recorder
//
//  Created by Don Altman on 11/1/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	grainSizeBoulders			= 1,
	grainSizeCobbles			= 2,
	grainSizeCoarseGravel		= 4,
	grainSizeFineGravel			= 8,
	grainSizeCoarseSand			= 16,
	grainSizeMediumSand			= 32,
	grainSizeFineSand			= 64,
	grainSizeFineSiltAndClay	= 128
} grainSizeEnum;

@interface StrataDocument : NSObject <NSCoding>

- (void)adjustStratumSize:(CGSize)size atIndex:(int)index;
- (void)save;
- (StrataDocument *)duplicate;
- (void)remove;
- (void)rename:(NSString *)name;
+ (id)loadFromFile:(NSString *)name;
+ (NSString *)documentsFolderPath;

// not a part of persistent document, just for housekeeping purposes
@property NSString*			name;					// document name (not including extension)
@property NSMutableArray*	strataFiles;			// list of strata files in sandbox
@property NSMutableSet*		materialNumbersPalette;	// NSNumbers, list of materials to display in materials palette
//	persistent properties
@property NSMutableArray*	strata;					// array of Strata*
@property CGSize			pageDimension;			// in inches
@property CGSize			pageMargins;			// in inches
@property CGFloat			scale;					// of page presentation, in physical units/inch
@property int				lineThickness;			// of page presentation, strata edges, in points
@property NSString*			units;					// English or Metric
@property float				strataHeight;			// height of model view (in physical units)
@property NSMutableArray*	sectionLabels;			// array of NSString's
@property int				grainSizesMask;			// bit mask of active grain sizes

@end

@interface Stratum : NSObject <NSCoding>

- (id)initWithFrame:(CGRect)frame;
- (void)initializeOutline;

// persistent properties
@property CGRect			frame;				// in user coordinates
@property int				materialNumber;
@property BOOL				hasPageCutter;		// does it have a page boundary attached?
@property BOOL				hasAnchor;			// does it have an anchor attached?
@property NSMutableArray*	paleoCurrents;		// of PaleoCurrent's
@property NSMutableArray*	outline;			// of NSDictionary's, defining endpoints and control points

@end

@interface PaleoCurrent : NSObject <NSCoding>

@property float				rotation;			// in radians, counter-clockwise from vertical
@property CGPoint			origin;				// with respect to LR corner of stratum

@end

@interface SectionLabel : NSObject <NSCoding>

@property int				numberOfStrataSpanned;
@property NSString*			labelText;

@end

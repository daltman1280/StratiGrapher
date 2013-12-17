//
//  StrataModel.h
//  Strata Recorder
//
//  Created by Don Altman on 11/1/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import <Foundation/Foundation.h>

//	grain size constants

static const int gGrainSizeOffsetInTickmarks = 4;				// x offset (in graph tickmarks), from origin to first grainsize location (fine silt and clay)
static const NSString *gGrainSizeNames[] = { @"Fine Silt & Clay", @"Fine Sand", @"Medium Sand", @"Coarse Sand", @"Fine Gravel", @"Coarse Gravel", @"Cobbles", @"Boulders" };
static const NSString *gAbbreviatedGrainSizeNames[] = { @"Silt", @"F. Sand", @"M. Sand", @"C. Sand", @"F. Grav.", @"C. Grav.", @"Cobb.", @"Bould." };
static const int gGrainSizeNamesCount = 8;

typedef enum {
	grainSizeUndefined			= -1,
	grainSizeFineSiltAndClay	= 0,
	grainSizeFineSand			= 1,
	grainSizeMediumSand			= 2,
	grainSizeCoarseSand			= 3,
	grainSizeFineGravel			= 4,
	grainSizeCoarseGravel		= 5,
	grainSizeCobbles			= 6,
	grainSizeBoulders			= 7
} grainSizeEnum;									// can be used as index in array of names

@interface StrataDocument : NSObject <NSCoding>

- (void)adjustStratumSize:(CGSize)size atIndex:(int)index;
- (void)removeStratumAtIndex:(int)index;
- (void)save;
- (StrataDocument *)duplicate;
- (void)remove;
- (void)rename:(NSString *)name;
+ (id)loadFromFile:(NSString *)name;
+ (NSString *)documentsFolderPath;
+ (int)snapToGrainSizePoint:(float *)stratumWidth;
+ (float)stratumWidthFromGrainSize:(grainSizeEnum)grainSize;

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
@property BOOL				hasPageCutter;		// does it have a page boundary attached? (it starts a new column)
@property BOOL				hasAnchor;			// does it have an anchor attached?
@property NSMutableArray*	paleoCurrents;		// of PaleoCurrent's
#ifdef MUTABLE
@property NSMutableArray*	outline;			// of NSMutableDictionary's, defining endpoints and control points
#else
@property NSMutableArray*	outline;			// of NSDictionary's, defining endpoints and control points
#endif
@property grainSizeEnum		grainSizeIndex;		// zero, if unassigned (new stratum), otherwise, index of applicable grain size enum + 1
@property NSString*			notes;

@end

@interface PaleoCurrent : NSObject <NSCoding>

@property float				rotation;			// in radians, counter-clockwise from vertical
@property CGPoint			origin;				// with respect to LR corner of stratum

@end

@interface SectionLabel : NSObject <NSCoding>

@property int				numberOfStrataSpanned;
@property NSString*			labelText;

@end

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
+ (id)loadFromFile:(NSString *)name;

@property NSString*			name;			// not a part of persistent document, just for housekeeping purposes
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

@property CGRect	frame;				// in user coordinates
@property int		materialNumber;

@end

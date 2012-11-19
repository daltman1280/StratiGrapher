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

@property NSMutableArray*	strata;			// array of Strata*
@property NSString*			name;			// not a part of persistent document, just for housekeeping purposes
@property CGSize			pageDimension;	// in inches
@property CGSize			pageMargins;	// in inches
@property CGFloat			scale;			// in meters/inch
@property int				lineThickness;	// in points

@end

@interface Stratum : NSObject <NSCoding>

- (id)initWithFrame:(CGRect)frame;

@property CGRect	frame;				// in user coordinates
@property int		materialNumber;

@end

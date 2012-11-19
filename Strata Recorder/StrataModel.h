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

@property NSMutableArray *strata;		// array of Strata*

@end

@interface Stratum : NSObject <NSCoding>

- (id)initWithFrame:(CGRect)frame;

@property CGRect	frame;				// in user coordinates
@property int		materialNumber;

@end

//
//  StrataModel.m
//  Strata Recorder
//
//  Created by Don Altman on 11/1/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "StrataModel.h"
#import "Graphics.h"

@interface StrataDocument()

@end

@implementation StrataDocument

- (id)init
{
#if 0
	self = [super init];
	if (self) {
		self.strata = [[NSMutableArray alloc] init];
		[self.strata addObject:[[Stratum alloc] initWithFrame:CGRectMake(0*GRID_WIDTH, 0*GRID_WIDTH, 2*GRID_WIDTH, 3*GRID_WIDTH)]];		// just for now
		((Stratum *)self.strata[0]).materialNumber = 703;
		[self.strata addObject:[[Stratum alloc] initWithFrame:CGRectMake(0*GRID_WIDTH, 3*GRID_WIDTH, 1*GRID_WIDTH, 2*GRID_WIDTH)]];		// just for now
		((Stratum *)self.strata[1]).materialNumber = 671;
		[self.strata addObject:[[Stratum alloc] initWithFrame:CGRectMake(0*GRID_WIDTH, 5*GRID_WIDTH, 3*GRID_WIDTH, 4*GRID_WIDTH)]];		// just for now
		((Stratum *)self.strata[2]).materialNumber = 611;
		[self.strata addObject:[[Stratum alloc] initWithFrame:CGRectMake(0*GRID_WIDTH, 9*GRID_WIDTH, 0*GRID_WIDTH, 0*GRID_WIDTH)]];		// just for now
		((Stratum *)self.strata[3]).materialNumber = 605;
	}
#else
	self = [StrataDocument restore];
#endif
	return self;
}

- (void)save
{
	NSString *gDocumentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	[NSKeyedArchiver archiveRootObject:self toFile:[gDocumentsFolder stringByAppendingPathComponent:@"test.strata"]];
}

+ (id)restore
{
	NSString *gDocumentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	StrataDocument *doc = [NSKeyedUnarchiver unarchiveObjectWithFile:[gDocumentsFolder stringByAppendingPathComponent:@"test.strata"]];
	return doc;
}

- (void)adjustStratumSize:(CGSize)size atIndex:(int)index
{
	Stratum *stratum = self.strata[index];
	CGRect frame = stratum.frame;
	CGSize adjustment = CGSizeMake(size.width-frame.size.width, size.height-frame.size.height);
	stratum.frame = CGRectMake(stratum.frame.origin.x, stratum.frame.origin.y, size.width, size.height);
	for (int i=index+1; i<self.strata.count; ++i) {															// offset origins of all following strata
		Stratum *stratum = self.strata[i];
		stratum.frame = CGRectOffset(stratum.frame, 0, adjustment.height);
	}
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.strata = [aDecoder decodeObjectForKey:@"strata"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.strata forKey:@"strata"];
}

@end

@implementation Stratum

//	designated initializer

- (id)initWithFrame:(CGRect)frame
{
	self = [super init];
	if (self) {
		self.frame = frame;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.frame = [aDecoder decodeCGRectForKey:@"frame"];
	self.materialNumber = [aDecoder decodeIntForKey:@"material"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeCGRect:self.frame forKey:@"frame"];
	[aCoder encodeInt:self.materialNumber forKey:@"material"];
}

@end

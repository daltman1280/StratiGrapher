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
	self = [super init];
	if (self) {												// default test document
		self.strata = [[NSMutableArray alloc] init];
		[self.strata addObject:[[Stratum alloc] initWithFrame:CGRectMake(0*GRID_WIDTH, 0*GRID_WIDTH, 0*GRID_WIDTH, 0*GRID_WIDTH)]];
		((Stratum *)self.strata[0]).materialNumber = 0;
//		[self.strata addObject:[[Stratum alloc] initWithFrame:CGRectMake(0*GRID_WIDTH, 0*GRID_WIDTH, 2*GRID_WIDTH, 3*GRID_WIDTH)]];
//		((Stratum *)self.strata[0]).materialNumber = 703;
//		[self.strata addObject:[[Stratum alloc] initWithFrame:CGRectMake(0*GRID_WIDTH, 3*GRID_WIDTH, 1*GRID_WIDTH, 2*GRID_WIDTH)]];
//		((Stratum *)self.strata[1]).materialNumber = 671;
//		[self.strata addObject:[[Stratum alloc] initWithFrame:CGRectMake(0*GRID_WIDTH, 5*GRID_WIDTH, 3*GRID_WIDTH, 4*GRID_WIDTH)]];
//		((Stratum *)self.strata[2]).materialNumber = 611;
//		[self.strata addObject:[[Stratum alloc] initWithFrame:CGRectMake(0*GRID_WIDTH, 9*GRID_WIDTH, 0*GRID_WIDTH, 0*GRID_WIDTH)]];
//		((Stratum *)self.strata[3]).materialNumber = 605;
		NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[StrataDocument documentsFolderPath] error:nil];
		NSMutableArray *strataFiles = [[NSMutableArray alloc] init];
		for (NSString *filename in files) {
			if ([filename hasSuffix:@".strata"])
				[strataFiles addObject:[filename stringByDeletingPathExtension]];
		}
		for (int i=1; i<100; ++i) {
			
			if ([strataFiles indexOfObject:[NSString stringWithFormat:@"Untitled %d", i]] == NSNotFound) {
				self.name = [NSString stringWithFormat:@"Untitled %d", i];
				break;
			}
		}
		self.units = @"Metric";
		self.strataHeight = 10;
		self.pageDimension = CGSizeMake(3.5, 5.);							// hard-coded until we support document settings
		self.pageMargins = CGSizeMake(.5, .5);
		self.scale = 2.;
		self.lineThickness = 2;
	}
	return self;
}

+ (id)loadFromFile:(NSString *)name
{
	NSString *filepath = [[StrataDocument documentsFolderPath] stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"strata"]];
	if (![[NSFileManager defaultManager] fileExistsAtPath:filepath])
		return nil;
	StrataDocument *doc = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
	doc.name = name;
	return doc;
}

+ (NSString *)documentsFolderPath
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (void)save
{
//	self.name = @"test";
	NSAssert(self.name, @"nil name for StrataDocument:save");
	[NSKeyedArchiver archiveRootObject:self toFile:[[StrataDocument documentsFolderPath] stringByAppendingPathComponent:[self.name stringByAppendingPathExtension:@"strata"]]];
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

#pragma mark NSCoder protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.strata = [aDecoder decodeObjectForKey:@"strata"];
	self.pageDimension = [aDecoder decodeCGSizeForKey:@"pageDimension"];
	self.pageMargins = [aDecoder decodeCGSizeForKey:@"pageMargins"];
	self.scale = [aDecoder decodeFloatForKey:@"scale"];
	self.lineThickness = [aDecoder decodeIntForKey:@"lineThickness"];
	self.units = [aDecoder decodeObjectForKey:@"units"];
	self.strataHeight = [aDecoder decodeFloatForKey:@"strataHeight"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.strata forKey:@"strata"];
	[aCoder encodeCGSize:self.pageDimension forKey:@"pageDimension"];
	[aCoder encodeCGSize:self.pageMargins forKey:@"pageMargins"];
	[aCoder encodeFloat:self.scale forKey:@"scale"];
	[aCoder encodeInt:self.lineThickness forKey:@"lineThickness"];
	[aCoder encodeObject:self.units forKey:@"units"];
	[aCoder encodeFloat:self.strataHeight forKey:@"strataHeight"];
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

#pragma mark NSCoder protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.frame = [aDecoder decodeCGRectForKey:@"frame"];
	self.materialNumber = [aDecoder decodeIntForKey:@"material"];
	self.hasPageCutter = [aDecoder decodeBoolForKey:@"hasPageCutter"];
	self.hasAnchor = [aDecoder decodeBoolForKey:@"hasAnchor"];
	self.paleoCurrents = [aDecoder decodeObjectForKey:@"paleocurrents"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeCGRect:self.frame forKey:@"frame"];
	[aCoder encodeInt:self.materialNumber forKey:@"material"];
	[aCoder encodeBool:self.hasPageCutter forKey:@"hasPageCutter"];
	[aCoder encodeBool:self.hasAnchor forKey:@"hasAnchor"];
	[aCoder encodeObject:self.paleoCurrents forKey:@"paleocurrents"];
}

@end

@implementation PaleoCurrent

#pragma mark NSCoder protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.rotation = [aDecoder decodeFloatForKey:@"rotation"];
	self.origin = [aDecoder decodeCGPointForKey:@"origin"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeFloat:self.rotation forKey:@"rotation"];
	[aCoder encodeCGPoint:self.origin forKey:@"origin"];
}

@end

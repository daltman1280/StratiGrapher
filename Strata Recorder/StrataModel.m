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
		[self populateStrataFiles];
		for (int i=1; i<100; ++i) {
			if ([self.strataFiles indexOfObject:[NSString stringWithFormat:@"Untitled %d", i]] == NSNotFound) {
				self.name = [NSString stringWithFormat:@"Untitled %d", i];
				break;
			}
		}
		self.units = @"Metric";
		self.strataHeight = 10;
		self.sectionLabels = [[NSMutableArray alloc] init];
		self.pageDimension = CGSizeMake(3.5, 5.);							// hard-coded until we support document settings
		self.pageMargins = CGSizeMake(.5, .5);
		self.scale = 2.;
		self.lineThickness = 2;
		self.materialNumbersPalette = [[NSMutableSet alloc] init];
	}
	return self;
}

- (void)populateStrataFiles
{
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[StrataDocument documentsFolderPath] error:nil];
	self.strataFiles = [[NSMutableArray alloc] init];
	for (NSString *filename in files) {
		if ([filename hasSuffix:@".strata"])
			[self.strataFiles addObject:[filename stringByDeletingPathExtension]];
	}
}

- (StrataDocument *)duplicate
{
	NSString *newName;
	[self populateStrataFiles];
	for (int i=1; i<100; ++i) {
		if ([self.strataFiles indexOfObject:[NSString stringWithFormat:@"%@ Copy %d", self.name, i]] == NSNotFound) {
			newName = [NSString stringWithFormat:@"%@ Copy %d", self.name, i];
			[[NSFileManager defaultManager] copyItemAtPath:[[[StrataDocument documentsFolderPath] stringByAppendingPathComponent:self.name] stringByAppendingPathExtension:@"strata"]
													toPath:[[[StrataDocument documentsFolderPath] stringByAppendingPathComponent:newName] stringByAppendingPathExtension:@"strata"]
													 error:nil];
			return [StrataDocument loadFromFile:newName];
			break;
		}
	}
	return nil;
}

- (void)rename:(NSString *)name
{
	[[NSFileManager defaultManager] moveItemAtPath:[[[StrataDocument documentsFolderPath] stringByAppendingPathComponent:self.name] stringByAppendingPathExtension:@"strata"]
											toPath:[[[StrataDocument documentsFolderPath] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"strata"]
											 error:nil];
	self.name = name;
}

- (void)remove
{
	[[NSFileManager defaultManager] removeItemAtPath:[[[StrataDocument documentsFolderPath] stringByAppendingPathComponent:self.name] stringByAppendingPathExtension:@"strata"]
											   error:nil];
}

+ (id)loadFromFile:(NSString *)name
{
	NSString *filepath = [[StrataDocument documentsFolderPath] stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"strata"]];
	if (![[NSFileManager defaultManager] fileExistsAtPath:filepath])
		return nil;
	StrataDocument *doc = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
	if (doc.sectionLabels == nil)
		doc.sectionLabels = [[NSMutableArray alloc] init];
	doc.name = name;
	doc.materialNumbersPalette = [[NSMutableSet alloc] init];
	for (Stratum *stratum in doc.strata) {
		if (stratum.materialNumber)
			[doc.materialNumbersPalette addObject:[NSNumber numberWithInt:stratum.materialNumber]];
	}
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
	CGRect oldFrame = stratum.frame;
	CGSize adjustment = CGSizeMake(size.width-oldFrame.size.width, size.height-oldFrame.size.height);
	stratum.frame = CGRectMake(stratum.frame.origin.x, stratum.frame.origin.y, size.width, size.height);
	if (stratum.outline && stratum.outline.count) {
		float xScale = stratum.frame.size.width/oldFrame.size.width;
		float yScale = stratum.frame.size.height/oldFrame.size.height;
		for (int index = 0; index < stratum.outline.count; ++index) {
			NSDictionary *dict = stratum.outline[index];
			CGPoint point;
			CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(dict), &point);
			point.x *= xScale;
			point.y *= yScale;
			[stratum.outline replaceObjectAtIndex:index withObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(point))];
		}
	}
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
	self.sectionLabels = [aDecoder decodeObjectForKey:@"sectionLabels"];
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
	[aCoder encodeObject:self.sectionLabels forKey:@"sectionLabels"];
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

- (void)initializeOutline
{
	self.outline = [[NSMutableArray alloc] init];
	float numberOfSegments = 5;
	for (float x = self.frame.origin.x; x <= self.frame.origin.x+self.frame.size.width; x += self.frame.size.width/numberOfSegments)						// left to right on bottom
		[self.outline addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(CGPointMake(x, self.frame.origin.y)))];
	for (float y = self.frame.origin.y; y <= self.frame.origin.y+self.frame.size.height; y += self.frame.size.height/numberOfSegments)						// up right side
		[self.outline addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(CGPointMake(self.frame.origin.x+self.frame.size.width, y)))];
	for (float x = self.frame.origin.x+self.frame.size.width; x >= self.frame.origin.x; x -= self.frame.size.width/numberOfSegments)						// right to left top
		[self.outline addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(CGPointMake(x, self.frame.origin.y+self.frame.size.height)))];
	// last for loop fails to add last point at x origin, so we add it
	[self.outline addObject:CFBridgingRelease(CGPointCreateDictionaryRepresentation(CGPointMake(self.frame.origin.x, self.frame.origin.y+self.frame.size.height)))];
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
	self.outline = [aDecoder decodeObjectForKey:@"outline"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeCGRect:self.frame forKey:@"frame"];
	[aCoder encodeInt:self.materialNumber forKey:@"material"];
	[aCoder encodeBool:self.hasPageCutter forKey:@"hasPageCutter"];
	[aCoder encodeBool:self.hasAnchor forKey:@"hasAnchor"];
	[aCoder encodeObject:self.paleoCurrents forKey:@"paleocurrents"];
	[aCoder encodeObject:self.outline forKey:@"outline"];
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

@implementation SectionLabel

#pragma mark NSCoder protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.numberOfStrataSpanned = [aDecoder decodeIntForKey:@"numberOfStrataSpanned"];
	self.labelText = [aDecoder decodeObjectForKey:@"labelText"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeInt:self.numberOfStrataSpanned forKey:@"numberOfStrataSpanned"];
	[aCoder encodeObject:self.labelText forKey:@"labelText"];
}

@end

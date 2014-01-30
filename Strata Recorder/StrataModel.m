//
//  StrataModel.m
//  Strata Recorder
//
//  Created by Don Altman on 11/1/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "StrataModel.h"
#import "StrataModelState.h"
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
		self.pageDimension = CGSizeMake(8.5, 11.);							// default
		self.pageMargins = CGSizeMake(.5, .5);
		self.scale = 2.;
		self.lineThickness = 2;
		self.materialNumbersPalette = [[NSMutableSet alloc] init];
		self.patternScale = 1;
		[StrataModelState currentState].dirty = YES;
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
			[StrataModelState currentState].dirty = YES;
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
	[StrataModelState currentState].dirty = YES;
	return doc;
}

+ (NSString *)documentsFolderPath
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

/*
 Round to nearest width (in user units) that represents grain size.
 Returns granularity (can also be used as index for granularity names table).
 */

+ (int)snapToGrainSizePoint:(float *)stratumWidth
{
	float snapLocation;
	int snapIndex;
	float firstGrainSizeSnapX = gGrainSizeOffsetInTickmarks / 4.0;							// in user units (4 tick marks per user unit)
	if (*stratumWidth <= firstGrainSizeSnapX) {
		snapLocation = firstGrainSizeSnapX;													// snap at first grain size
		snapIndex = 0;
	} else if (*stratumWidth > firstGrainSizeSnapX+(gGrainSizeNamesCount-1)/4.0) {
		snapLocation = firstGrainSizeSnapX+(gGrainSizeNamesCount-1)/4.0;					// snap at last grain size
		snapIndex = gGrainSizeNamesCount-1;
	} else {
		snapLocation = trunc(4*(*stratumWidth + 1./8.))/4.0;
		snapIndex = (snapLocation - firstGrainSizeSnapX) * 4;
	}
	*stratumWidth = snapLocation;
	return snapIndex;
}

/*
 Returns width of stratum, based on grainSize.
 */

+ (float)stratumWidthFromGrainSize:(grainSizeEnum)grainSize
{
	float firstGrainSizeSnapX = gGrainSizeOffsetInTickmarks / 4.0;							// in user units (4 tick marks per user unit)
	return firstGrainSizeSnapX + (grainSize / 4.0);
}

- (void)save
{
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
			NSMutableDictionary *dict = stratum.outline[index];
			CGPoint point;
			CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(dict), &point);
			point.x *= xScale;
			point.y *= yScale;
			[dict setObject:[NSNumber numberWithFloat:point.x] forKey:@"X"];
			[dict setObject:[NSNumber numberWithFloat:point.y] forKey:@"Y"];
		}
	}
	for (int i=index+1; i<self.strata.count; ++i) {															// offset origins of all following strata
		Stratum *stratum = self.strata[i];
		stratum.frame = CGRectOffset(stratum.frame, 0, adjustment.height);
	}
}

- (void)removeStratumAtIndex:(int)index
{
	[self.strata removeObjectAtIndex:index];
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
	self.patternScale = [aDecoder decodeFloatForKey:@"patternScale"];
	if (self.patternScale == 0) self.patternScale = 1;
	self.legendScale = [aDecoder decodeFloatForKey:@"legendScale"];
	if (self.legendScale == 0) self.legendScale = 1;
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
	[aCoder encodeFloat:self.patternScale forKey:@"patternScale"];
	[aCoder encodeFloat:self.legendScale forKey:@"legendScale"];
}

@end

@implementation Stratum

//	designated initializer

- (id)initWithFrame:(CGRect)frame
{
	self = [super init];
	if (self) {
		self.frame = frame;
		self.grainSizeIndex = 0;										// uninitialized value
	}
	return self;
}

- (void)initializeOutline
{
	self.outline = [[NSMutableArray alloc] init];
	float numberOfSegments = 5;
	for (float x = self.frame.origin.x, segnum = 0; segnum <= numberOfSegments; x += self.frame.size.width/numberOfSegments, ++segnum)						// left to right, on bottom
		[self.outline addObject:[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)CFBridgingRelease(CGPointCreateDictionaryRepresentation(CGPointMake(x, 0)))]];
	for (float y = 0, segnum = 0; segnum <= numberOfSegments; y += self.frame.size.height/numberOfSegments, ++segnum)										// bottom to top, on right side
		[self.outline addObject:[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)CFBridgingRelease(CGPointCreateDictionaryRepresentation(CGPointMake(self.frame.origin.x+self.frame.size.width, y)))]];
	for (float x = self.frame.origin.x+self.frame.size.width, segnum = 0; segnum <= numberOfSegments; x -= self.frame.size.width/numberOfSegments, ++segnum)// right to left, on top
		[self.outline addObject:[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)CFBridgingRelease(CGPointCreateDictionaryRepresentation(CGPointMake(x, self.frame.size.height)))]];
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
	NSMutableArray *convertedOutline = [[NSMutableArray alloc] init];
	int i = 0;
	for (NSDictionary *dict in self.outline)
		[convertedOutline addObject:[NSMutableDictionary dictionaryWithDictionary:self.outline[i++]]];
	self.outline = convertedOutline;
	self.grainSizeIndex = [aDecoder decodeIntForKey:@"grainSizeIndex"];
	self.notes = [aDecoder decodeObjectForKey:@"notes"];
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
	[aCoder encodeInt:self.grainSizeIndex forKey:@"grainSizeIndex"];
	[aCoder encodeObject:self.notes forKey:@"notes"];
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

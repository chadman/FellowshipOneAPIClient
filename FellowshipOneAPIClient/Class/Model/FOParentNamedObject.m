//
//  ParentObject.m
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FOParentNamedObject.h"

@interface FOParentNamedObject (PRIVATE)

- (id)initWithDictionary:(NSDictionary *)dict;

@end


@implementation FOParentNamedObject
@synthesize myId;
@synthesize url;
@synthesize name;

- (NSDictionary *)serializationMapper {
	
	if (!_serializationMapper) {
		
		
		NSMutableDictionary *mapper = [[NSMutableDictionary alloc] init];
		NSMutableDictionary *attributeKeys = [[NSMutableDictionary alloc] init];
		NSArray *attributeOrder = [[NSArray alloc] initWithObjects:@"myId", @"url", nil];
		
		[mapper setObject:attributeOrder forKey:@"attributeOrder"];
		[attributeOrder release];
		
		[attributeKeys setValue:@"@uri" forKey:@"url"];
		[attributeKeys setValue:@"@id" forKey:@"myId"];
		
		[mapper setObject:attributeKeys forKey:@"attributes"];
		[attributeKeys release];
		
		NSArray *fieldOrder = [[NSArray alloc] initWithObjects:@"name", nil];
		[mapper setObject:fieldOrder forKey:@"fieldOrder"];
		[fieldOrder release];
		
		[mapper setValue:@"name" forKey:@"name"];
		
		_serializationMapper = [[NSDictionary alloc] initWithDictionary:mapper];
		[mapper release];
		
	}
	
	return _serializationMapper;
}

#pragma mark -
#pragma mark Init Methods

+ (FOParentNamedObject *)populateFromDictionary: (NSDictionary *)dict {
	
	return [[[FOParentNamedObject alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	
	if (![super init]) {
		return nil;
	}
	
	if ([[dict objectForKey:@"@uri"] length] > 0) {
		
		self.url = [dict objectForKey:@"@uri"];
		if (![self.url isEqual:[NSNull null]]) {
			self.myId = [[dict objectForKey:@"@id"] integerValue];
			self.name = [dict objectForKey:@"name"];
		}
		else {
			self.url = nil;
		}
	}
	else {
		self.url = nil;
		self.myId = NSIntegerMin;
		self.name = nil;
	}
	
	return self;
	
}


#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOParentNamedObject alloc] init];
	
	if (self != nil) {
		self.myId = [coder decodeIntegerForKey:@"myId"];
		self.url = [coder decodeObjectForKey:@"url"];
		self.name = [coder decodeObjectForKey:@"name"];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeInteger:myId forKey:@"myId"];
	[coder encodeObject:url forKey:@"url"];
	[coder encodeObject:name forKey:@"name"];
	
}

- (void)dealloc {
	[url release];
	[name release];
	[super dealloc];
}

@end
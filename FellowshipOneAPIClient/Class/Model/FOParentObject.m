//
//  ParentObject.m
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FOParentObject.h"

@interface FOParentObject (PRIVATE)

- (id)initWithDictionary:(NSDictionary *)dict;

@end


@implementation FOParentObject
@synthesize myId;
@synthesize url;

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
		
		_serializationMapper = [[NSDictionary alloc] initWithDictionary:mapper];
		[mapper release];
		
	}
	
	return _serializationMapper;
}

#pragma mark -
#pragma mark Init Methods

+ (FOParentObject *)populateFromDictionary: (NSDictionary *)dict {
	
	return [[[FOParentObject alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	
	if (![super init]) {
		return nil;
	}

	if ([[dict objectForKey:@"@uri"] length] > 0) {
	
		self.url = [dict objectForKey:@"@uri"];
		if (![self.url isEqual:[NSNull null]]) {
			self.myId = [[dict objectForKey:@"@id"] integerValue];
		}
		else {
			self.url = nil;
		}
	}
	else {
		self.url = nil;
		self.myId = NSIntegerMin;
	}
	
	return self;

}


#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOParentObject alloc] init];
	
	if (self != nil) {
		self.myId = [coder decodeIntegerForKey:@"myId"];
		self.url = [coder decodeObjectForKey:@"url"];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeInteger:myId forKey:@"myId"];
	[coder encodeObject:url forKey:@"url"];
	
}

- (void)dealloc {
	[url release];
	[super dealloc];
}

@end

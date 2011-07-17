
//
//  HouseholdMemberType.m
//  F1Touch
//
//  Created by Matt Vasquez on 4/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FOHouseholdMemberType.h"


@implementation FOHouseholdMemberType

@synthesize url, myId, name;

+ (FOHouseholdMemberType *) populateFromDictionary:(NSDictionary *)dict {
    
	return [[[FOHouseholdMemberType alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (![super init]) {
		return nil;
	}
	
	self.url = [dict objectForKey:@"@uri"];
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.name = [dict objectForKey:@"name"];
	
	return self;
}

- (void) dealloc {
	[url release];
	[name release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOHouseholdMemberType alloc] init];
	
	if (self != nil) {
		self.url = [coder decodeObjectForKey:@"url"];
		self.myId = [coder decodeIntegerForKey:@"myId"];
		self.name = [coder decodeObjectForKey:@"name"];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:url forKey:@"url"];
	[coder encodeInteger:myId forKey:@"myId"];
	[coder encodeObject:name forKey:@"name"];
}

@end

//
//  Status.m
//  F1Touch
//
//  Created by Matt Vasquez on 4/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FTStatus.h"
#import "FTSubStatus.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"


@implementation FTStatus

@synthesize url, myId, name, comment, date, subStatus;

+ (FTStatus *)populateFromDictionary: (NSDictionary *)dict {
	return [[[FTStatus alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (![super init]) {
		return nil;
	}
	
	self.url = [dict objectForKey:@"@uri"];
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.name = [dict objectForKey:@"name"];
	// optional
	self.comment = [dict objectForKey:@"comment"];
	if ([self.comment isEqual:[NSNull null]]) {
		self.comment = nil;
	}
	
	NSString *tempDate = [dict objectForKey:@"date"];
	if ([tempDate isEqual:[NSNull null]]) {
		self.date = nil;
	}
	else {
		self.date = [FellowshipOneAPIDateUtility dateFromString:tempDate];
	}
	
	if ([dict objectForKey:@"subStatus"] != nil) {
		NSDictionary *tempSubStatus = [dict objectForKey:@"subStatus"];
		NSString *tempName = [tempSubStatus objectForKey:@"name"];
		if (![tempName isEqual:[NSNull null]]) {
			self.subStatus = [[[FTSubStatus alloc] initWithDictionary:[dict objectForKey:@"subStatus"]] autorelease];
		}
		else {
			self.subStatus = nil; 
		}
	}
	
	return self;
}

- (void) dealloc {
	
	self.url = nil;
	self.comment = nil;
	self.date = nil;
	self.subStatus = nil;
	self.name = nil;
	
	[url release];
	[comment release];
	[date release];
	[subStatus release];
	[name release];
	
	[super dealloc];

}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FTStatus	 alloc] init];
	
	if (self != nil) {
		self.url = [coder decodeObjectForKey:@"url"];
		self.comment = [coder decodeObjectForKey:@"comment"];
		self.date = [coder decodeObjectForKey:@"date"];
		self.subStatus = [coder decodeObjectForKey:@"substatus"];
		self.name = [coder decodeObjectForKey:@"name"];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:url forKey:@"url"];
	[coder encodeObject:comment forKey:@"comment"];
	[coder encodeObject:date forKey:@"date"];
	[coder encodeObject:subStatus forKey:@"subStatus"];
	[coder encodeObject:name forKey:@"name"];
}


@end

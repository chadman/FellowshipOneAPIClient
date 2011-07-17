//
//  Communication.m
//  F1Touch
//
//  Created by Matt Vasquez on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FOCommunication.h"
#import "JSON.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"

@interface FOCommunication (PRIVATE)

- (id)initWithDictionary:(NSDictionary *)dict;

@end


@implementation FOCommunication

@synthesize url;
@synthesize myId;
@synthesize householdId, householdUrl;
@synthesize personId;
@synthesize personUrl;
@synthesize value;
@synthesize comment;
@synthesize listed;
@synthesize lastUpdatedDate;
@synthesize typeId, typeName;
@synthesize cleansedValue, generalType;

+ (FOCommunication *)populateFromDictionary: (NSDictionary *)dict {
	
	return [[[FOCommunication alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (![super init]) {
		return nil;
	}
	
	self.url = [dict objectForKey:@"@uri"];
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.householdId = [[[dict objectForKey:@"household"] objectForKey:@"@id"] integerValue];
	self.householdUrl = [[dict objectForKey:@"household"] objectForKey:@"@uri"];
	
	NSDictionary *person = [dict objectForKey:@"person"];
	self.personUrl = [person objectForKey:@"@uri"];
	if (![self.personUrl isEqual:[NSNull null]]) {
		self.personId = [[person objectForKey:@"@id"] integerValue];
	}
	else {
		self.personUrl = nil;
	}
	
	self.value = [dict objectForKey:@"communicationValue"];
	
	self.comment = [dict objectForKey:@"communicationComment"];
	if ([self.comment isEqual:[NSNull null]]) {
		self.comment = nil;
	}
	
	NSString *tempLastUpdatedDate = [dict objectForKey:@"lastUpdatedDate"];
	if ([tempLastUpdatedDate isEqual:[NSNull null]]) {
		self.lastUpdatedDate = nil;
	}
	else {
		self.lastUpdatedDate = [FellowshipOneAPIDateUtility dateFromString:tempLastUpdatedDate];
	}
	
	self.listed = [[dict objectForKey:@"listed"] boolValue];
	self.cleansedValue = [dict objectForKey:@"searchCommunicationValue"];	
	self.generalType = [dict objectForKey:@"communicationGeneralType"];
	
	self.typeId = [[[dict objectForKey:@"communicationType"] objectForKey:@"@id"] integerValue];
	self.typeName = [[dict objectForKey:@"communicationType"] objectForKey:@"name"];
	
	return self;
}

#pragma mark Read-only properties

- (NSString *)urlScheme {
	NSString *theScheme = self.value;
	
	if ([self.generalType isEqualToString:@"Telephone"]) {
		theScheme = [NSString stringWithFormat:@"tel://%@", self.cleansedValue];
	}
	else if ([self.generalType isEqualToString:@"Email"]) {
		theScheme = [NSString stringWithFormat:@"mailto://%@", self.value];
	}
	else {
		if (![self.value hasPrefix:@"http"]) {
			theScheme = [@"http://" stringByAppendingString:self.value];
		}
	}
	
	return theScheme;
}

#pragma mark -

#pragma mark Find

+ (NSArray *) getByPersonID: (NSInteger) personID {
	
	NSMutableArray *returnCommunications = [[[NSMutableArray alloc] init] autorelease];
	NSString *theUrl = [NSString stringWithFormat:@"People/%d/Communications.json", personID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *results = [oauth callSyncFTAPIWithURLSuffix:theUrl forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (results.isSucceed) {
		
		NSDictionary *topLevel = [results.returnData objectForKey:@"communications"];
		if (![topLevel isEqual:[NSNull null]]) {	
			NSArray *communications = [topLevel objectForKey:@"communication"];
			
			for (NSDictionary *currentCommunication in communications) {
				[returnCommunications addObject:[FOCommunication populateFromDictionary:currentCommunication]];
			}
		}
	}
	
	[results release];
	[oauth release];
	
	return returnCommunications;
}

+ (FOCommunication *) getByCommunicationID: (NSInteger) communicationID {
	
	FOCommunication *returnCommunication = [[[FOCommunication alloc] init] autorelease];
	NSString *urlSuffix = [NSString stringWithFormat:@"Communications/%d.json", communicationID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"address"];
		
		if (![topLevel isEqual:[NSNull null]]) {		
			returnCommunication = [FOCommunication populateFromDictionary:topLevel];
		}
	}
	
	[ftOAuthResult release];
	[oauth release];
	
	return returnCommunication;
	
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOCommunication alloc] init];
	
	if (self != nil) {
		self.url = [coder decodeObjectForKey:@"url"];
		self.myId = [coder decodeIntegerForKey:@"myId"];
		self.householdId = [coder decodeIntegerForKey:@"householdId"];
		self.householdUrl = [coder decodeObjectForKey:@"householdUrl"];
		self.personId = [coder decodeIntegerForKey:@"personId"];
		self.personUrl = [coder decodeObjectForKey:@"personUrl"];
		self.value = [coder decodeObjectForKey:@"value"];
		self.comment = [coder decodeObjectForKey:@"comment"];
		self.listed = [coder decodeBoolForKey:@"listed"];
		self.lastUpdatedDate = [coder	decodeObjectForKey:@"lastUpdatedDate"];
		self.typeId = [coder decodeIntegerForKey:@"typeId"];
		self.typeName = [coder decodeObjectForKey:@"typeName"];
		self.cleansedValue = [coder decodeObjectForKey:@"cleansedValue"];
		self.generalType = [coder decodeObjectForKey:@"generalType"];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:url forKey:@"url"];
	[coder encodeInteger:myId forKey:@"myId"];
	[coder encodeInteger:householdId forKey:@"householdId"];
	[coder encodeObject:householdUrl forKey:@"householdUrl"];
	[coder encodeInteger:personId forKey:@"personId"];
	[coder encodeObject:personUrl forKey:@"personUrl"];
	[coder encodeObject:value forKey:@"value"];
	[coder encodeObject:comment forKey:@"comment"];
	[coder encodeBool:listed forKey:@"listed"];
	[coder encodeObject:lastUpdatedDate forKey:@"lastUpdatedDate"];
	[coder encodeInteger:typeId forKey:@"typeId"];
	[coder encodeObject:typeName forKey:@"typeName"];
	[coder encodeObject:cleansedValue forKey:@"cleansedValue"];
	[coder encodeObject:generalType forKey:@"generalType"];
}


#pragma mark -
#pragma mark Cleanup

- (void) dealloc {
	
	[url release];
	[householdUrl release];
	[personUrl release];
	[value release];
	[comment release];
	[lastUpdatedDate release];
	[typeName release];
	[generalType release];
	[cleansedValue release];
	
	[super dealloc];
}

@end
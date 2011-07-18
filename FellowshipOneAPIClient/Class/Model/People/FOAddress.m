//
//  Address.m
//  F1Touch
//
//  Created by Matt Vasquez on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FOAddress.h"
#import "JSON.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuth.h"
#import "FTOAuthResult.h"
#import "ConsoleLog.h"
#import "NSObject+serializeToXml.h"
#import "NSObject+serializeToJSON.h"
#import "FOParentObject.h"
#import "FOParentNamedObject.h"
#import "FOPagedEntity.h"


@interface FOAddress (PRIVATE)

- (id)initWithDictionary:(NSDictionary *)dict;

@end


@implementation FOAddress

@synthesize url;
@synthesize myId;
@synthesize street1, street2, street3, city, state, postalCode, county, country;
@synthesize comment;
@synthesize uspsVerified;
@synthesize lastUpdatedDate;
@synthesize addressType;
@synthesize household;
@synthesize person;
@synthesize carrierRoute, deliveryPoint, addressDate, addressVerifiedDate, lastVerificationAttemptDate, createdDate;

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
		
		NSArray *fieldOrder = [[NSArray alloc] initWithObjects:@"household", @"person", @"addressType", @"street1", @"street2", @"street3", @"city", @"postalCode", @"county", @"country", @"state", @"carrierRoute", @"deliveryPoint", @"addressDate", @"comment", @"uspsVerified", @"addressVerifiedDate", @"lastVerificationAttemptDate", @"createdDate", @"lastUpdatedDate",nil];
		[mapper setObject:fieldOrder forKey:@"fieldOrder"];
		[fieldOrder release];
		
		[mapper setValue:@"address1" forKey:@"street1"];
		[mapper setValue:@"address2" forKey:@"street2"];
		[mapper setValue:@"address3" forKey:@"street3"];
		[mapper setValue:@"addressComment" forKey:@"comment"];
		[mapper setValue:@"city" forKey:@"city"];
		[mapper setValue:@"stProvince" forKey:@"state"];
		[mapper setValue:@"postalCode" forKey:@"postalCode"];
		[mapper setValue:@"county" forKey:@"county"];
		[mapper setValue:@"country" forKey:@"country"];
		[mapper setValue:@"carrierRoute" forKey:@"carrierRoute"];
		[mapper setValue:@"deliveryPoint" forKey:@"deliveryPoint"];
		[mapper setValue:@"addressDate" forKey:@"addressDate"];
		[mapper setValue:@"uspsVerified" forKey:@"uspsVerified"];
		[mapper setValue:@"addressVerifiedDate" forKey:@"addressVerifiedDate"];
		[mapper setValue:@"lastVerificationAttemptDate" forKey:@"lastVerificationAttemptDate"];
		[mapper setValue:@"createdDate" forKey:@"createdDate"];
		[mapper setValue:@"lastUpdatedDate" forKey:@"lastUpdatedDate"];
		
		_serializationMapper = [[NSDictionary alloc] initWithDictionary:mapper];
		[mapper release];
	}
	
	return _serializationMapper;
}


+ (FOAddress *)populateFromDictionary: (NSDictionary *)dict {
	
	return [[[FOAddress alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (![super init]) {
		return nil;
	}
	
	self.url = [dict objectForKey:@"@uri"];
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	
	self.household = [FOParentObject populateFromDictionary:[dict objectForKey:@"household"]];
	
	self.person = [FOParentObject populateFromDictionary:(NSDictionary *)[dict objectForKey:@"person"]];
	
	self.street1 = [dict objectForKey:@"address1"];
	
	self.street2 = [dict objectForKey:@"address2"];
	if ([self.street2 isEqual:[NSNull null]]) {
		self.street2 = nil;
	}
	
	self.street3 = [dict objectForKey:@"address3"];
	if ([self.street3 isEqual:[NSNull null]]) {
		self.street3 = nil;
	}
	
	self.city = [dict objectForKey:@"city"];
	if ([self.city isEqual:[NSNull null]]) {
		self.city = nil;
	}
	
	self.state = [dict objectForKey:@"stProvince"];
	if ([self.state isEqual:[NSNull null]]) {
		self.state = nil;
	}
	
	self.postalCode = [dict objectForKey:@"postalCode"];
	if ([self.postalCode isEqual:[NSNull null]]) {
		self.postalCode = nil;
	}
	
	self.county = [dict objectForKey:@"county"];
	if ([self.county isEqual:[NSNull null]]) {
		self.county = nil;
	}
	
	self.country = [dict objectForKey:@"country"];
	if ([self.country isEqual:[NSNull null]]) {
		self.country = nil;
	}
	
	self.comment = [dict objectForKey:@"addressComment"];
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
	
	self.carrierRoute = [dict objectForKey:@"carrierRoute"];
	self.deliveryPoint = [dict objectForKey:@"deliveryPoint"];
	self.addressDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"addressDate"]];
	self.addressVerifiedDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"addressVerifiedDate"]];
	self.lastVerificationAttemptDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"lastVerificationAttemptDate"]];
	self.uspsVerified = [FellowshipOneAPIUtility convertToBOOL:[dict objectForKey:@"uspsVerified"]];
	self.createdDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"createdDate"]];
	self.lastUpdatedDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"lastUpdatedDate"]];
	
	[self setAddressType:[FOParentNamedObject populateFromDictionary:(NSDictionary *)[dict objectForKey:@"addressType"]]];
	
	return self;
}

- (NSString *)formattedAddress {
	
	@try {
		NSMutableString *desc = [NSMutableString stringWithString: self.street1];
		
		if (self.street2 != nil) {
			[desc appendString:@"\n"];
			[desc appendString:self.street2];
		}
		
		if (self.street3 != nil) {
			[desc appendString:@"\n"];
			[desc appendString:self.street3];
		}
		
		if (self.city != nil) {
			[desc appendString:@"\n"];
			[desc appendString:self.city];
		}
		
		if (self.state != nil) {
			[desc appendString:@", "];
			[desc appendString:self.state];
		}
		
		if (self.postalCode != nil) {
			[desc appendString:@" "];
			[desc appendString:self.postalCode];
		}
		
		if (self.county != nil) {
			[desc appendString:@"\n"];
			[desc appendString:self.county];
		}
		
		NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
		NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
		NSString *countryName = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
		
		if (self.country != nil && ![countryCode isEqualToString:self.country]) {
			[desc appendString:@"\n"];
			[desc appendString:countryName];
		}
		
		return desc;
	}
	@catch (NSException *e) { 
		[ConsoleLog LogMessage:[NSString stringWithFormat:@"Error occured during Address Description: %@", e]];
	}
	
	return nil;
}

- (NSString *)googleMapURL {
	NSMutableString *desc = [[[NSMutableString alloc] init] autorelease];
	
	[desc appendString:self.street1];
	
	if (self.street2 != nil) {
		[desc appendString:@" "];
		[desc appendString:self.street2];
	}
	
	if (self.street3 != nil) {
		[desc appendString:@" "];
		[desc appendString:self.street3];
	}
	
	if (self.city != nil) {
		[desc appendString:@", "];
		[desc appendString:self.city];
	}
	
	if (self.state != nil) {
		[desc appendString:@", "];
		[desc appendString:self.state];
	}
	
	if (self.postalCode != nil) {
		[desc appendString:@" "];
		[desc appendString:self.postalCode];
	}
	
	NSString *escaped = [desc stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	return [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", escaped];
}

#pragma mark -
#pragma mark Find

+ (NSArray *) getByPersonID: (NSInteger) personID {
	
	NSMutableArray *returnedAddresses = [[[NSMutableArray alloc] init] autorelease];
	NSString *theUrl = [NSString stringWithFormat:@"People/%d/Addresses.json", personID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *results = [oauth callSyncFTAPIWithURLSuffix:theUrl forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (results.isSucceed) {
		
		NSDictionary *topLevel = [results.returnData objectForKey:@"addresses"];
		if (![topLevel isEqual:[NSNull null]]) {	
			NSArray *addresses = [topLevel objectForKey:@"address"];
			
			for (NSDictionary *currentAddress in addresses) {
				[returnedAddresses addObject:[FOAddress populateFromDictionary:currentAddress]];
			}
		}
	}
	
	[results release];
	[oauth release];
	
	return returnedAddresses;
}

+ (void) getByPersonID: (NSInteger)personID usingCallback:(void (^)(NSArray *))results {
    
    NSString *addressUrl = [NSString stringWithFormat:@"People/%d/Addresses.json", personID];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block NSMutableArray *returnAddresses = [[NSMutableArray alloc] init];
    
    [oauth callFTAPIWithURLSuffix:addressUrl forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                NSDictionary *topLevel = [result.returnData objectForKey:@"addresses"];
                if (![topLevel isEqual:[NSNull null]]) {	
                    NSArray *addresses = [topLevel objectForKey:@"address"];
                    
                    for (NSDictionary *currentAddress in addresses) {
                        [returnAddresses addObject:[FOAddress populateFromDictionary:currentAddress]];
                    }
                }
            }
        }
        results(returnAddresses);
        [returnAddresses release];
        [oauth release];
    }];
}

+ (FOAddress *) getByAddressID: (NSInteger) addressID {
	
	FOAddress *returnAddress = [[[FOAddress alloc] init] autorelease];
	NSString *urlSuffix = [NSString stringWithFormat:@"Addresses/%d.json", addressID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"address"];
		
		if (![topLevel isEqual:[NSNull null]]) {		
			returnAddress = [FOAddress populateFromDictionary:topLevel];
		}
	}
	
    [oauth release];
    [ftOAuthResult release];
	return returnAddress;	
}

+ (void) getByAddressID: (NSInteger) addressID usingCallback:(void (^)(FOAddress *))returnAddress {
    NSString *addressUrl = [NSString stringWithFormat:@"Addresses/%d.json", addressID];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOAddress *tmpAddress = [[FOAddress alloc] init];
    
    [oauth callFTAPIWithURLSuffix:addressUrl forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpAddress = [[FOAddress alloc] initWithDictionary:[result.returnData objectForKey:@"address"]];
            }
        }
        returnAddress(tmpAddress);
        [tmpAddress release];
        [oauth release];
    }];
}

- (void) save {
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	HTTPMethod method = HTTPMethodPOST;
	
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"Addresses"];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];

	
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix 
															forRealm:FTAPIRealmBase 
													  withHTTPMethod:method 
															withData:[[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding]];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"address"];
		
		if (![topLevel isEqual:[NSNull null]]) {		
			[self initWithDictionary:topLevel];
		}
	}
    
    [ftOAuthResult release];
    [oauth release];
}

- (void) saveUsingCallback:(void (^)(FOAddress *))returnAddress {
    
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOAddress *tmpAddress = [[FOAddress alloc] init];
    HTTPMethod method = HTTPMethodPOST;	
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"Addresses"];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:method withData:[[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding] usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpAddress = [[FOAddress alloc] initWithDictionary:[result.returnData objectForKey:@"address"]];
            }
        }
        returnAddress(tmpAddress);
        [tmpAddress release];
        [oauth release];
    }];
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOAddress alloc] init];
	
	if (self != nil) {
		self.url = [coder decodeObjectForKey:@"url"];
		self.myId = [coder decodeIntegerForKey:@"myId"];
		self.household = [coder decodeObjectForKey:@"household"];
		self.person = [coder decodeObjectForKey:@"person"];
		self.street1 = [coder decodeObjectForKey:@"street1"];
		self.street2 = [coder decodeObjectForKey:@"street2"];
		self.street3 = [coder decodeObjectForKey:@"street3"];
		self.city = [coder decodeObjectForKey:@"city"];
		self.state = [coder decodeObjectForKey:@"state"];
		self.postalCode = [coder decodeObjectForKey:@"postalCode"];
		self.county = [coder decodeObjectForKey:@"county"];
		self.country = [coder decodeObjectForKey:@"country"];
		self.comment = [coder decodeObjectForKey:@"comment"];
		self.uspsVerified = [coder decodeBoolForKey:@"uspsVerified"];
		self.lastUpdatedDate = [coder	decodeObjectForKey:@"lastUpdatedDate"];
		self.addressType = [coder decodeObjectForKey:@"addressType"];
		self.carrierRoute = [coder decodeObjectForKey:@"carrierRoute"];
		self.deliveryPoint = [coder decodeObjectForKey:@"deliveryPoint"];
		self.addressVerifiedDate = [coder decodeObjectForKey:@"addressVerifiedDate"];
		self.lastVerificationAttemptDate = [coder decodeObjectForKey:@"lastVerificationAttemptDate"];
		self.createdDate = [coder decodeObjectForKey:@"createdDate"];
	}
	
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:url forKey:@"url"];
	[coder encodeInteger:myId forKey:@"myId"];
	[coder encodeObject:household forKey:@"household"];
	[coder encodeObject:person forKey:@"person"];
	[coder encodeObject:street1 forKey:@"street1"];
	[coder encodeObject:street2 forKey:@"street2"];
	[coder encodeObject:street3 forKey:@"street3"];
	[coder encodeObject:city forKey:@"city"];
	[coder encodeObject:state forKey:@"state"];
	[coder encodeObject:postalCode forKey:@"postalCode"];
	[coder encodeObject:county forKey:@"county"];
	[coder encodeObject:country forKey:@"country"];
	[coder encodeObject:comment forKey:@"comment"];
	[coder encodeObject:carrierRoute forKey:@"carrierRoute"];
	[coder encodeObject:deliveryPoint forKey:@"deliveryPoint"];
	[coder encodeObject:addressDate forKey:@"addressDate"];
	[coder encodeObject:addressVerifiedDate forKey:@"addressVerifiedDate"];
	[coder encodeObject:lastVerificationAttemptDate forKey:@"lastVerificationAttemptDate"];
	[coder encodeObject:createdDate forKey:@"createdDate"];
	[coder encodeBool:uspsVerified forKey:@"uspsVerified"];
	[coder encodeObject:lastUpdatedDate forKey:@"lastUpdatedDate"];
	[coder encodeObject:addressType forKey:@"addressType"];
}

#pragma mark -
#pragma mark Cleanup

- (void) dealloc {
	
	[url release];
	[household release];
	[person release];
	[street1 release];
	[street2 release];
	[street3 release];
	[city release];
	[state release];
	[postalCode release];
	[county release];
	[country release];
	[comment release];
	[carrierRoute release];
	[deliveryPoint release];
	[addressDate release];
	[addressVerifiedDate release];
	[lastVerificationAttemptDate release];
	[createdDate release];
	[lastUpdatedDate release];
	[addressType release];
	[_serializationMapper release];
	
	[super dealloc];
}

@end
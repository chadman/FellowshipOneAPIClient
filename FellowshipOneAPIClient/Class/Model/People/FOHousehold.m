//
//  FTHousehold.m
//  F1Touch
//
//  Created by Matt Vasquez on 5/18/09.
//  Copyright 2009 Fellowship Technologies. All rights reserved.
//

#import "FOHousehold.h"
#import "Constants.h"
#import "FTOAuth.h"
#import "FellowshipOneAPIUtility.h"
#import "FOPagedEntity.h"
#import "FOPerson.h"
#import "FOHouseholdMemberType.h"
#import "FOHouseholdQO.h"
#import "ConsoleLog.h"
#import "NSObject+serializeToJSON.h"
#import "NSString+URLEncoding.h"

@interface FOHousehold (PRIVATE)

- (id)initWithDictionary:(NSDictionary *)dict;

+(FOHousehold *)populateFromDictionary: (NSDictionary *)dict;

+ (NSString *) createQueryString: (FOHouseholdQO *)qo;

@end


@implementation FOHousehold

@synthesize myId, myOldId, householdCode, url, householdName, householdSortName, householdFirstName;
@synthesize lastSecurityAuthorization, lastActivityDate, createdDate, lastUpdatedDate;
@synthesize allMembers;

- (NSDictionary *)serializationMapper {
	
	if (!_serializationMapper) {
		
		NSMutableDictionary *mapper = [[NSMutableDictionary alloc] init];
		NSMutableDictionary *attributeKeys = [[NSMutableDictionary alloc] init];
		NSArray *attributeOrder = [[NSArray alloc] initWithObjects:@"myId", @"url", @"myOldId", @"householdCode", nil];
		
		[mapper setObject:attributeOrder forKey:@"attributeOrder"];
		[attributeOrder release];
		
		[attributeKeys setValue:@"@uri" forKey:@"url"];
		[attributeKeys setValue:@"@id" forKey:@"myId"];
		[attributeKeys setValue:@"@oldID" forKey:@"myOldId"];
		[attributeKeys setValue:@"@hCode" forKey:@"householdCode"];		
		
		[mapper setObject:attributeKeys forKey:@"attributes"];
		[attributeKeys release];
		
		NSArray *fieldOrder = [[NSArray alloc] initWithObjects:@"householdName", @"householdSortName", @"householdFirstName", @"lastSecurityAuthorization", @"lastActivityDate", @"createdDate", @"lastUpdatedDate",nil];
		[mapper setObject:fieldOrder forKey:@"fieldOrder"];
		[fieldOrder release];
		
		[mapper setValue:@"householdName" forKey:@"householdName"];
		[mapper setValue:@"householdSortName" forKey:@"householdSortName"];
		[mapper setValue:@"householdFirstName" forKey:@"householdFirstName"];
		[mapper setValue:@"lastSecurityAuthorization" forKey:@"lastSecurityAuthorization"];
		[mapper setValue:@"lastActivityDate" forKey:@"lastActivityDate"];
		[mapper setValue:@"createdDate" forKey:@"createdDate"];
		[mapper setValue:@"lastUpdatedDate" forKey:@"lastUpdatedDate"];
		
		_serializationMapper = [[NSDictionary alloc] initWithDictionary:mapper];
		[mapper release];
	}
	
	return _serializationMapper;
}

#pragma mark -
#pragma mark PRIVATE methods
- (id)initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    
	if (!self) {
		return nil;
	}
	
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.myOldId = [FellowshipOneAPIUtility convertToInt:[dict objectForKey:@"@oldID"]];
	self.householdCode = [dict objectForKey:@"@hCode"];
	self.url = [dict objectForKey:@"@uri"];
	self.householdName = [dict objectForKey:@"householdName"];
	self.householdSortName = [dict objectForKey:@"householdSortName"];
	self.householdFirstName = [dict objectForKey:@"householdFirstName"];
	self.lastSecurityAuthorization = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"lastSecurityAuthorization"]];
	self.lastActivityDate = [FellowshipOneAPIUtility convertToFullNSDate:[dict objectForKey:@"lastActivityDate"]];
	self.createdDate = [FellowshipOneAPIUtility convertToFullNSDate:@"createdDate"];
	self.lastUpdatedDate = [FellowshipOneAPIUtility convertToFullNSDate:@"lastUpdatedDate"];
    
	NSMutableString *membersURL = [NSMutableString stringWithFormat:@"Households/%d/People.json", self.myId];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	// Get all the members of the household
	FTOAuthResult *ftOAuthResult = [[oauth callSyncFTAPIWithURLSuffix:membersURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil] retain];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"people"];
		NSMutableArray *people = [[NSMutableArray alloc] init];
		
		if (![topLevel isKindOfClass:[NSNull class]]) {
            
			NSArray *personResult = [topLevel objectForKey:@"person"];
            
			// Loop through all the people in the result and add the individuals to the household
			for (NSDictionary *result in personResult) {
				[people addObject:[FOPerson populateFromDictionary:result]];	
			}
			
			NSLog(@"Household Individual: %@", personResult);
		}
		
		self.allMembers = people;
		[people release];
	}
	
	[ftOAuthResult release];
    [oauth release];
    
	return self;
}

+(FOHousehold *)populateFromDictionary: (NSDictionary *)dict {
	
	return [[[FOHousehold alloc] initWithDictionary:dict] autorelease];
}

+ (NSString *) createQueryString: (FOHouseholdQO *)qo {
    NSMutableString *queryString = [NSMutableString stringWithString:@"?"];
    BOOL firstParameter = YES;
    
    if (qo.searchTerm) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"searchFor", [qo.searchTerm URLEncodedString]];
        firstParameter = NO;
    }
    
    if (qo.lastActivityDate) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"lastActivityDate", [FellowshipOneAPIUtility convertToNSDate:qo.lastActivityDate]];
        firstParameter = NO;
    }
    
    if (qo.createdDate) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"lastActivityDate", [FellowshipOneAPIUtility convertToNSDate:qo.createdDate]];
        firstParameter = NO;
    }
    
    if (qo.lastUpdatedDate) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"lastActivityDate", [FellowshipOneAPIUtility convertToNSDate:qo.lastUpdatedDate]];
        firstParameter = NO;
    }
    
    // Append the page number and records per page
    if (!firstParameter) {
        [queryString appendString:@"&"];
    }
    [queryString appendFormat:@"%@=%d", @"page", qo.pageNumber];
    firstParameter = NO;

    if (!firstParameter) {
        [queryString appendString:@"&"];
    }
    [queryString appendFormat:@"%@=%d", @"recordsperpage", qo.recordsPerPage];
    firstParameter = NO;

    return queryString;
}

#pragma mark -
#pragma mark Properties
- (NSArray *)members {
	NSMutableArray *people = [[[NSMutableArray alloc] init] autorelease];
	
    
	for (FOPerson *person in self.allMembers) {
		if (person.householdMemberType.myId != kFellowshipOneAPIClientHouseholdMemberTypeVisitor) {
			[people addObject:person];
		}
	}
	
	return people;
}

- (NSArray *)visitors {
	NSMutableArray *people = [[[NSMutableArray alloc] init] autorelease];
	
    
	for (FOPerson *person in self.allMembers) {
		if (person.householdMemberType.myId == kFellowshipOneAPIClientHouseholdMemberTypeVisitor) {
			[people addObject:person];
		}
	}
    
	
	return people;
}

#pragma mark -
#pragma mark Find

+ (FOHousehold *) getByID: (NSInteger)hsdID {
    
    FOHousehold *returnHousehold = [[[FOHousehold alloc] init] autorelease];
	NSString *urlSuffix = [NSString stringWithFormat:@"Households/%d.json", hsdID];
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	FTOAuthResult *ftOAuthResult = [oauth callSyncFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"household"];
		
		if (![topLevel isEqual:[NSNull null]]) {		
			returnHousehold = [FOHousehold populateFromDictionary:topLevel];
		}
	}
	
	[ftOAuthResult release];
	[oauth release];
	
	return returnHousehold; 
}

+ (void) getByID: (NSInteger)hsdID usingCallback:(void (^)(FOHousehold *))returnedHousehold {
    
	NSString *urlSuffix = [NSString stringWithFormat:@"Households/%d.json", hsdID];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOHousehold *tmpHousehold = [[FOHousehold alloc] init];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpHousehold = [[FOHousehold alloc] initWithDictionary:[result.returnData objectForKey:@"household"]];
            }
        }
        returnedHousehold(tmpHousehold);
        [tmpHousehold release];
        [oauth release];
    }];
}

+ (void) searchForHouseholds: (FOHouseholdQO *)qo usingCallback:(void (^)(FOPagedEntity *))pagedResults {
    
    NSString *urlSuffix = [NSString stringWithFormat:@"%@%@", @"households/search.json", [FOHousehold createQueryString:qo]];
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        FOPagedEntity *resultsEntity = [[FOPagedEntity alloc] init];
        NSMutableArray *tmpResults = [[NSMutableArray alloc] initWithObjects:nil];
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                
                NSDictionary *topLevel = [result.returnData objectForKey:@"results"];
                NSArray *results = [topLevel objectForKey:@"household"];
                
                resultsEntity.currentCount = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@count"]];
                resultsEntity.pageNumber = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@pageNumber"]];
                resultsEntity.totalRecords = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@totalRecords"]];
                resultsEntity.additionalPages = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@additionalPages"]];
                
                for (NSDictionary *result in results) {
                    [tmpResults addObject:[FOHousehold populateFromDictionary:result]];
                }
                
                resultsEntity.results = [tmpResults copy];
            }
        }
        pagedResults(resultsEntity);
        [resultsEntity release];
        [tmpResults release];
        [oauth release]; 
    }];
}

#pragma mark -
#pragma mark Save Methods

- (void) save {
	
	FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
	HTTPMethod method = HTTPMethodPOST;
	
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"Households"];
	
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
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"household"];
		
		if (![topLevel isEqual:[NSNull null]]) {		
			[self initWithDictionary:topLevel];
		}
	}
    
    [ftOAuthResult release];
    [oauth release];
}

- (void) saveUsingCallback:(void (^)(FOHousehold *))returnHousehold {
    
    FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
    __block FOHousehold *tmpHousehold = [[FOHousehold alloc] init];
    HTTPMethod method = HTTPMethodPOST;	
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"Households"];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];
    
    [oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:method withData:[[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding] usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpHousehold = [[FOHousehold alloc] initWithDictionary:[result.returnData objectForKey:@"household"]];
            }
        }
        returnHousehold(tmpHousehold);
        [tmpHousehold release];
        [oauth release];
    }];
}

- (void) dealloc {
	
	[householdCode release];
	[url release];
	[householdName release];
	[householdSortName release];
	[householdFirstName release];
	[lastSecurityAuthorization release];
	[lastActivityDate release];
	[createdDate release];
	[lastUpdatedDate release];
	[allMembers release];
	[_serializationMapper release];
    
	[super dealloc];
}

@end

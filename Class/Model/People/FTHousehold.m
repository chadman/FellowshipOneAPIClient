//
//  FTHousehold.m
//  F1Touch
//
//  Created by Matt Vasquez on 5/18/09.
//  Copyright 2009 Fellowship Technologies. All rights reserved.
//

#import "FTHousehold.h"
#import "Constants.h"
#import "FTOAuth.h"
#import "FellowshipOneAPIUtility.h"
#import "PagedEntity.h"
#import "FTPerson.h"
#import "FTHouseholdMemberType.h"
#import "ConsoleLog.h"
#import "NSObject+serializeToJSON.h"

@interface FTHousehold ()

@property (nonatomic, retain) FTOAuth *oauth;

@end


@interface FTHousehold (PRIVATE)

- (id)initWithDictionary:(NSDictionary *)dict;

+(FTHousehold *)populateFromDictionary: (NSDictionary *)dict;

@end


@implementation FTHousehold

@synthesize myId, myOldId, householdCode, url, householdName, householdSortName, householdFirstName;
@synthesize lastSecurityAuthorization, lastActivityDate, createdDate, lastUpdatedDate;
@synthesize allMembers;
@synthesize oauth;

- (id)delegate {
	return _delegate;
}

- (void) setDelegate: (id)newDelegate {
	_delegate = newDelegate;
}

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

- (id) initWithDelegate: (id)delegate {
	
	if (self = [super init]) {
		self.delegate = delegate;
		self.oauth = [[FTOAuth alloc] initWithDelegate:self];
	}
	return self;		
}

#pragma mark -
#pragma mark PRIVATE methods
- (id)initWithDictionary:(NSDictionary *)dict {
	if (![super init]) {
		return nil;
	}
	else {
		self.oauth = [[FTOAuth alloc] initWithDelegate:self];
	}
	
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.myOldId = [FellowshipOneAPIUtility convertToInt:[dict objectForKey:@"@OldID"]];
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
	// Get all the members of the household
	FTOAuthResult *ftOAuthResult = [[oauth callSyncFTAPIWithURLSuffix:membersURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil] retain];
	
	if (ftOAuthResult.isSucceed) {
		
		NSDictionary *topLevel = [ftOAuthResult.returnData objectForKey:@"people"];
		NSMutableArray *people = [[NSMutableArray alloc] init];
		
		if (![topLevel isKindOfClass:[NSNull class]]) {

			NSArray *personResult = [topLevel objectForKey:@"person"];
		
			// Loop through all the people in the result and add the individuals to the household
			for (NSDictionary *result in personResult) {
				[people addObject:[FTPerson populateFromDictionary:result]];	
			}
			
			NSLog(@"Household Individual: %@", personResult);
			
			
		}
		
		self.allMembers = people;
		[people release];
	}
	
	[ftOAuthResult release];

	return self;
}

+(FTHousehold *)populateFromDictionary: (NSDictionary *)dict {
	
	return [[[FTHousehold alloc] initWithDictionary:dict] autorelease];
}

#pragma mark -
#pragma mark Properties
- (NSArray *)members {
	NSMutableArray *people = [[[NSMutableArray alloc] init] autorelease];
	

	for (FTPerson *person in self.allMembers) {
		if (person.householdMemberType.myId != kHouseholdMemberTypeVisitor) {
			[people addObject:person];
		}
	}
	
	return people;
}

- (NSArray *)visitors {
	NSMutableArray *people = [[[NSMutableArray alloc] init] autorelease];
	

	for (FTPerson *person in self.allMembers) {
		if (person.householdMemberType.myId == kHouseholdMemberTypeVisitor) {
			[people addObject:person];
		}
	}

	
	return people;
}

#pragma mark -
#pragma mark Find

- (void)getByID:(NSInteger)hsdID {
	
	NSString *householdURL = [NSString stringWithFormat:@"Households/%d.json", hsdID];
	[oauth callFTAPIWithURLSuffix:householdURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
}

- (void) searchForHouseholds: (NSString *)searchText householdSearchType: (HouseholdSearchType) searchType  withPage: (NSInteger)pageNumber {
	
	[oauth callFTAPIWithURLSuffix:[NSString stringWithFormat:@"Households/Search.json?searchFor=%@&page=%d&recordsperpage=5", searchText, pageNumber] 
									forRealm:FTAPIRealmBase 
						  withHTTPMethod:HTTPMethodGET 
								withData:nil];
}

#pragma mark -
#pragma mark Save Methods

- (void) save {
	
	HTTPMethod method = HTTPMethodPOST;
	
	// There is a possibility when calling this method that the oauth object has not been initialized. If it hasn't init it here
	if (!oauth) {
		self.oauth = [[FTOAuth alloc] initWithDelegate:self];
	}
	
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"households"];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];
	
	[oauth callFTAPIWithURLSuffix:urlSuffix forRealm:FTAPIRealmBase withHTTPMethod:method withData:[[self serializeToJSON] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) saveSynchronously {
	
	HTTPMethod method = HTTPMethodPOST;
	
	// There is a possibility when calling this method that the oauth object has not been initialized. If it hasn't init it here
	if (!oauth) {
		self.oauth = [[FTOAuth alloc] initWithDelegate:self];
	}
	
	NSMutableString *urlSuffix = [NSMutableString stringWithFormat:@"households"];
	
	if (myId > 0) {
		[urlSuffix appendFormat:@"/%d", myId];
		method = HTTPMethodPUT;
	}
	
	[urlSuffix appendString:@".json"];
	
	if (!oauth) {
		oauth = [[FTOAuth alloc] initWithDelegate:self];
	}
	
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
}

#pragma mark -
#pragma mark FTOauth Delegate Methods
- (void) ftOauth: (FTOAuth *)ftOAuth didComplete: (FTOAuthResult *) result {
	
	NSLog(@"FTOAuth returned a result.");
	
	if (result.isSucceed) {
		
		if (result.returnData != nil) {
			
			NSMutableArray *searchResults = [[[NSMutableArray alloc] init] autorelease];
			NSDictionary *topLevel = [result.returnData objectForKey:@"results"];
			NSArray *results;
			
			if (topLevel) {
				results = [topLevel objectForKey:@"household"];
			}
			else {
				results = [result.returnData objectForKey:@"household"];
			}
			
			PagedEntity *resultEntity;

			if (results) {
				// If the results is an array then there are multiple results
				if ([results isKindOfClass:[NSArray class]]) {
					
					// Create the paged entity
					resultEntity = [[PagedEntity alloc] init];
					
					resultEntity.currentCount = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@count"]];
					resultEntity.pageNumber = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@pageNumber"]];
					resultEntity.totalRecords = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@totalRecords"]];
					resultEntity.additionalPages = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@additionalPages"]];
					
					for (NSDictionary *result in results) {
						[searchResults addObject:[FTHousehold populateFromDictionary:result]];
					}
					
					resultEntity.results = searchResults;
					
					if ([self.delegate respondsToSelector:@selector(FTHouseholdsReturned:)]) {
						[[self delegate] FTHouseholdsReturned:resultEntity];
					}
					else {
						[ConsoleLog LogMessage:@"FTHouseholdsReturned delegate method not implemented."];
					}
					
					[resultEntity release];
				}
				else {
					if ([self.delegate respondsToSelector:@selector(FThouseholdReturned:)]) {
						[[self delegate] FThouseholdReturned:[FTHousehold populateFromDictionary: (NSDictionary *)results]];
					}
					else {
						[ConsoleLog LogMessage:@"FTHouseholdReturned delegate method not implemented."];
					}
				}
			}
			else {
				if ([self.delegate respondsToSelector:@selector(FTHouseholdsReturned:)]) {
					[[self delegate] FTHouseholdsReturned:nil];
				}
				else {
					[ConsoleLog LogMessage:@"FTHouseholdReturned delegate method not implemented."];
				}
			}
		}
		else {
			[[self delegate] FTHouseholdFail:nil];
		}
	}
	else {
		[[self delegate] FTHouseholdFail:nil];
	}
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
	if (oauth) [oauth release];
	[_serializationMapper release];

	[super dealloc];
}

@end

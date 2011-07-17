//
//  Person.m
//  F1Touch
//
//  Created by Matt Vasquez on 4/17/09.
//  Copyright 2009 Fellowship Technologies. All rights reserved.
//

#import "FOPerson.h"
#import "JSON.h"
#import "FOHouseholdMemberType.h"
#import "FOStatus.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"
#import "NSDate+ageFromDate.h"
#import "PagedEntity.h"
#import "ConsoleLog.h"
#import "PagedEntity.h"
#import "FOAddress.h"
#import "FOCommunication.h"

@interface FOPerson ()

@end

@interface FOPerson (PRIVATE)

+(FOPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching;
+(FOPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage;

- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage;
- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching;
- (id)initWithDictionary:(NSDictionary *)dict;
@end


@implementation FOPerson

@synthesize myId, householdId;
@synthesize url;
@synthesize firstName, middleName, lastName, goesByName, suffix, title, prefix, salutation, formerName;
@synthesize maritalStatus;
@synthesize gender;
@synthesize dateOfBirth;
@synthesize imageURL;
@synthesize rawImage;
@synthesize firstRecord;
@synthesize createdDate;
@synthesize lastUpdatedDate;
@synthesize householdMemberType;
@synthesize status;
@synthesize addresses;
@synthesize communications;

#pragma mark Additional Properties

- (NSString *)casualName {
	NSMutableString *name;
	
	if (self.goesByName != nil) {
		name = [NSMutableString stringWithString:self.goesByName];
	}
	else {
		name = [NSMutableString stringWithString:self.firstName];
	}
	
	[name appendString:@" "];
	[name appendString:self.lastName];
	
	if (self.suffix != nil) {
		[name appendString:@", "];
		[name appendString:self.suffix];
	}
	
	return name;
}

- (NSString *)age {
	if (self.dateOfBirth) {
		
		NSInteger ageInYears = [self.dateOfBirth ageFromDate];
		
		if (ageInYears > 0) {
			return [NSString stringWithFormat:@"%i yrs.", ageInYears];
		}
		else {
			return @"child";
		}
	}
	
	return @"";	
}

#pragma mark -
#pragma mark PRIVATE populate methods

+(FOPerson *)populateFromDictionary: (NSDictionary *)dict {
	
	return [FOPerson populateFromDictionary:dict searching:NO];
}

+(FOPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching {
	
	return [[[FOPerson alloc] initWithDictionary:dict searching:searching] autorelease];
}

+(FOPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage {
	return [[[FOPerson alloc] initWithDictionary:dict searching:searching preloadImage:preloadImage] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	return [self initWithDictionary:dict searching:NO];
}

- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching {
	return [self initWithDictionary:dict searching:searching preloadImage:YES];
}

- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage {
	if (![super init]) {
		return nil;
	}
	
	self.myId = [[dict objectForKey:@"@id"] integerValue];
	self.url = [dict objectForKey:@"@uri"];
	self.householdId = [[dict objectForKey:@"@householdID"] integerValue];
	self.firstName = [dict objectForKey:@"firstName"];
	self.lastName = [dict objectForKey:@"lastName"];
	
	self.goesByName = [dict objectForKey:@"goesByName"];
	if ([self.goesByName isEqual:[NSNull null]]) {
		self.goesByName = nil;
	}
	
	self.suffix = [dict objectForKey:@"suffix"];
	if ([self.suffix isEqual:[NSNull null]]) {
		self.suffix = nil;
	}
	
	self.imageURL = [dict objectForKey:@"@imageURI"];
	
    // Address collection
    NSDictionary *addressResults = [dict objectForKey:@"addresses"];
    
    if (addressResults && ![addressResults isKindOfClass:[NSNull class]]) {
        NSMutableArray *addressArray = [[NSMutableArray alloc] initWithObjects:nil];
        for (NSDictionary *addressResult in [addressResults objectForKey:@"address"]) {
            [addressArray addObject:[FOAddress populateFromDictionary:addressResult]];
        }
        self.addresses = [addressArray copy];
        [addressArray release];
    }
    
    // communication collection
    NSDictionary *communicationResults = [dict objectForKey:@"communications"];
    
    if (communicationResults && ![communicationResults isKindOfClass:[NSNull class]]) {
        NSMutableArray *communicationArray = [[NSMutableArray alloc] initWithObjects:nil];
        for (NSDictionary *communicationResult in [communicationResults objectForKey:@"communication"]) {
            [communicationArray addObject:[FOCommunication populateFromDictionary:communicationResult]];
        }
        self.communications = [communicationArray copy];
        [communicationArray release];
    }
    
	
	if (!searching) {
		
		if (preloadImage) {
			if (self.imageURL.length == 0) {
				self.imageURL = nil;
			}
			else {
				self.rawImage = [self getImageData:@"S"];
			}
		}
		
		
		self.gender = [dict objectForKey:@"gender"];
		if ([self.gender isEqual:[NSNull null]]) {
			self.gender = nil;
		}
		
		self.title = [dict objectForKey:@"title"];
		if ([self.title isEqual:[NSNull null]]) {
			self.title = nil;
		}
		
		self.prefix = [dict objectForKey:@"prefix"];
		if ([self.prefix isEqual:[NSNull null]]) {
			self.prefix = nil;
		}
		
		self.salutation = [dict objectForKey:@"salutation"];
		if ([self.salutation isEqual:[NSNull null]]) {
			self.salutation = nil;
		}
		
		NSString *tempDOB = [dict objectForKey:@"dateOfBirth"];
		if ([tempDOB isEqual:[NSNull null]]) {
			self.dateOfBirth = nil;
		}
		else {
			self.dateOfBirth = [FellowshipOneAPIDateUtility dateFromString:tempDOB];
		}
		
		self.maritalStatus = [dict objectForKey:@"maritalStatus"];
		if ([self.maritalStatus isEqual:[NSNull null]]) {
			self.maritalStatus = nil;
		}
		
		self.formerName = [dict objectForKey:@"formerName"];
		if ([self.formerName isEqual:[NSNull null]]) {
			self.formerName = nil;
		}
		
		NSString *tempFirstRecord = [dict objectForKey:@"firstRecord"];
		if ([tempFirstRecord isEqual:[NSNull null]]) {
			self.firstRecord = nil;
		}
		else {
			self.firstRecord = [FellowshipOneAPIDateUtility dateFromString:tempFirstRecord];
		}
		
		NSString *tempCreatedDate = [dict objectForKey:@"createdDate"];
		if ([tempCreatedDate isEqual:[NSNull null]]) {
			self.createdDate = nil;
		}
		else {
			self.createdDate = [FellowshipOneAPIDateUtility dateFromString:tempCreatedDate];
		}
		
		NSString *tempLastUpdatedDate = [dict objectForKey:@"lastUpdatedDate"];
		if ([tempLastUpdatedDate isEqual:[NSNull null]]) {
			self.lastUpdatedDate = nil;
		}
		else {
			self.lastUpdatedDate = [FellowshipOneAPIDateUtility dateFromString:tempLastUpdatedDate];
		}
		
		self.householdMemberType = [FOHouseholdMemberType populateFromDictionary:[dict objectForKey:@"householdMemberType"]];
		self.status = [FOStatus populateFromDictionary:[dict objectForKey:@"status"]];
	}
	
	return self;
}

+ (NSString *) getSearchIncludeString:(PeopleSearchInclude)include {
	
	@try {
		switch (include) {
			case (int)PeopleSearchIncludeAddresses:
				return @"addresses";
				break;
			case (int)PeopleSearchIncludeCommunications:
				return @"communications";
				break;
			case (int)PeopleSearchIncludeAttributes:
				return @"attributes";
				break;
			default:
				return @"";
				break;
		}
	}
	@catch (NSException * e) {
		[ConsoleLog LogMessage:[NSString stringWithFormat:@"Could not find people search include %@. Error returned %@", include, e]];
		return @"";
	}
	@finally { }
}


#pragma mark -
#pragma mark Helpers

- (NSData *) getImageData: (NSString *)size {
    NSData *rawData = nil;
	
	if (self.imageURL) {
		NSMutableString *imageFullURL = [NSString stringWithFormat:@"%@?size=%@", self.imageURL, size];
		
		NSURL *nsImageURL = [NSURL URLWithString:imageFullURL];
		
        FTOAuth *oauth = [[FTOAuth alloc] initWithDelegate:self];
		FTOAuthResult *result = [oauth callSyncFTAPIWithURL:nsImageURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
		
		if (result.isSucceed) {
			rawData = [result.returnImageData retain];
		}
        [oauth release];
	}	
	
	return rawData;
}

#pragma mark -
#pragma mark Find

+ (void) getByID: (NSInteger)personID usingCallback:(void (^)(FOPerson *))returnedPerson {
    
    NSString *personURL = [NSString stringWithFormat:@"People/%d.json", personID];
    FTOAuth *oauth = [[[FTOAuth alloc] initWithDelegate:self] autorelease];
    __block FOPerson *tmpPerson = [[FOPerson alloc] init];
 
    [oauth callFTAPIWithURLSuffix:personURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpPerson = [[FOPerson alloc] initWithDictionary:[result.returnData objectForKey:@"person"]];
            }
        }
        returnedPerson(tmpPerson);
        [tmpPerson release];
    }];
}

+ (void) getByUrl: (NSString *)theUrl usingCallback:(void (^)(FOPerson *))returnedPerson {
    FTOAuth *oauth = [[[FTOAuth alloc] initWithDelegate:self] autorelease];
    __block FOPerson *tmpPerson = [[FOPerson alloc] init];
    
    [oauth callFTAPIWithURL:theUrl withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpPerson = [[FOPerson alloc] initWithDictionary:[result.returnData objectForKey:@"person"]];
            }
        }
        returnedPerson(tmpPerson);
        [tmpPerson release];
    }];
    
}

+ (void) searchForPeople: (NSString *)searchText withSearchIncludes:(NSArray *)includes withPage: (NSInteger)pageNumber usingCallback:(void (^)(PagedEntity *))pagedResults {
	
	NSMutableString *peopleSearchURL = [NSMutableString stringWithFormat:@"People/Search.json?searchFor=%@&page=%d&recordsperpage=20", searchText, pageNumber];
	FTOAuth *oauth = [[[FTOAuth alloc] initWithDelegate:self] autorelease];
    
	// If there are includes, add them to the people search URL
	if (includes) {
		NSMutableString *includesString = [NSMutableString stringWithString:@""];
		
		// Loop through all the array objects
		for (int i = 0; i < [includes count]; i++) {
			
			if ([includesString length] > 0) {
				[includesString appendString:@","];
			}
			
			[includesString appendString:[includes objectAtIndex:i]];
		}
		
		[peopleSearchURL appendString:@"&include="];
        [peopleSearchURL appendString:includesString];
	}
    
    [oauth callFTAPIWithURLSuffix:peopleSearchURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        PagedEntity *resultsEntity = [[PagedEntity alloc] init];
        NSMutableArray *tmpResults = [[NSMutableArray alloc] initWithObjects:nil];
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                
                NSDictionary *topLevel = [result.returnData objectForKey:@"results"];
                NSArray *results = [topLevel objectForKey:@"person"];

                resultsEntity.currentCount = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@count"]];
                resultsEntity.pageNumber = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@pageNumber"]];
                resultsEntity.totalRecords = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@totalRecords"]];
                resultsEntity.additionalPages = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@additionalPages"]];
                
                for (NSDictionary *result in results) {
                    [tmpResults addObject:[FOPerson populateFromDictionary:result searching:YES]];
                }
                
                resultsEntity.results = [tmpResults copy];
            }
        }
        pagedResults(resultsEntity);
        [resultsEntity release];
        [tmpResults release];
    }];
}

+ (void)getImageData: (NSInteger)personID withSize:(NSString *)size usingCallback:(void (^)(NSData *))returnedImage {
    NSString *imageURL = [NSString stringWithFormat:@"People/%d/Images.json?Size=%@", personID, size];
    FTOAuth *oauth = [[[FTOAuth alloc] initWithDelegate:self] autorelease];
    __block NSData *tmpImage = [[NSData alloc] init];
    
    [oauth callFTAPIWithURLSuffix:imageURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil usingBlock:^(id block) {
        
        if ([block isKindOfClass:[FTOAuthResult class]]) {
            FTOAuthResult *result = (FTOAuthResult *)block;
            if (result.isSucceed) {
                tmpImage = result.returnImageData;
            }
        }
        returnedImage(tmpImage);
        [tmpImage release];
    }];
}


- (void) dealloc {
	[url release];
	[firstName release];
	[middleName release];
	[lastName release];
	[suffix release];
	[title release];
	[prefix release];
	[gender release];
	[salutation release];
	[maritalStatus release];
	[formerName release];
	[dateOfBirth release];
	[imageURL release];
	[firstRecord release];
	[createdDate release];
	[lastUpdatedDate release];
	[householdMemberType release];
	[status release];
	[rawImage release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FOPerson alloc] init];
	
	if (self != nil) {
		self.url = [coder decodeObjectForKey:@"url"];
		self.myId = [coder decodeIntegerForKey:@"myId"];
		self.householdId = [coder decodeIntegerForKey:@"householdId"];
		self.firstName = [coder decodeObjectForKey:@"firstName"];
		self.middleName = [coder decodeObjectForKey:@"middleName"];
		self.goesByName = [coder decodeObjectForKey:@"goesByName"];
		self.lastName = [coder decodeObjectForKey:@"lastName"];
		self.suffix = [coder decodeObjectForKey:@"suffix"];
		self.title = [coder decodeObjectForKey:@"title"];
		self.prefix = [coder decodeObjectForKey:@"prefix"];
		self.gender = [coder decodeObjectForKey:@"gender"];
		self.salutation = [coder decodeObjectForKey:@"salutation"];
		self.maritalStatus = [coder decodeObjectForKey:@"maritalStatus"];
		self.formerName = [coder decodeObjectForKey:@"formerName"];
		self.dateOfBirth = [coder decodeObjectForKey:@"dateOfBirth"];
		self.imageURL = [coder decodeObjectForKey:@"imageURL"];
		self.firstRecord = [coder decodeObjectForKey:@"firstRecord"];
		self.createdDate = [coder decodeObjectForKey:@"createdDate"];
		self.lastUpdatedDate = [coder decodeObjectForKey:@"lastUpdatedDate"];
		self.householdMemberType = [coder decodeObjectForKey:@"householdMemberType"];
		self.status = [coder decodeObjectForKey:@"status"];
		self.rawImage = [coder decodeObjectForKey:@"rawImage"];
        self.addresses = [coder decodeObjectForKey:@"addresses"];
	}
    
	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:url forKey:@"url"];
	[coder encodeInteger:myId forKey:@"myId"];
	[coder encodeInteger:householdId forKey:@"householdId"];
	[coder encodeObject:firstName forKey:@"firstName"];
	[coder encodeObject:middleName forKey:@"middleName"];
	[coder encodeObject:lastName forKey:@"lastName"];
	[coder encodeObject:suffix forKey:@"suffix"];
	[coder encodeObject:title forKey:@"title"];
	[coder encodeObject:prefix forKey:@"prefix"];
	[coder encodeObject:gender forKey:@"gender"];
	[coder encodeObject:salutation forKey:@"salutation"];
	[coder encodeObject:maritalStatus forKey:@"maritalStatus"];
	[coder encodeObject:formerName forKey:@"formerName"];
	[coder encodeObject:dateOfBirth forKey:@"dateOfBirth"];
	[coder encodeObject:imageURL forKey:@"imageURL"];
	[coder encodeObject:firstRecord forKey:@"firstRecord"];
	[coder encodeObject:createdDate forKey:@"createdDate"];
	[coder encodeObject:lastUpdatedDate forKey:@"lastUpdatedDate"];
	[coder encodeObject:householdMemberType forKey:@"householdMemberType"];
	[coder encodeObject:status forKey:@"status"];
	[coder encodeObject:rawImage forKey:@"rawImage"];
    [coder encodeObject:addresses forKey:@"addresses"];
}

@end
//
//  Person.m
//  F1Touch
//
//  Created by Matt Vasquez on 4/17/09.
//  Copyright 2009 Fellowship Technologies. All rights reserved.
//

#import "FTPerson.h"
#import "JSON.h"
#import "FTHouseholdMemberType.h"
#import "FTStatus.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "FTOAuthResult.h"
#import "FTOAuth.h"
#import "NSDate+ageFromDate.h"
#import "PagedEntity.h"
#import "ConsoleLog.h"

@interface FTPerson ()

@property (nonatomic, retain) FTOAuth *oauth;

@end

@interface FTPerson (PRIVATE)

- (NSString *) getSearchIncludeString:(PeopleSearchInclude)include;

+(FTPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching;
+(FTPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage;

- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage;
- (id)initWithDictionary:(NSDictionary *)dict searching:(BOOL)searching;
- (id)initWithDictionary:(NSDictionary *)dict;
@end


@implementation FTPerson

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
@synthesize oauth;

#pragma mark Additional Properties

- (id)delegate {
	return _delegate;
}

- (void) setDelegate: (id)newDelegate {
	
	if (_delegate) [_delegate release];
	_delegate = newDelegate;
}

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

+(FTPerson *)populateFromDictionary: (NSDictionary *)dict {
	
	return [FTPerson populateFromDictionary:dict searching:NO];
}

+(FTPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching {
	
	return [[[FTPerson alloc] initWithDictionary:dict searching:searching] autorelease];
}

+(FTPerson *) populateFromDictionary: (NSDictionary *)dict searching:(BOOL)searching preloadImage:(BOOL)preloadImage {
	return [[[FTPerson alloc] initWithDictionary:dict searching:searching preloadImage:preloadImage] autorelease];
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
	
	self.oauth = [[FTOAuth alloc] initWithDelegate:self];
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
	
	
	if (!searching) {
		
		if (preloadImage) {
			if (self.imageURL.length == 0) {
				self.imageURL = nil;
			}
			else {
				self.rawImage = [self getImageDataSynchronously:@"S"];
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
		
		self.householdMemberType = [FTHouseholdMemberType populateFromDictionary:[dict objectForKey:@"householdMemberType"]];
		self.status = [FTStatus populateFromDictionary:[dict objectForKey:@"status"]];
	}
	
	return self;
}

- (NSString *) getSearchIncludeString:(PeopleSearchInclude)include {
	
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
#pragma mark Initialization


- (id) initWithDelegate: (id)delegate {

	if (self = [super init]) {
		self.delegate = delegate;
		self.oauth = [[FTOAuth alloc] initWithDelegate:self];
	}
	return self;		
}

#pragma mark -
#pragma mark Helpers

- (void)getImageData:(NSString *)size {

	if (self.imageURL) {
		NSMutableString *imageFullURL = [NSString stringWithFormat:@"%@?size=%@", self.imageURL, size];
		
		// There is a possibility when calling this method that the oauth object has not been initialized. If it hasn't init it here
		if (!oauth) {
			self.oauth = [[FTOAuth alloc] initWithDelegate:self];
		}
		
		[oauth callFTAPIWithURL:[NSURL URLWithString:imageFullURL] forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	}
	else {
		[ConsoleLog LogMessage:[NSString stringWithFormat:@"person id %d does not have an image URL.", self.myId]];
	}
}

- (NSData *)getImageDataSynchronously:(NSString *)size {
	NSData *rawData = nil;
	
	if (self.imageURL) {
		NSMutableString *imageFullURL = [NSString stringWithFormat:@"%@?size=%@", self.imageURL, size];
		
		NSURL *nsImageURL = [NSURL URLWithString:imageFullURL];
		
		FTOAuthResult *result = [oauth callSyncFTAPIWithURL:nsImageURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
		
		if (result.isSucceed) {
			rawData = [result.returnImageData retain];
		}
	}	
	
	return rawData;
}


#pragma mark -
#pragma mark Find

- (void)getByID:(NSInteger)personID {
	
	NSString *personURL = [NSString stringWithFormat:@"People/%d.json", personID];
	[oauth callFTAPIWithURLSuffix:personURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
}

- (void) getByUrl: (NSString *)theUrl {

	// Create a url from the string
	NSURL *personInfoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@.json", theUrl]];
	
	[oauth callFTAPIWithURL:personInfoURL forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil];
	
}

- (void) searchForPeople: (NSString *)searchText withSearchIncludes:(NSArray *)includes withPage: (NSInteger)pageNumber {
	
	NSMutableString *peopleSearchURL = [NSMutableString stringWithFormat:@"People/Search.json?searchFor=%@&page=%d&recordsperpage=20", searchText, pageNumber];
	
	// If there are includes, add them to the people search URL
	if (includes) {
		NSMutableString *includesString = [NSMutableString stringWithString:@""];
		
		// Loop through all the array objects
		for (int i = 0; i < [includes count]; i++) {
			
			if ([includesString length] > 0) {
				[includesString appendString:@","];
			}
			
			[includesString appendString:[self getSearchIncludeString:(PeopleSearchInclude)[includes objectAtIndex:i]]];
		}
		
		[peopleSearchURL appendString:includesString];
	}
	

	[oauth callFTAPIWithURLSuffix:peopleSearchURL
						 forRealm:FTAPIRealmBase 
				   withHTTPMethod:HTTPMethodGET 
						 withData:nil];
}

+ (FTPerson *)getByURLSynchronously:(NSString *)theUrl {
	
	FTPerson *returnPerson = nil;
	
	FTOAuth *syncOAuth = [[FTOAuth alloc] init];
	
	FTOAuthResult *result = [[syncOAuth callSyncFTAPIWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.json", theUrl]] forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil] retain];
	
	if (result.isSucceed) {
		returnPerson = [FTPerson populateFromDictionary:[result.returnData objectForKey:@"person"] searching:NO];
	}
	
	[result release];
	[syncOAuth release];
	
	return returnPerson;
}

+ (FTPerson *)findSynchronouslyByUrl:(NSString *)theUrl searching:(BOOL)searching {
	
	FTPerson *returnPerson = nil;
	
	FTOAuth *syncOAuth = [[FTOAuth alloc] init];
	
	FTOAuthResult *result = [[syncOAuth callSyncFTAPIWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.json", theUrl]] forRealm:FTAPIRealmBase withHTTPMethod:HTTPMethodGET withData:nil] retain];

	if (result.isSucceed) {
		returnPerson = [FTPerson populateFromDictionary:[result.returnData objectForKey:@"person"] searching:searching];
	}

	[result release];
	[syncOAuth release];
	
	return returnPerson;
	
}

#pragma mark -

- (void) ftOauth: (FTOAuth *)ftOAuth didComplete: (FTOAuthResult *) result {
	
	if (result.isSucceed) {
		
		if (result.returnData != nil) {
			
			PagedEntity *resultsEntity;
			NSDictionary *topLevel = [result.returnData objectForKey:@"results"];
			NSArray *results = [topLevel objectForKey:@"person"];
			
			
			if (results) {
				
				NSMutableArray *people = [[NSMutableArray alloc] init];
				
				for (NSDictionary *result in results) {
					[people addObject:[FTPerson populateFromDictionary:result searching:YES]];
				}	
				
				// Create the paged entity
				resultsEntity = [[PagedEntity alloc] init];
				
				resultsEntity.currentCount = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@count"]];
				resultsEntity.pageNumber = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@pageNumber"]];
				resultsEntity.totalRecords = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@totalRecords"]];
				resultsEntity.additionalPages = [FellowshipOneAPIUtility convertToInt:[topLevel objectForKey:@"@additionalPages"]];
				
				
				resultsEntity.results = people;
				
				if ([self.delegate respondsToSelector:@selector(FTPeopleReturned:)]) {
					[[self delegate] FTPeopleReturned:resultsEntity];
				}
				
				[people release];
				
			}
			else {
				
				// The result is either for one individual or for people image data, find out which
				if (result.returnImageData) {
					if ([self.delegate respondsToSelector:@selector(FTPersonImageReturned:)]) {
						[[self delegate] FTPersonImageReturned:result.returnImageData];
					}
				}
				else {
					// Must only be one individual, check it out
					if ([result.returnData objectForKey:@"person"]) {
						if ([self.delegate respondsToSelector:@selector(FTPersonReturned:)]) {
							FTPerson *returnedPerson =[FTPerson populateFromDictionary:[result.returnData objectForKey:@"person"]];
							[[self delegate] FTPersonReturned:returnedPerson];
						}
					}
				}
			}
		}
	}
	else {
		if ([self.delegate respondsToSelector:@selector(FTPersonFail:)]) {
			[[self delegate] FTPersonFail:nil];
		}
	}
		
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
	if (_delegate) [_delegate release];
	[super dealloc];
	
	if (oauth) [oauth release];
}

#pragma mark -
#pragma mark NSCoding Methods

- (id) initWithCoder: (NSCoder *)coder {
	
	self = [[FTPerson	alloc] init];
	
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
}

@end

/*
 Copyright (C) 2010 Fellowship Technologies. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 
 FellowshipOneAPIClient is a Cocoa Touch static library responsibile for constrcuting
 well formed signed OAuth requests to the Fellowship One API. The library promises to 
 eliminate the need to understand the inner workings of OAuth and signing to allow 
 developers to quickly get up and running building cocoa touch applications that
 integrate with the Fellowship One API
 
 For more information on OAUTH, please visit http://www.oauth.net
 
 For more information on the Fellowship One API, please visit http://developer.fellowshipone.com/docs/
 
 */

/* 
 
 inferface purpose: Fellowship One API exposes the household resource. This interface provides ways
 to interact with the household resource and holds all the properties the resource exposes
 
 */

#import <Foundation/Foundation.h>


@class PagedEntity;
@class FTOAuth;
@class FTError;

@protocol FTHouseholdDelegate;

typedef enum {
	HouseholdSearchTypeName, // Search for a household by name
	HouseholdSearchTypePhoneNumber // Search for a household by a phone number
} HouseholdSearchType;

@interface FTHousehold : NSObject {
	
	NSString			*url; 
	NSInteger			myId; 
	NSInteger			myOldId;
	NSString			*householdCode;
	NSString			*householdName;
	NSString			*householdSortName;
	NSString			*householdFirstName;
	NSDate				*lastSecurityAuthorization;
	NSDate				*lastActivityDate;
	NSDate				*createdDate;
	NSDate				*lastUpdatedDate;
	NSArray			*allMembers;
	id<FTHouseholdDelegate>	_delegate;
	
	@private FTOAuth *oauth;
	@private NSDictionary *_serializationMapper;
}

// Delegate for the object
@property (nonatomic,assign, )	id<FTHouseholdDelegate> delegate;
@property (nonatomic, copy)		NSString *url; 
@property (nonatomic, assign)	NSInteger myId; 
@property (nonatomic, assign)	NSInteger myOldId; 
@property (nonatomic, copy) NSString *householdCode;
@property (nonatomic, copy)		NSString *householdName;
@property (nonatomic, copy) NSString *householdSortName;
@property (nonatomic, copy) NSString *householdFirstName;
@property (nonatomic, retain) NSDate *lastSecurityAuthorization;
@property (nonatomic, retain) NSDate *lastActivityDate;
@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) NSDate *lastUpdatedDate;

/* maps the properties in this class to the required properties and order from an API request. 
 This is needed for when the object is saved since the xsd requires a certain order for all fields */
@property (nonatomic, readonly, assign) NSDictionary *serializationMapper;

// All the members that belong to this household
@property (nonatomic, retain)	NSArray *allMembers;

// All the members of the household (Head, Spouse, Child, Other)
@property (nonatomic, readonly) NSArray *members;

// Members of the household who are tagged as visitors
@property (nonatomic, readonly) NSArray *visitors;

// Creates and instance of FTHousehold passing in the delegate
- (id) initWithDelegate:(id)delegate;

// Get a household from the API based on the household id
- (void) getByID: (NSInteger)hsdID;

// Search the F1 database for households this will return 5 households at a time, because the method gets the individual
// members tied to the household, 5 was considered to be an optimal number where performance was not weakened
// searchText: The text to search by
// householdSearchType: Determines the type of search the API is doing
// pageNumber: the page number the search is for
- (void) searchForHouseholds: (NSString *)searchText householdSearchType: (HouseholdSearchType)searchType withPage: (NSInteger)pageNumber;

/* Saves an FTHousehold. If the object has an id, it assumes its an update, if no id exists, 
 it will attempt to create the object into the API */
- (void) save;

/* Saves an FTHousehold. If the object has an id, it assumes its an update, if no id exists, 
 it will attempt to create the object into the API */
- (void) saveSynchronously;

@end

@protocol FTHouseholdDelegate<NSObject>

// This method is required to consume the delegate. If a household fails, an error will be returned
- (void) FTHouseholdFail: (FTError *)error;

@optional
// Implement for when multiple households are returned
- (void) FTHouseholdsReturned: (PagedEntity *)households;

// Implement for when one household is returned
- (void) FThouseholdReturned: (FTHousehold *)household;

@end


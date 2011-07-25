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


@class FOPagedEntity;
@class FTOAuth;
@class FTError;
@class FOHouseholdQO;

typedef enum {
	HouseholdSearchTypeName, // Search for a household by name
	HouseholdSearchTypePhoneNumber // Search for a household by a phone number
} HouseholdSearchType;

@interface FOHousehold : NSObject {
	
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
	NSArray             *allMembers;

@private NSDictionary *_serializationMapper;
}

// Delegate for the object
@property (nonatomic, copy)		NSString *url; 
@property (nonatomic, assign)	NSInteger myId; 
@property (nonatomic, assign)	NSInteger myOldId; 
@property (nonatomic, copy)     NSString *householdCode;
@property (nonatomic, copy)		NSString *householdName;
@property (nonatomic, copy)     NSString *householdSortName;
@property (nonatomic, copy)     NSString *householdFirstName;
@property (nonatomic, retain)   NSDate *lastSecurityAuthorization;
@property (nonatomic, retain)   NSDate *lastActivityDate;
@property (nonatomic, retain)   NSDate *createdDate;
@property (nonatomic, retain)   NSDate *lastUpdatedDate;

/* maps the properties in this class to the required properties and order from an API request. 
 This is needed for when the object is saved since the xsd requires a certain order for all fields */
@property (nonatomic, readonly, assign) NSDictionary *serializationMapper;

// All the members that belong to this household
@property (nonatomic, retain)	NSArray *allMembers;

// All the members of the household (Head, Spouse, Child, Other)
@property (nonatomic, readonly) NSArray *members;

// Members of the household who are tagged as visitors
@property (nonatomic, readonly) NSArray *visitors;

// Get a household from the API based on the household id
+ (FOHousehold *) getByID: (NSInteger)hsdID;

// Get a household from the API based on the household id ascynchornously
+ (void) getByID: (NSInteger)hsdID usingCallback:(void (^)(FOHousehold *))returnedHousehold;

/* Calls the API to save the current address. If there is an ID attached to the address, the method assumes an update, if no id exists, the method assumes create */
- (void) save;

/* Calls the API to save the current address. If there is an ID attached to the address, the method assumes an update, if no id exists, the method assumes create */
- (void) saveUsingCallback:(void (^)(FOHousehold *))returnHousehold;

/* populates an FOHousehold object from a NSDictionary */
+ (FOHousehold *)populateFromDictionary: (NSDictionary *)dict;

// Search the F1 database for households and also retrieves the people for those households -- This method is performed asynchronously --
// searchText: The text to search by
// qo: The queryobject that holds are the search things
+ (void) searchForHouseholds: (FOHouseholdQO *)qo usingCallback:(void (^)(FOPagedEntity *))pagedResults;

/* Calls the API to save the current household. If there is an ID attached to the household, the method assumes an update, if no id exists, the method assumes create */
- (void) save;

/* Calls the API to save the current household. If there is an ID attached to the household, the method assumes an update, if no id exists, the method assumes create */
- (void) saveUsingCallback:(void (^)(FOHousehold *))returnHousehold;

@end

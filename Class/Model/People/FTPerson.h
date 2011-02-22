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
 
 inferface purpose: FTPerson is the person object for the fellowship one api. 
 You may get more information by going to https://demo.fellowshiponeapi.com/v1/people.help
 
 */

#import <Foundation/Foundation.h>


/* Enum that informs the search methods what to include in the search parameters */
typedef enum {
	PeopleSearchIncludeAddresses, // Include people addresses in search
	PeopleSearchIncludeCommunications, // Include communications in search
	PeopleSearchIncludeAttributes // Include attributes in search
} PeopleSearchInclude;

@class FTOAuth;
@class FTHouseholdMemberType;
@class FTStatus;
@class PagedEntity;
@class FTOAuthResult;
@class FTError;

@protocol FTPersonDelegate;


@interface FTPerson : NSObject <NSCoding> {
	
	id<FTPersonDelegate>		_delegate;
	NSString				*url;
	NSInteger				myId;
	NSInteger				householdId;
	NSString				*firstName;
	NSString				*middleName;
	NSString				*goesByName;
	NSString				*lastName;
	NSString				*suffix;
	NSString				*title;
	NSString				*prefix;
	NSString				*gender;
	NSString				*salutation;
	NSString				*maritalStatus;
	NSString				*formerName;
	NSDate					*dateOfBirth;
	NSString				*imageURL;
	NSDate					*firstRecord;
	NSDate					*createdDate;
	NSDate					*lastUpdatedDate;
	FTHouseholdMemberType	*householdMemberType;
	FTStatus				*status;
	NSData					*rawImage;
	@private FTOAuth		*oauth;
}

@property (nonatomic, assign)	id<FTPersonDelegate> delegate;
@property (nonatomic, assign)	NSInteger myId;
@property (nonatomic, assign)	NSInteger householdId;
@property (nonatomic, copy)		NSString *url;
@property (nonatomic, copy)		NSString *firstName;
@property (nonatomic, copy)		NSString *middleName;
@property (nonatomic, copy)		NSString *goesByName;
@property (nonatomic, copy)		NSString *lastName;
@property (nonatomic, copy)		NSString *suffix;
@property (nonatomic, copy)		NSString *title;
@property (nonatomic, copy)		NSString *prefix;
@property (nonatomic, copy)		NSString *gender;
@property (nonatomic, copy)		NSString *salutation;
@property (nonatomic, copy)		NSString *maritalStatus;
@property (nonatomic, copy)		NSString *formerName;
@property (nonatomic, retain)	NSDate *dateOfBirth;
@property (nonatomic, copy)		NSString *imageURL;
@property (nonatomic, retain)	NSDate *firstRecord;
@property (nonatomic, retain)	NSDate *createdDate;
@property (nonatomic, retain)	NSDate *lastUpdatedDate;
@property (nonatomic, retain)	FTHouseholdMemberType *householdMemberType;
@property (nonatomic, retain)	FTStatus *status;
@property (nonatomic, retain)	NSData *rawImage;

// Convienence property for returning a casual name
// The property tries to get the GoesBy name, if one doesn't exist it gets the First Name
// Then the property gets the last name and then if there is a suffix, appends that to the end
@property (nonatomic, assign, readonly) NSString *casualName;

// Convienence property for returning a an age
// Takes the date of birth and calculates the age in years, if the age is less than 1, the word "child" is returned
@property (nonatomic, assign, readonly) NSString *age;

// Initialize an FTPerson and set the delegate
- (id)initWithDelegate: (id)delegate;

// Search the F1 database for individual this will return 20 individuals at a time -- This method is performed asynchronously --
// searchText: The text to search by
// includes: an array of things to include in the search results :: See PeopleSearchInclude enum
// pageNumber: the page number the search is for
- (void) searchForPeople: (NSString *)searchText withSearchIncludes:(NSArray *)includes withPage: (NSInteger)pageNumber;

// Performs a query on the F1 API to return a single person based on the provided person id -- This method is performed asynchronously --
- (void) getByID: (NSInteger)personID;

// Performs a query on the F1 API to return a single person based on the provided url string. -- This method is performed asynchronously --
- (void) getByUrl: (NSString *)theUrl;

// Returns a portait image from the F1API specified by the size S, M, or L are the options. -- This method is called asynchronously --
// Image will be returned in the FTPersonImageReturned delegate method
- (void)getImageData:(NSString *)size;

// Returns a portait image from the F1API specified by the size S, M, or L are the options. -- This method is called synchronously --
- (NSData *)getImageDataSynchronously:(NSString *)size;

// Performs a query on the F1 API to return a single person based on the url. -- This method is performed synchronously --
+ (FTPerson *)getByURLSynchronously:(NSString *)theUrl;

// Used to construct a person object from an NSDictionary. The NSDictionary is the json repesentation of the person object. 
// NOTE :: This method is not supported outside the library itself, use at your own risk.
+(FTPerson *) populateFromDictionary: (NSDictionary *)dict;

@end

@protocol FTPersonDelegate<NSObject>

@optional

// This method is required to consume the delegate. If a household fails, an error will be returned
- (void) FTPersonFail: (FTError *)error;

@optional
// Implement for when multiple individual are returned
- (void) FTPeopleReturned: (PagedEntity *)people;

// Implement for when one individual is returned
- (void) FTPersonReturned: (FTPerson *)person;

// Implement for when requesting an individual image
- (void)FTPersonImageReturned: (NSData *)imageData;

@end


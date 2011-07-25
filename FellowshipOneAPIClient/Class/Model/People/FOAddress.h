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
 
 inferface purpose: In order to use the fellowship one api, the first steps is to acquire an access token from the server
 The purpose here is to provide all methods necessary to logging into the API and gaining an access token along with providing
 some global methods
 
 */

#import <Foundation/Foundation.h>

@class FTError;
@class FTOAuth;
@class FOPagedEntity;
@class FOParentObject;
@class FOParentNamedObject;

@interface FOAddress : NSObject <NSCoding> {
	
	NSString *url;
	NSInteger myId;
	FOParentObject *household;
	FOParentObject *person;
	NSString *street1;
	NSString *street2;
	NSString *street3;
	NSString *city;
	NSString *state;
	NSString *postalCode;
	NSString *county;
	NSString *country;
	NSString *comment;
	NSString *carrierRoute;
	NSString *deliveryPoint;
	NSDate *addressDate;
	BOOL uspsVerified;
	NSDate *addressVerifiedDate;
	NSDate *lastVerificationAttemptDate;
	NSDate *createdDate;
	NSDate *lastUpdatedDate;
	FOParentNamedObject *addressType;

@private NSDictionary *_serializationMapper;
}

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger myId;
@property (nonatomic, retain) FOParentObject *household;
@property (nonatomic, retain) FOParentObject *person;
@property (nonatomic, copy) NSString *street1;
@property (nonatomic, copy) NSString *street2;
@property (nonatomic, copy) NSString *street3;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *postalCode;
@property (nonatomic, copy) NSString *county;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *carrierRoute;
@property (nonatomic, copy) NSString *deliveryPoint;
@property (nonatomic, retain) NSDate *addressDate;
@property (nonatomic, assign) BOOL uspsVerified;
@property (nonatomic, retain) NSDate *addressVerifiedDate;
@property (nonatomic, retain) NSDate *lastVerificationAttemptDate;
@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) NSDate *lastUpdatedDate;
@property (nonatomic, retain) FOParentNamedObject *addressType;

/* maps the properties in this class to the required properties and order from an API request. 
 This is needed for when the object is saved since the xsd requires a certain order for all fields */
@property (nonatomic, readonly, assign) NSDictionary *serializationMapper;

/* Convienence property for getting the address into a google map URL. */
@property (nonatomic, readonly) NSString *googleMapURL;

/* Convienence property for formatting the address into the typical USPS format */
@property (nonatomic, readonly) NSString *formattedAddress;

/* Gets all the communications associated with a specific person id -- Thie method is performed synchronously -- */
+ (NSArray *) getByPersonID: (NSInteger) personID;

/* Gets a specific address by the address ID -- this method is performed synchronously */
+ (FOAddress *) getByID: (NSInteger) addressID;

/* Gets all the communications associated with a specific person id -- Thie method is performed asynchronously -- */
+ (void) getByPersonID: (NSInteger)personID usingCallback:(void (^)(NSArray *))results;

/* Gets a specific address by the address ID -- this method is performed asynchronously */
+ (void) getByID: (NSInteger) addressID usingCallback:(void (^)(FOAddress *))returnAddress;

/* Calls the API to save the current address. If there is an ID attached to the address, the method assumes an update, if no id exists, the method assumes create */
- (void) save;

/* Calls the API to save the current address. If there is an ID attached to the address, the method assumes an update, if no id exists, the method assumes create */
- (void) saveUsingCallback:(void (^)(FOAddress *))returnAddress;

/* populates an FTAddress object from a NSDictionary */
+ (FOAddress *)populateFromDictionary: (NSDictionary *)dict;



@end


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
 
 interface purpose: The FOPerson Query Object holds all the properties that a search can account for.
 It does not do the logic checks to make sure certain properties are mutually execlusive. You can find more
 information about searching for people here: http://developer.fellowshipone.com/docs/v1/People.help#search

*/


#import "FOBaseQO.h"


@interface FOPersonQO : FOBaseQO {
    
    NSString *searchTerm;
    NSString *address;
    NSString *communication;
    NSDate *dateOfBirth;
    NSInteger statusId;
    NSInteger subStatusId;
    NSInteger attributeId;
    NSString *checkinTagCode;
    NSString *memberEnvelopeNo;
    NSString *barCode;
    NSArray *peopleIds;
    NSInteger householdId;
    BOOL _includeInactive;
    BOOL _includeDeceased;
    NSDate *lastUpdatedDate;
    NSDate *createdDate;
    NSArray *additionalData;
    
    struct {
		BOOL includeInactive;
		BOOL includeDeceased;
	} _personQODirtyFlags;
}


@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *communication;
@property (nonatomic, retain) NSDate *dateOfBirth;
@property (nonatomic, assign) NSInteger statusId;
@property (nonatomic, assign) NSInteger subStatusId;
@property (nonatomic, assign) NSInteger attributeId;
@property (nonatomic, copy) NSString *checkinTagCode;
@property (nonatomic, copy) NSString *memberEnvelopeNo;
@property (nonatomic, copy) NSString *barCode;
@property (nonatomic, copy) NSArray *peopleIds;
@property (nonatomic, assign) NSInteger householdId;
@property (nonatomic, assign)BOOL includeInactive;
@property (nonatomic, assign) BOOL includeDeceased;
@property (nonatomic, retain) NSDate *lastUpdatedDate;
@property (nonatomic, retain) NSDate *createdDate;

// Additional data is an array that tells the search to include meta data about the person in the search
// Each set of meta data that is wanting to be returned with the search, include in the array
// EX: addresses communications attributes
@property (nonatomic, copy) NSArray *additionalData;

- (NSString *) createQueryString;

@end

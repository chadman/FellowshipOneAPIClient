//
//  Peopleself.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FOPersonQO.h"
#import "NSString+URLEncoding.h"
#import "FellowshipOneAPIUtility.h"


@implementation FOPersonQO

@synthesize searchTerm;
@synthesize address;
@synthesize communication;
@synthesize dateOfBirth;
@synthesize statusId;
@synthesize subStatusId;
@synthesize attributeId;
@synthesize checkinTagCode;
@synthesize memberEnvelopeNo;
@synthesize barCode;
@synthesize peopleIds;
@synthesize householdId;
@synthesize lastUpdatedDate;
@synthesize createdDate;
@synthesize additionalData;


- (BOOL) includeInactive {
    return _includeInactive;
}

- (void) setIncludeInactive:(BOOL)includeInactive {
    
    NSNumber *new = [[NSNumber alloc] initWithInt:includeInactive];
    NSNumber *old = [[NSNumber alloc] initWithInt:_includeInactive];
                      
    
    _personQODirtyFlags.includeInactive = [super getDirtyFlag:new comparer:old];
    _includeInactive = includeInactive;

    [new release];
    [old release];
}

- (BOOL) includeDeceased {
    return _includeDeceased;
}

- (void) setIncludeDeceased:(BOOL)includeDeceased {
    
    NSNumber *new = [[NSNumber alloc] initWithInt:includeDeceased];
    NSNumber *old = [[NSNumber alloc] initWithInt:_includeDeceased];
    
    _personQODirtyFlags.includeDeceased = [super getDirtyFlag:new comparer:old];
    _includeDeceased = includeDeceased;
    
    [new release];
    [old release];
}

- (NSString *) createQueryString {
    
    NSMutableString *queryString = [NSMutableString stringWithString:@"?"];
    BOOL firstParameter = YES;
    
    if (self.searchTerm) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"searchFor", [self.searchTerm URLEncodedString]];
        firstParameter = NO;
    }
    
    if (self.address) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"address", [self.address URLEncodedString]];
        firstParameter = NO;
    }
    
    if (self.communication) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"communication", [self.communication URLEncodedString]];
        firstParameter = NO;
    }
    
    if (self.checkinTagCode) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"checkinTagCode", [self.checkinTagCode URLEncodedString]];
        firstParameter = NO;
    }
    
    if (self.memberEnvelopeNo) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"memberEnvelopeNo", [self.memberEnvelopeNo URLEncodedString]];
        firstParameter = NO;
    }
    
    if (self.barCode) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"barCode", [self.barCode URLEncodedString]];
        firstParameter = NO;
    }
    
    if (self.dateOfBirth) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"dob", [FellowshipOneAPIUtility convertToNSDate:self.dateOfBirth]];
        firstParameter = NO;
    }
    
    
    if (self.lastUpdatedDate) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"lastActivityDate", [FellowshipOneAPIUtility convertToNSDate:self.lastUpdatedDate]];
        firstParameter = NO;
    }
    
    if (self.createdDate) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%@", @"createdDate", [FellowshipOneAPIUtility convertToNSDate:self.createdDate]];
        firstParameter = NO;
    }
    
    if (self.statusId > 0) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%d", @"status", self.statusId];
        firstParameter = NO;
    }
    
    if (self.subStatusId > 0) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%d", @"subStatus", self.subStatusId];
        firstParameter = NO;
    }
    
    if (self.attributeId > 0) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%d", @"attribute", self.attributeId];
        firstParameter = NO;
    }
    
    if (self.householdId > 0) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%d", @"hsdid", self.householdId];
        firstParameter = NO;
    }
    
    if (_personQODirtyFlags.includeDeceased) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%d", @"includeDeceased", self.includeDeceased];
        firstParameter = NO;
    }
    
    if (_personQODirtyFlags.includeInactive) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
        [queryString appendFormat:@"%@=%d", @"includeDeceased", self.includeInactive];
        firstParameter = NO;
    }
    
    if (additionalData) {
        if (!firstParameter) {
            [queryString appendString:@"&"];
        }
		NSMutableString *includesString = [NSMutableString stringWithString:@""];
		
		// Loop through all the array objects
		for (int i = 0; i < [additionalData count]; i++) {
			
			if ([includesString length] > 0) {
				[includesString appendString:@","];
			}
			
			[includesString appendString:[additionalData objectAtIndex:i]];
		}
		
		[queryString appendString:@"include="];
        [queryString appendString:includesString];
        firstParameter = NO;
	}

    
    // Append the page number and records per page
    if (!firstParameter) {
        [queryString appendString:@"&"];
    }
    [queryString appendFormat:@"%@=%d", @"page", self.pageNumber];
    firstParameter = NO;
    
    if (!firstParameter) {
        [queryString appendString:@"&"];
    }
    [queryString appendFormat:@"%@=%d", @"recordsperpage", self.recordsPerPage];
    firstParameter = NO;
    
    return queryString;
}


- (void) dealloc {
    [super dealloc];
    [address release];
    [communication release];
    [dateOfBirth release];
    [checkinTagCode release];
    [barCode release];
    [peopleIds release];
    [lastUpdatedDate release];
    [createdDate release];
}

@end

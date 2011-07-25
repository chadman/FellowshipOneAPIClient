//
//  HouseholdQO.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FOHouseholdQO.h"


@implementation FOHouseholdQO
@synthesize searchTerm;
@synthesize lastActivityDate;
@synthesize lastUpdatedDate;
@synthesize createdDate;

- (void) dealloc {
    [super dealloc];
    [searchTerm release];
    [lastActivityDate release];
    [lastUpdatedDate release];
    [createdDate release];
}

@end

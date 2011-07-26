//
//  GroupMemberQO.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupMemberQO.h"


@implementation GroupMemberQO
@synthesize memberName;
@synthesize memberTypeId;
@synthesize personId;


- (void) dealloc {
    [memberName release];
    [super dealloc];
}

@end

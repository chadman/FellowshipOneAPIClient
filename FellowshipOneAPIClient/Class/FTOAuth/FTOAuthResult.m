//
//  FTOAuthResult.m
//  Fellowship
//
//  Created by Chad Meyer on 5/4/09.
//  Copyright 2009 Fellowship Tech. All rights reserved.
//

#import "FTOAuthResult.h"
#import "FTOAuth.h"



@implementation FTOAuthResult


@synthesize returnData;
@synthesize isSucceed;
@synthesize returnImageData;


- (void) dealloc
{
	[returnData release];
	[returnImageData release];
	[super dealloc];
}

@end

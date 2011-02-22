//
//  FTError.m
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FTError.h"


@implementation FTError

@synthesize errorMessage, statusCode, headerFields;



- (void) dealloc {

	[errorMessage release];
	[statusCode release];
	[headerFields release];
	[super dealloc];
}

@end

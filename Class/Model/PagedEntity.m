//
//  PagedObject.m
//  F1Touch
//
//  Created by Meyer, Chad on 2/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PagedEntity.h"


@implementation PagedEntity

@synthesize currentCount;
@synthesize pageNumber;
@synthesize totalRecords;
@synthesize additionalPages;
@synthesize results;


- (void) dealloc {

	[results release];
	
	[super dealloc];
	
}

@end

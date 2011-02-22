//
//  ConsoleLog.m
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ConsoleLog.h"


@implementation ConsoleLog

+ (void) LogMessage:(NSString *)message {

	NSLog(@"FT API Framework :: %@", message);
}

@end

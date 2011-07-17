//
//  BaseTest.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseTest.h"
#import "FellowshipOneAPIClient.h"


@implementation BaseTest

- (void)setUp
{
    [super setUp];
    condition = [[NSCondition alloc] init];
    
    // Kill the defaults at the beginning of every test
    [FellowshipOneAPIClient removeOAuthTicket];
    
    // Always set a church code
    [FellowshipOneAPIClient setChurchCode:@"dc"];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
    [condition release];
}

- (void) runLoop {
    
    @try {
        // This executes another run loop.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // Sleep 1/100th sec
        usleep(10000);
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }

}


@end

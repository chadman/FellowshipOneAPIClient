//
//  FOPerson.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#import "FOPerson.h"
#import "FellowshipOneAPIClient.h"
#import "FOPagedEntity.h"
#import "FOAddress.h"
#import "FOPersonQO.h"


@implementation Person

- (void)setUp {
    [FellowshipOneAPIClient createOAuthTicket:@"b019af55-6279-457e-b64d-4c74cb931253" withSecret:@"e6e78ee2-6b04-4420-9fb8-b84625c2e14d" forChurchCode:@"dc"];    
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}


- (void) testGetById {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    
    [FOPerson getByID:8266692 usingCallback:^(FOPerson *returnedPerson) {
       
        STAssertNotNil(returnedPerson, @"Getting person by id failed.");
        done = YES;

    }];

    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testGetById");
        }
    }
}

- (void) testSearchResults {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    FOPersonQO *qo = [[FOPersonQO alloc] init];
    qo.searchTerm = @"sm";
    qo.pageNumber = 1;
    qo.recordsPerPage = 10;
    
    [FOPerson searchForPeople:qo usingCallback:^(FOPagedEntity *pagedResults) {
        STAssertTrue([pagedResults.results count] > 0, @"No results were returned.");
        [qo release];
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testSearchResults");
        }
    }
}

- (void) testSearchNoResults {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    // Testing using blocks for authentication
    FOPersonQO *qo = [[FOPersonQO alloc] init];
    qo.searchTerm = @"asdfasdfadsfasdf";
    qo.pageNumber = 1;
    qo.recordsPerPage = 10;
    
    [FOPerson searchForPeople:qo usingCallback:^(FOPagedEntity *pagedResults) {
        STAssertTrue([pagedResults.results count] == 0, @"results were returned.");
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testSearchNoResults");
        }
    }
    
    [qo release];
}

- (void) testSearchIncludeAddress {
    __block BOOL done= NO;
    __block BOOL foundAddress = NO;
    int count = 0;
    
    NSArray *includes = [[NSArray alloc] initWithObjects:[FOPerson getSearchIncludeString:PeopleSearchIncludeAddresses], nil];
    // Testing using blocks for authentication
    FOPersonQO *qo = [[FOPersonQO alloc] init];
    qo.searchTerm = @"meyer";
    qo.pageNumber = 1;
    qo.recordsPerPage = 10;
    qo.additionalData = includes;
    
    [FOPerson searchForPeople:qo usingCallback:^(FOPagedEntity *pagedResults) {
        
        // Looks through the results and look for addresses
        for (FOPerson *currentPerson in pagedResults.results) {
            
            if (currentPerson.addresses && [currentPerson.addresses count] > 0) {
                foundAddress = YES;
                break;
            }
        }
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testSearchIncludeAddress");
        }
    }
    
    [includes release];
    [qo release];
    
    STAssertTrue(foundAddress, @"No addresses were found.");
}

- (void) testSearchIncludeCommunication {
    
    __block BOOL done= NO;
    __block BOOL foundCommunications = NO;
    int count = 0;

    NSArray *includes = [[NSArray alloc] initWithObjects:[FOPerson getSearchIncludeString:PeopleSearchIncludeCommunications], nil];
    FOPersonQO *qo = [[FOPersonQO alloc] init];
    qo.searchTerm = @"meyer";
    qo.pageNumber = 1;
    qo.recordsPerPage = 10;
    qo.additionalData = includes;
    
    
    [FOPerson searchForPeople:qo usingCallback:^(FOPagedEntity *pagedResults) {
        
        // Looks through the results and look for addresses
        for (FOPerson *currentPerson in pagedResults.results) {
            
            if (currentPerson.communications && [currentPerson.communications count] > 0) {
                foundCommunications = YES;
                break;
            }
        }
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testSearchIncludeCommunication");
        }
    }
    
    [includes release];
    [qo release];
    
    STAssertTrue(foundCommunications, @"No communications were found.");
}

- (void) testSearchIncludeAttributes {
    
    
    /*
     __block BOOL done= NO;
     int count = 0;
    NSMutableArray *includes = [[NSMutableArray alloc] initWithObjects:nil];
    [includes addObject:(id)PeopleSearchIncludeAttributes];
    
    
    [FOPerson searchForPeople:@"meyer" withSearchIncludes:includes withPage:1 usingCallback:^(PagedEntity *pagedResults) {
        STAssertTrue([pagedResults.results count] == 0, @"results were returned.");
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testSearchNoResults");
        }
    }
    
    [includes release];
    
    */
}

- (void) testGetImage {
    __block BOOL done= NO;
    int count = 0;
    
    // Testing using blocks for authentication
    
    [FOPerson getImageData:8266692 withSize:@"M" usingCallback:^(NSData *returnedImage) {
        
        STAssertNotNil(returnedImage, @"Getting image by person id failed.");
        done = YES;
        
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testGetImage");
        }
    }
}

- (void) testGetSynchronouslyById {
    FOPerson *person = [FOPerson getByID:8266692];
    
    STAssertNotNil(person, @"person not returned.");
}

- (void)testGetSynchronouslyByUrl {
    
    __block BOOL done= NO;
    int count = 0;
    
    [FellowshipOneAPIClient removeOAuthTicket];
    
    // Testing using blocks for authentication
    FellowshipOneAPIClient *client = [[FellowshipOneAPIClient alloc] init];
    
    [client authenticatePortalUser:@"tcoulson" password:@"FT.Admin1" usingBlock:^(id block) {
        
        FOPerson *person = [FOPerson getByUrl:[NSString stringWithFormat:@"%@%@", [FellowshipOneAPIClient loggedUserURL], @".json"]];
        STAssertNotNil(person, @"retrieve by url not populated.");
        done = YES;
    }];
    
    while (!done) {
        
        if (count < 20) {
            count++;
            [self runLoop];
        }
        else {
            done = YES;
            STFail(@"Did not complete testGetImage");
        }
    }
    
    [client release];
    
}

@end

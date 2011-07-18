//
//  FOPerson.h
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "BaseTest.h"


@interface Person : BaseTest {
    
}

- (void) testGetById;

- (void) testSearchNoResults;

- (void) testSearchResults;

- (void) testSearchIncludeAddress;

- (void) testSearchIncludeCommunication;

- (void) testSearchIncludeAttributes;

- (void) testGetImage;

- (void) testGetSynchronouslyById;

- (void) testGetSynchronouslyByUrl;

@end

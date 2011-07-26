//
//  Address.h
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "BaseTest.h"

@class FOAddress;


@interface Address : BaseTest {
    
}

- (void) testGetAddressByPerson;

- (void) testGetAddressesByPersonWithCallBack;

- (void) testGetAddressByID;

- (void) testGetAddressByIDWithCallBack;

- (void) testUpdateAddress;

- (void) testUpdateAddressWithCallBack;

- (void) testCreateAddress;

- (void) testCreateAddressWithCallBack;

- (void) testDeleteAddress;

- (void) testDeleteAddressWithCallBack;

- (FOAddress *) createAnAddress;
@end

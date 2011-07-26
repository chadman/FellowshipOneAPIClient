//
//  GroupMemberQO.h
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FOBaseQO.h"


@interface GroupMemberQO : FOBaseQO {
    
    NSString *memberName;
    NSInteger memberTypeId;
    NSInteger personId;
}


@property (nonatomic, copy) NSString *memberName;
@property (nonatomic, assign) NSInteger memberTypeId;
@property (nonatomic, assign) NSInteger personId;

@end
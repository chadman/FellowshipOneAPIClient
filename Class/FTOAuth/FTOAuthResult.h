//
//  FTOAuthResult.h
//  Fellowship
//
//  Created by Chad Meyer on 5/4/09.
//  Copyright 2009 Fellowship Tech. All rights reserved.
//

#import "FTAPIRealm.h"
#import "HTTPMethod.h"

@interface FTOAuthResult : NSObject {

	NSDictionary	*returnData;
	BOOL			isSucceed;
	NSData			*returnImageData;
}


@property (readwrite, nonatomic, retain) NSDictionary *returnData;
@property (nonatomic) BOOL isSucceed;
@property (readwrite, nonatomic, retain) NSData *returnImageData;

@end


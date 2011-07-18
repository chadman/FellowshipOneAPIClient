//
//  FTUserDefaults.h
//  Fellowship
//
//  Created by Chad Meyer on 4/29/09.
//  Copyright 2009 Fellowship Tech. All rights reserved.
//


@interface FOUserDefaults : NSObject {

	NSString		*churchCode;
	NSString		*acessToken;
	NSString		*acessTokenSecret;
	NSString		*loggedUserURI;
}

@property (readwrite, retain) NSString *churchCode;
@property (readwrite, retain) NSString *accessToken;
@property (readwrite, retain) NSString *accessTokenSecret;
@property (readwrite, retain) NSString *loggedUserURI;

+ (FOUserDefaults *)sharedInstance; 
+ (void)killAllFTDefaults;

@end

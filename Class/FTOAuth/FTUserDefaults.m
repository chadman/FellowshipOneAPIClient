//
//  FTUserDefaults.m
//  Fellowship
//
//  Created by Chad Meyer on 4/29/09.
//  Copyright 2009 Fellowship Tech. All rights reserved.
//

#import "FTUserDefaults.h"
#import "Constants.h"
#import "FellowshipOneAPIUtility.h"
#import "ConsoleLog.h"
#import "Constants.h"

@implementation FTUserDefaults

+ (FTUserDefaults *)sharedInstance {
	static FTUserDefaults *sharedInstance;
	
	@synchronized(self) {
		if (!sharedInstance) {
			sharedInstance = [[FTUserDefaults alloc] init];
		}
	}
	
	return sharedInstance;
}

+ (void)killAllFTDefaults {
	// Remove all the defaults currently shown in this file, currently
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accessTokenSecret"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loggedUserURI"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"churchCode"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)churchCode {
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *returnVal = [userDefaults stringForKey:@"churchCode"];
	
	if (returnVal != nil) {
		return returnVal;
	}
	else {
		// If the church code is nil in the user defaults, check the plist
		returnVal = [FellowshipOneAPIUtility getValueFromPList:kApiPlistName withListKey:@"churchCode"];
		
		if (!returnVal) {
			returnVal = @"";
			[ConsoleLog LogMessage:[NSString stringWithFormat:@"churchCode was not found in the %@", kApiPlistName]];
		}
		else {
			[self setChurchCode:returnVal];
		}
	}

	return returnVal;
}

- (void)setChurchCode: (NSString*)aValue {
	
	[ConsoleLog LogMessage:[NSString stringWithFormat:@"Setting Church Code for : %@", aValue]];
	[[NSUserDefaults standardUserDefaults] setObject:aValue forKey:@"churchCode"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)accessToken {
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *returnVal = [userDefaults stringForKey:@"accessToken"];
	
	if (returnVal != nil) {
		return returnVal;
	}
	else {
		[ConsoleLog LogMessage:@"access token has not been set."];
	}
	
	return returnVal;
}

- (void)setAccessToken: (NSString *)aValue {
	[[NSUserDefaults standardUserDefaults] setObject: aValue forKey: @"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
	
- (NSString *)accessTokenSecret {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *returnVal = [userDefaults stringForKey:@"accessTokenSecret"];
	
	if (returnVal != nil) {
		return returnVal;
	}
	else {
		[ConsoleLog LogMessage:@"access token secret has not been set."];
	}
	
	return returnVal;
}

- (void)setAccessTokenSecret: (NSString *)aValue {
	[[NSUserDefaults standardUserDefaults] setObject: aValue forKey: @"accessTokenSecret"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)loggedUserURI {
	return [[NSUserDefaults standardUserDefaults] valueForKey: @"loggedUserURI"];
}

- (void)setLoggedUserURI: (NSString *)aValue {

	[[NSUserDefaults standardUserDefaults] setObject:aValue forKey:@"loggedUserURI"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end

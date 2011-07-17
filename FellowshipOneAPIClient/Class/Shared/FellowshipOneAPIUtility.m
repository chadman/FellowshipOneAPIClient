//
//  Utility.m
//  F1Touch
//
//  Created by Chad Meyer on 5/5/09.
//  Copyright 2009 Fellowship Tech. All rights reserved.
//

#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"
#import "ConsoleLog.h"
#import "Constants.h"

@interface FellowshipOneAPIUtility () 

+(NSDictionary *)getPList: (NSString *)pListFileName;

@end

@implementation FellowshipOneAPIUtility

+ (NSString *)getFTAPIValueFromPList: (NSString *)pListKey {
	
	NSDictionary *plistDictionary = [self getPList:kApiPlistName];
	
	if (plistDictionary != nil) {
		return [plistDictionary objectForKey: pListKey];
	}
	else {
		return nil;
	}
	
}

+ (NSString *)getValueFromPList: (NSString *)pListFileName withListKey: (NSString *)pListKey {
	
	NSDictionary *plistDictionary = [self getPList: pListFileName];
	NSString *returnVal = nil;
	
	if (plistDictionary != nil) {
		returnVal = [plistDictionary objectForKey: pListKey];
		
		if (returnVal == nil) {
			[ConsoleLog LogMessage:[NSString stringWithFormat:@"the key %@ was not found in the %@", pListKey, kApiPlistName]];
		}
	}

	return returnVal;
}

+ (NSDictionary *)getPList: (NSString *)pListFileName {
	
	NSDictionary *plistDictionary;
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent: pListFileName];
	plistDictionary = [NSDictionary dictionaryWithContentsOfFile:finalPath];
	
	if ([plistDictionary count] <= 0) {
		[ConsoleLog LogMessage:[NSString stringWithFormat:@"Could not find the %@. Make sure it exists with the appropriate keys.", kApiPlistName]];
	}
	
	return plistDictionary;
}

+(BOOL) convertToBOOL: (id) value {
	
	if (![value isKindOfClass:[NSNull class]]) {
		
		// The value is not null so now to find out if the value is a BOOL
		if ([NSNumber numberWithBool:[value boolValue]]) {
			return [value boolValue];
		}
	}
	
	return NO;
}

+(int) convertToInt:(id) value {
	
	if (![value isKindOfClass:[NSNull class]] && ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])) {
		return [value intValue];
	}
	
	return INT32_MIN;
}

+(NSDate *) convertToNSDate:(id) value {
	
	if ([value isEqual:[NSNull null]]) {
		return nil;
	}
	else {
		return [FellowshipOneAPIDateUtility dateFromString:value];
	}
}

+(NSDate *) convertToFullNSDate: (id) value {
	if ([value isEqual:[NSNull null]]) {
		return nil;
	}
	else {
		return [FellowshipOneAPIDateUtility dateAndTimeFromString:value];
	}
}

@end

@interface FellowshipOneAPIDatabaseUtility (Private)

// Returns the database path
@property (nonatomic, readonly) NSString *databasePath;

@end


@implementation FellowshipOneAPIDatabaseUtility


+ (NSString *) getDatabasePath; {
	BOOL success;
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writeableDBPath = [documentsDirectory stringByAppendingPathComponent:@"F1Touch.sqlite"];
	
	success = [fileManager fileExistsAtPath:writeableDBPath];
	
	// The file exists, return it
	if (success) return writeableDBPath;

	// Create a writeable copy of the database
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"F1Touch.sqlite"];
	success = [fileManager copyItemAtPath:defaultDBPath toPath:writeableDBPath error:&error];
	
	if (!success) {
		NSAssert1(0, @"Failed to create writeable copy of the database with message %@", [error localizedDescription]);
	}
	
	return writeableDBPath;
	
}

+ (NSString *) SqlSafeParam: (id)value {

	if ([value isKindOfClass:[NSNumber class]]) {
		NSLog(@"SQLSafeParam integer: %d", [value integerValue]);
		return [NSString stringWithFormat:@"%d", [value integerValue]];
	}
	else if ([value isKindOfClass:[NSDate class]]) {
		return [NSString stringWithFormat:@"'%@'", [FellowshipOneAPIDateUtility stringFromDate:value withDateFormat:@"yyyy-MM-dd HH:mm:ss"]];
	}
	else if ([value isKindOfClass:[NSString class]]) {
		return [NSString stringWithFormat:@"'%@'", value];
	}	
	
	return [NSString stringWithFormat:@"%@", value];
}

+ (id) executeQuery:(NSString *)query {
	
	/*
	Sqlite *sqliteDB = [[Sqlite alloc] init];
	NSArray *SQLResults = [[[NSArray alloc] init] autorelease];
	
	// If the database opens
	if ([sqliteDB open:[DatabaseUtility getDatabasePath]]) {
		
		SQLResults = [sqliteDB executeQuery:query];
		NSLog(@"Returned results:%@", SQLResults);
		
		
		[sqliteDB close];
	}
	
	[sqliteDB release];
	return SQLResults;
	*/
	
	return nil;
	
}

+ (BOOL) executeNonQuery: (NSString *)query {
	
	return [FellowshipOneAPIDatabaseUtility executeNonQuery:query arguments:nil];
	
}

+ (BOOL) executeNonQuery:(NSString *)query arguments: (NSArray *)parameters {
	
	/*
	Sqlite *sqliteDB = [[Sqlite alloc] init];
	BOOL returnResult = YES;

	// If the database opens
	if ([sqliteDB open:[DatabaseUtility getDatabasePath]]) {
		
		if (![sqliteDB executeNonQuery:query arguments:parameters]) {
			returnResult = NO;
		}
		
		
		[sqliteDB close];
	}
	
	[sqliteDB release];
	return returnResult;
	 
	 */
	
	return NO;
}

@end


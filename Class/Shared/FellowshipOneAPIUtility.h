//
//  Utility.h
//  F1Touch
//
//  Created by Chad Meyer on 5/5/09.
//  Copyright 2009 Fellowship Tech. All rights reserved.
//

@interface FellowshipOneAPIUtility : NSObject {

}

+(NSString *)getFTAPIValueFromPList: (NSString *)pListKey;
+(NSString *)getValueFromPList: (NSString *)pListFileName withListKey: (NSString *)pListKey;

// Converts an object to a BOOL
+(BOOL) convertToBOOL:(id) value;

+(int) convertToInt:(id) value;

// Convert an object to an NSDate
+(NSDate *) convertToNSDate: (id) value;

// Convert an object to a full date NSDate
+(NSDate *) convertToFullNSDate: (id) value;
@end

@interface FellowshipOneAPIDatabaseUtility : NSObject {
	
}

// takes an object and properly puts the right syntax around it for database saving
+ (NSString *) SqlSafeParam: (id)value;

// Executes a SQLite query that returns data
+ (id) executeQuery:(NSString *)query;

// Executes a SQLite query that does not return data
+ (BOOL) executeNonQuery: (NSString *)query;

// Executes a SQLite query that does not return data
+ (BOOL) executeNonQuery:(NSString *)query arguments: (NSArray *)parameters;

+ (NSString *) getDatabasePath;

@end
//
//  DateUtility.h
//  F1Touch
//
//  Created by Matt Vasquez on 4/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FellowshipOneAPIDateUtility : NSObject {

}

// Converts a string to a full date and time
+ (NSDate *)dateAndTimeFromString:(NSString *)dateString;

+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSString *)stringFromDate:(NSDate *)date;

// Catch all for dates, insert a custom date format for the date
+ (NSString *)stringFromDate:(NSDate *)date withDateFormat: (NSString *)format;

// Catch all for dates, insert a custom date format for the date
+ (NSDate *)dateFromString:(NSString *)dateString withDateFormat: (NSString *)format;

@end

//
//  NSDate+ageFromDate.m
//  F1Touch
//
//  Created by Matt Vasquez on 6/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSDate+ageFromDate.h"

static NSInteger kNumberOfSecondsInAYear = 31556926;

@implementation NSDate (ageFromDate)

- (NSInteger)ageFromDate {
	NSTimeInterval interval = [self timeIntervalSinceNow];
	NSInteger years = (NSInteger)interval/kNumberOfSecondsInAYear;
	years = years * -1;
	
	return years;
}

@end

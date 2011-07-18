//
//  NSObject+serializeToJSON.m
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSObject+serializeToJSON.h"


#import "NSObject+serializeToXml.h"
#import "objc/runtime.h"
#import "FOParentObject.h"
#import "FOParentNamedObject.h"
#import "ConsoleLog.h"
#import "FellowshipOneAPIUtility.h"
#import "FellowshipOneAPIDateUtility.h"

@interface NSObject (private)

// Determine if one of the properties in the list is excluded from being serialized to xml
// Currently the only way to do this is to create a list
- (BOOL)propertyIsExcluded:(NSString *)propertyName;

// Does some work to cleanse the value that is being passed in, sometimes the value is nil so the return value should be blank
- (NSString *)cleanseValue:(id)value field:(NSString *)fieldName;

@end

@implementation NSObject (private)

- (BOOL)propertyIsExcluded:(NSString *)propertyName {
	
	// Create an array with properties that are going to be excluded from all xml serialization requests
	NSMutableArray *exclusionList = [NSMutableArray arrayWithObjects:@"delegate", nil];
	
	for (NSString *current in exclusionList) {
		if ([propertyName isEqualToString:current]) {
			return YES;
		}
	}
	
	return NO;
}

- (NSString *)cleanseValue:(id)value field:(NSString *)fieldName {
	
	if ([value isKindOfClass:[NSNull class]] || value == nil) {
		return @"";
	}
	else if ([value isKindOfClass:[NSDate class]]) {
		return [NSString stringWithFormat:@"%@", [FellowshipOneAPIDateUtility stringFromDate:value withDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"]];
	}
	else if ([value isKindOfClass:[NSNumber class]]) {
		NSLog(@"%d", [value integerValue]);
		if ([value integerValue] == 1 || [value integerValue] == 0) {
			if ([fieldName isEqualToString:@"myId"]) {
				return [NSString stringWithFormat:@"%d", [value integerValue]];
			}
			else {
				if ([value boolValue]) {
					return @"true";
				}
				else {
					return @"false";
				}
			}
		}
		else if ([[NSString stringWithFormat:@"%d", [value integerValue]] isEqualToString:[NSString stringWithFormat:@"%d", NSIntegerMin]]) {
			return @"";
		}
		else {
			return [NSString stringWithFormat:@"%d", [value integerValue]];
		}
	}
	else {
		return value;
	}
	
	return [NSString stringWithFormat:@"%@", value];
}

@end


@implementation NSObject (serializeToJSON)

- (NSString *) serializeToJSON {
	
	
	// The prefix for all class names that needs to be stripped
	NSString *objectNamePrefix = [NSString stringWithString:@"FO"];
	
	NSMutableString *className = [NSMutableString stringWithFormat:@"%@", [self class]];
	
	// strip the prefix from the class name
	if ([className rangeOfString:objectNamePrefix].length > 0) {
		[className replaceCharactersInRange:[className rangeOfString:objectNamePrefix] withString:@""];
	}
	
	// Get the first letter in the class name so we can make it lowercase
	[className replaceCharactersInRange:NSMakeRange(0,1) withString:[[className substringWithRange:NSMakeRange(0, 1)] lowercaseString]];
	
	return [self serializeToJSON:className isChild:NO];
	
}

- (NSString *)serializeToJSON: (NSString *)className isChild:(BOOL)child {
	
	BOOL hasFields = NO;
	
	// The string variable used to construct the json
	NSMutableString *jsonReturnString = [NSMutableString stringWithString:@""];
	
	if (!child) {
		[jsonReturnString appendString:@"{"];
	}
	
	// Append the name of the class
	[jsonReturnString appendFormat:@"\"%@\": {", className];
	
	
	// Get the json mapper 
	NSDictionary *serializationMapper = [self valueForKey:@"serializationMapper"];
	
	if ([serializationMapper objectForKey:@"fieldOrder"]) {
		hasFields = YES;
	}
	
	// Loop through the serializationMapper to figure out all properties
	if ([serializationMapper objectForKey:@"attributeOrder"]) {
		
		// Get all the attributes
		NSArray *attributeOrderArray = [serializationMapper objectForKey:@"attributeOrder"];
		NSDictionary *attributeDictonary = [serializationMapper objectForKey:@"attributes"];
		
		for (int i = 0; i < [attributeOrderArray count]; i++) {
			
			NSString *attributeName = [attributeOrderArray objectAtIndex:i];
			
			[jsonReturnString appendFormat:@"\"%@\":\"%@\"", [attributeDictonary valueForKey:attributeName], [self cleanseValue:[self valueForKey:attributeName] field:attributeName]];
			if (i != ([attributeOrderArray count] - 1)) {
				[jsonReturnString appendFormat:@","];
			}
		}
	}
	
	if (hasFields) {
		
		// Add a comman every object has attributes
		[jsonReturnString appendString:@","];
		
		// For each object in the dictionary that is not the attributes, add the value
		NSArray *fieldOrder = [serializationMapper objectForKey:@"fieldOrder"];
		
		for (int i = 0; i < [fieldOrder count]; i++) {
			
			NSString *fieldName = [fieldOrder objectAtIndex:i];
			
			// There are certain objects that can belong to an entity like ParentObject. If the object that is being added to the xml
			// Is a parent object, then serialize that to xml
			if ([[self valueForKey:fieldName] isKindOfClass:[FOParentObject class]] ||
				[[self valueForKey:fieldName] isKindOfClass:[FOParentNamedObject class]]) {
				[jsonReturnString appendString:[[self valueForKey:fieldName] serializeToJSON:fieldName isChild:YES]];
			}
			else {
				[jsonReturnString appendFormat:@"\"%@\":\"%@\"", [serializationMapper valueForKey:fieldName], [self cleanseValue:[self valueForKey:fieldName] field:fieldName]];
			}
			
			if (i != ([fieldOrder count] - 1)) {
				[jsonReturnString appendFormat:@","];
			}
		}
	}
	
	[jsonReturnString appendString:@"}"];
	
	if (!child) {
		[jsonReturnString appendString:@"}"];
	}
	
	NSLog(@"%@", jsonReturnString);
	
	return jsonReturnString;
}

@end


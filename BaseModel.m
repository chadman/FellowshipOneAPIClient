//
//  BaseModel.m
//  F1Touch
//
//  Created by Meyer, Chad on 3/12/10.
//  Copyright 2010 Fellowship Technologies. All rights reserved.
//

#import "BaseModel.h"
#import "objc/runtime.h"

@interface BaseModel (private)

// Determine if one of the properties in the list is excluded from being serialized to xml
// Currently the only way to do this is to create a list
- (BOOL)propertyIsExcluded:(NSString *)propertyName;

@end

@implementation BaseModel (private)

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

@end

@implementation BaseModel

@synthesize entityState;
@synthesize canDirty;
@synthesize jsonSerializer;

- (id) init {
	if (self = [super init]) {
		canDirty = YES;
		jsonSerializer = [[SBJSON alloc] init];
	}
	
	return self;
}

- (BOOL) getDirtyFlag: (id)value1 comparer: (id)value2 {

	return value1 != value2;
}

- (NSString *) serializeToXml {
	
	// The prefix for all class names that needs to be stripped
	NSString *objectNamePrefix = [NSString stringWithString:@"FT"];
	
	NSMutableString *className = [NSMutableString stringWithFormat:@"%@", [self class]];
	
	// strip the prefix from the class name
	if ([className rangeOfString:objectNamePrefix].length > 0) {
		[className replaceCharactersInRange:[className rangeOfString:objectNamePrefix] withString:@""];
	}
	
	// Get the first letter in the class name so we can make it lowercase
	[className replaceCharactersInRange:NSMakeRange(0,1) withString:[[className substringWithRange:NSMakeRange(0, 1)] lowercaseString]];
	
	
	
	// The string variable used to construct the xml
	NSMutableString *xmlReturnString = [NSMutableString stringWithFormat:@"<%@>", className];
	
	// Integers for counts in the for loop
	unsigned int outCount, i;
	
	// Get all the properties for the specific class
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);

	// Loop through all the properties constructing the xml
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
			//const char *propType = getPropertyType(property);
			NSString *propertyName = [NSString stringWithCString:propName];
			//NSString *propertyType = [NSString stringWithCString:propType];
			
			// Determine if the property is excluded, if not, put it in the xml list
			if (![self propertyIsExcluded:propertyName]) {
				[xmlReturnString appendFormat:@"<%@>%@</%@>", propertyName, [self valueForKey:propertyName], propertyName];
			}
        }
    }
    free(properties);
	
	[xmlReturnString appendFormat:@"</%@>", className];
	
	NSLog(@"%@", xmlReturnString);
	
	return xmlReturnString;
}

- (void) dealloc {
	[jsonSerializer release];
	[super dealloc];
}

@end

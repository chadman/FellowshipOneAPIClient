//
//  NSObject+serializeToXml.m
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSObject+serializeToXml.h"
#import "objc/runtime.h"

@interface NSObject (private)

// Determine if one of the properties in the list is excluded from being serialized to xml
// Currently the only way to do this is to create a list
- (BOOL)propertyIsExcluded:(NSString *)propertyName;

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

@end


@implementation NSObject (serializeToXml)

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
		const char *propType = "@";
        if(propName) {

			const char *attributes = property_getAttributes(property);
			char buffer[1 + strlen(attributes)];
			strcpy(buffer, attributes);
			char *state = buffer, *attribute;
			while ((attribute = strsep(&state, ",")) != NULL) {
				if (attribute[0] == 'T') {
					propType = (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
					break;
				}
			}

			NSString *propertyName = [NSString stringWithUTF8String:propName];
			NSString *propertyType = [NSString stringWithUTF8String:propType];
			
			// If the property type is FTParentObject, need to get the children nodes
			if ([propertyType isEqualToString:@"FTParentObject"]) {
				
				[xmlReturnString appendString:[[self valueForKey:propertyName] serializeToXml]];
			}
			else {
			
				// Determine if the property is excluded, if not, put it in the xml list
				if (![self propertyIsExcluded:propertyName]) {
					
					
					
					[xmlReturnString appendFormat:@"<%@>%@</%@>", propertyName, [self valueForKey:propertyName], propertyName];
				}
			}
        }
    }
    free(properties);
	
	[xmlReturnString appendFormat:@"</%@>", className];
	
	NSLog(@"%@", xmlReturnString);
	
	return xmlReturnString;
}

@end

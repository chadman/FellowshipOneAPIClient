//
//  NSObject+serializeToXml.h
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (serializeToXml)

// Serializes an object to xml
- (NSString *)serializeToXml;

// Serializes an object to xml specifying the parent class name
- (NSString *)serializeToXml: (NSString *)className;

@end
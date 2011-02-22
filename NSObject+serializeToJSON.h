//
//  NSObject+serializeToJSON.h
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (serializeToJSON)
	
// Serializes an object to xml
- (NSString *)serializeToJSON;
	
// Serializes an object to xml specifying the parent class name
- (NSString *)serializeToJSON: (NSString *)className isChild:(BOOL)child;

@end

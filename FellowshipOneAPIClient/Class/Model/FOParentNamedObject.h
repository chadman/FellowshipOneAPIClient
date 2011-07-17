//
//  ParentObject.h
//  FellowshipTechAPI
//
//  Created by Meyer, Chad on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FOParentNamedObject : NSObject <NSCoding> {
	
	NSInteger myId;
	NSString *url;
	NSString *name;
	NSDictionary *_serializationMapper;
}

@property (nonatomic, assign) NSInteger myId;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *name;

/* maps the properties in this class to the required properties and order from an API request. 
 This is needed for when the object is saved since the xsd requires a certain order for all fields */
@property (nonatomic, readonly, assign) NSDictionary *serializationMapper;

/* populates an FTParentObject object from a NSDictionary */
+ (FOParentNamedObject *)populateFromDictionary: (NSDictionary *)dict; 

@end

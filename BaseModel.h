//
//  BaseModel.h
//  F1Touch
//
//  Created by Meyer, Chad on 3/12/10.
//  Copyright 2010 Fellowship Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityState.h"
#import "JSON.h"


@interface BaseModel : NSObject {
	
	EntityState entityState;
	BOOL canDirty;
	SBJSON *jsonSerializer;

}

@property (nonatomic, assign) EntityState entityState;
@property (nonatomic, assign) BOOL canDirty;
@property (nonatomic, retain) SBJSON *jsonSerializer;

- (id) init;

- (BOOL) getDirtyFlag: (id)value1 comparer: (id)value2;

- (NSString *) serializeToXml;

@end

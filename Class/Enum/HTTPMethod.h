//
//  HTTPMethod.h
//  F1Touch
//
//  Created by Meyer, Chad on 4/1/10.
//  Copyright 2010 Fellowship Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

// Create an enum for the type of methods that can be used via the protocol
typedef enum {
	HTTPMethodPOST,
	HTTPMethodPUT,
	HTTPMethodGET,
	HTTPMethodDELETE
} HTTPMethod;
/*
 Copyright (C) 2010 Fellowship Technologies. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 
 FellowshipOneAPIClient is a Cocoa Touch static library responsibile for constrcuting
 well formed signed OAuth requests to the Fellowship One API. The library promises to 
 eliminate the need to understand the inner workings of OAuth and signing to allow 
 developers to quickly get up and running building cocoa touch applications that
 integrate with the Fellowship One API
 
 For more information on OAUTH, please visit http://www.oauth.net
 
 For more information on the Fellowship One API, please visit http://developer.fellowshipone.com/docs/
 
 */

/* 
 
 inferface purpose: A paged entity is a loose typed collection of the results from the API. This will be 
 returned for any API call that returns a paged result set.
 
 
 */

#import <Foundation/Foundation.h>


@interface PagedEntity : NSObject {
	
	int currentCount;
	int pageNumber;
	int totalRecords;
	int additionalPages;
	NSArray *results;

}

@property (nonatomic, assign) int currentCount;
@property (nonatomic, assign) int pageNumber;
@property (nonatomic, assign) int totalRecords;
@property (nonatomic, assign) int additionalPages;
@property (nonatomic, assign) NSArray *results;

@end
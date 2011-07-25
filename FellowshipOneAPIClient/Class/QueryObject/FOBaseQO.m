//
//  BaseQO.m
//  FellowshipOneAPIClient
//
//  Created by Chad Meyer on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FOBaseQO.h"


@implementation FOBaseQO

- (NSInteger) recordsPerPage {
    
    if (!_recordsPerPage || _recordsPerPage <= 0) {
        _recordsPerPage = 20;
    }
    
    return _recordsPerPage;
}

- (void) setRecordsPerPage:(NSInteger)recordsPerPage {
    _recordsPerPage = recordsPerPage;
}

- (NSInteger) pageNumber {
    if (!_pageNumber || _pageNumber <= 0) {
        _pageNumber = 1;
    }
    
    return _pageNumber;
}

- (void) setPageNumber:(NSInteger)pageNumber {
    _pageNumber = pageNumber;
}

- (BOOL) getDirtyFlag: (id)value1 comparer: (id)value2 {
    
	return value1 != value2;
}

@end



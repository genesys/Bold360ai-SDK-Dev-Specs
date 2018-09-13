//
//  BCHTTPConnection.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/27/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCHTTPConnection.h"

@implementation BCHTTPConnection

@synthesize operationQueue = _operationQueue;
@synthesize request = _request;

- (id)initWithRequest:(NSURLRequest *)urlRequest delegate:(id<BCHTTPConnectionDelegate>)delegate {
    if ((self = [self init])) {
        self.request = urlRequest;
        self.delegate = delegate;
        _syncObject = [[NSObject alloc] init];
    }
    return self;
}

- (void)start {
}

- (void)cancel {

}

- (void)dealloc {
    
}

@end

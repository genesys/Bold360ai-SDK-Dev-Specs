//
//  BCHTTPConnection_URLSession.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/27/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCHTTPConnection_URLSession.h"

/**
 BCHTTPConnection_URLSession private interface.
 @since Version 1.0
 */
@interface BCHTTPConnection_URLSession ()

/**
 The currently running data task.
 @since Version 1.0
 */
@property(nonatomic, strong)NSURLSessionDataTask *dataTask;

@end


@implementation BCHTTPConnection_URLSession

@synthesize urlSession = _urlSession;
@synthesize dataTask = _dataTask;

- (void)setDelegate:(id<BCHTTPConnectionDelegate>)delegate {
    @synchronized(_syncObject) {
        if (_delegate != delegate) {
            _delegate = delegate;
        }
    }
}

- (id<BCHTTPConnectionDelegate>)delegate {
    @synchronized(_syncObject) {
        return _delegate;
    }
}

- (id)initWithRequest:(NSURLRequest *)urlRequest delegate:(id <BCHTTPConnectionDelegate>)delegate {
    if((self = [super initWithRequest:urlRequest delegate:delegate])) {
        
    }
    return self;
}

- (void)start {
    [self cancel];
    NSURLRequest *currentRequest = self.request;
    //self is intentionaly retained by the block call cancel before release this object
    self.dataTask = [self.urlSession dataTaskWithRequest:currentRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        @synchronized(_syncObject) {
            if (error) {
                [self.delegate bcHttpConnection:self request:currentRequest didFailWithError:error];
            } else {
                [self.delegate bcHttpConnection:self request:currentRequest didSucceedWithData:data];
            }
        }
    }];
    
    [self.dataTask resume];
}

- (void)cancel {
    [self.dataTask cancel];
    self.dataTask = nil;
}

- (void)dealloc {
    [self cancel];
}

@end

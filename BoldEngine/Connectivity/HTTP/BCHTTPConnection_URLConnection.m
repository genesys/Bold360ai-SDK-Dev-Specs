//
//  BCHTTPConnection_URLConnection.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/27/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCHTTPConnection_URLConnection.h"

/**
 BCHTTPConnection_URLConnection private interface.
 @since Version 1.0
 */
@interface BCHTTPConnection_URLConnection () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

/**
 Data storage used to buffer all the response data, and notify the delegate if the whole has arrived.
 @since Version 1.0
 */
@property(nonatomic, strong)NSMutableData *responseData;

/**
 The connection object.
 @since Version 1.0
 */
@property(nonatomic, strong)NSURLConnection *connection;
@end

@implementation BCHTTPConnection_URLConnection

@synthesize responseData = _responseData;
@synthesize connection = _connection;

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
    
    [super start];
    self.responseData = [[NSMutableData alloc] init];
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (self.operationQueue) {
        [self.connection setDelegateQueue:self.operationQueue];
    }
    [self.connection start];
}

- (void)cancel {
    [super cancel];
    [self.connection cancel];
    self.connection = nil;
}

#pragma mark -
#pragma mark NSURLConnectionDelegate, NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    @synchronized(_syncObject) {
        [self.delegate bcHttpConnection:self request:connection.originalRequest didSucceedWithData:self.responseData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    @synchronized(_syncObject) {
        [self.delegate bcHttpConnection:self request:connection.originalRequest didFailWithError:error];
    }
}


- (void)dealloc {
    [self cancel];
}

@end

//
//  BCCall.m
//  VisitorSDK
//
//  Created by vfabian on 03/07/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCCall.h"

@implementation BCCall

- (id)initWithRESTCall:(BCRESTCall *)restCall {
    if ((self = [self init])) {
        self.restCall = restCall;
    }
    return self;
}

- (void)start {
    
}

- (void)cancel {
    [self.restCall cancel];
}

- (void)suspend {
    [self.restCall suspend];
}

- (void)resume {
    [self.restCall resume];
}

- (void)dealloc {
    [self cancel];
}

@end

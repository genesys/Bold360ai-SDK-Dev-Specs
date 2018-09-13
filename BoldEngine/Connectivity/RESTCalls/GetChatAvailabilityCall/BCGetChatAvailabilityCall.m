//
//  BCGetChatAvailabilityCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/9/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCGetChatAvailabilityCall.h"
#import "BCGetChatAvailabilityCallParser.h"


@interface BCGetChatAvailabilityCall () <BCRESTCallDelegate>

@end

@implementation BCGetChatAvailabilityCall

@synthesize visitorId = _visitorId;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"getChatAvailability";
    self.restCall.parser = [[BCGetChatAvailabilityCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    
    if (self.visitorId) paramsDictionary[@"VisitorID"] = self.visitorId;

    self.restCall.params = paramsDictionary;
    [self.restCall start];
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcGetChatAvailabilityCall:self didFinishWithResult:(BCGetChatAvailabilityCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcGetChatAvailabilityCall:self didFinishWithError:error];
}

@end

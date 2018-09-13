//
//  BCLongPollCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/4/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCLongPollCall.h"
#import "BCLongPollCallParser.h"

@interface BCLongPollCall () <BCRESTCallDelegate>

@end

@implementation BCLongPollCall

@synthesize url = _url;
@synthesize lastMessageId = _lastMessageId;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.infiniteTimeout = YES;
    self.restCall.parser = [[BCLongPollCallParser alloc] init];
    self.restCall.customUrl = [NSString stringWithFormat:@"%@%lld",self.url, self.lastMessageId];
    [self.restCall start];
    
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcLongPollCall:self didFinishWithResult:(NSArray *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcLongPollCall:self didFinishWithError:error];
}

@end

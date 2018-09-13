//
//  BCGetUnavailableFormCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/10/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCGetUnavailableFormCall.h"
#import "BCGetUnavailableFormCallParser.h"

@interface BCGetUnavailableFormCall () <BCRESTCallDelegate>

@end

@implementation BCGetUnavailableFormCall

@synthesize chatKey = _chatKey;
@synthesize clientId = _clientId;
@synthesize delegate = _delegate;


- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"getUnavailableForm";
    self.restCall.parser = [[BCGetUnavailableFormCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    paramsDictionary[@"ChatKey"] = self.chatKey;
    paramsDictionary[@"ClientID"] = self.clientId;
    
    self.restCall.params = paramsDictionary;
    
    [self.restCall start];
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcGetUnavailableFormCall:self didFinishWithResult:(BCGetUnavailableFormCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcGetUnavailableFormCall:self didFinishWithError:error];
}

@end

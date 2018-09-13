//
//  BCSubmitUnavailableEmailCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/10/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCSubmitUnavailableEmailCall.h"
#import "BCSubmitUnavailableEmailCallParser.h"

@interface BCSubmitUnavailableEmailCall () <BCRESTCallDelegate>

@end

@implementation BCSubmitUnavailableEmailCall

@synthesize from = _from;
@synthesize subject = _subject;
@synthesize body = _body;
@synthesize chatKey = _chatKey;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"submitUnavailableEmail";
    self.restCall.parser = [[BCSubmitUnavailableEmailCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    if (self.from) paramsDictionary[@"From"] = self.from;
    if (self.subject) paramsDictionary[@"Subject"] = self.subject;
    if (self.body) paramsDictionary[@"Body"] = self.body;
    if (self.chatKey) paramsDictionary[@"ChatKey"] = self.chatKey;
    
    self.restCall.params = paramsDictionary;
    
    [self.restCall start];
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcSubmitUnavailableEmailCall:self didFinishWithResult:(BCSubmitUnavailableEmailCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcSubmitUnavailableEmailCall:self didFinishWithError:error];
}

@end

//
//  BCChangeLanguageCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/17/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCChangeLanguageCall.h"
#import "BCChangeLanguageCallParser.h"

@interface BCChangeLanguageCall () <BCRESTCallDelegate>

@end

@implementation BCChangeLanguageCall

@synthesize chatKey = _chatKey;
@synthesize language = _language;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"changeLanguage";
    self.restCall.parser = [[BCChangeLanguageCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    paramsDictionary[@"ChatKey"] = self.chatKey;
    paramsDictionary[@"Language"] = self.language;
    
    self.restCall.params = paramsDictionary;
    
    [self.restCall start];
    
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcChangeLanguageCall:self didFinishWithResult:(BCChangeLanguageCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcChangeLanguageCall:self didFinishWithError:error];
}

@end

//
//  BCSubmitPreChatCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/10/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCSubmitPreChatCall.h"
#import "BCSubmitPreChatCallParser.h"

@interface BCSubmitPreChatCall () <BCRESTCallDelegate>

@end

@implementation BCSubmitPreChatCall

@synthesize chatKey = _chatKey;
@synthesize data = _data;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"submitPreChat";
    self.restCall.parser = [[BCSubmitPreChatCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    paramsDictionary[@"ChatKey"] = self.chatKey;
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.data options:0 error:&error];
    
    if (!error) {
        paramsDictionary[@"Data"] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    self.restCall.params = paramsDictionary;
    
    [self.restCall start];
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcSubmitPreChatCall:self didFinishWithResult:(BCSubmitPreChatCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcSubmitPreChatCall:self didFinishWithError:error];
}

@end

//
//  BCOSSFinishChatCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/1/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSFinishChatCall.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSFinishChatCall

@synthesize delegate = _delegate;
@synthesize chatKey = _chatKey;
@synthesize clientId = _clientId;

- (NSData *)requestData {
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
    paramsDict[@"ChatKey"] = self.chatKey;
    paramsDict[@"ClientID"] = self.clientId;
    
    NSData *jsonData = [self requestWithMethod:@"finishChat" params:paramsDict];
    return jsonData;
}

- (BOOL)waitsForResponse {
    return YES;
}


- (BOOL)processResponse:(NSDictionary *)response {
    if ([self.callId isEqualToString:[response[@"id"] bcNilOrStringValue]]) {
        [self.delegate ossFinishChatCallDidSucceed:self];
        return YES;
    }
    
    return NO;
    
}


@end

//
//  BCOSSSendMessageCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/1/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSSendMessageCall.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSSendMessageCall

@synthesize delegate = _delegate;
@synthesize chatKey = _chatKey;
@synthesize chatMessageID = _chatMessageID;
@synthesize name = _name;
@synthesize message = _message;

- (NSData *)requestData {
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
    paramsDict[@"ChatKey"] = self.chatKey;
    paramsDict[@"ChatMessageID"] = self.chatMessageID;
    if(self.name) paramsDict[@"Name"] = self.name;
    if(self.message) paramsDict[@"Message"] = self.message;
    
    NSData *jsonData = [self requestWithMethod:@"sendMessage" params:paramsDict];
    return jsonData;
}

- (BOOL)processResponse:(NSDictionary *)response {
    if ([self.callId isEqualToString:[response[@"id"] bcNilOrStringValue]]) {
        [self.delegate ossSendMessageCallDidSucceed:self];
        return YES;
    }
    
    return NO;
    
}

@end

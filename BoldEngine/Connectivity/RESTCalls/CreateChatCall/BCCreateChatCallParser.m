//
//  BCCreateChatCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/28/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCCreateChatCallParser.h"
#import "BCCreateChatCallResult.h"
#import "BCFormFieldParser.h"
#import "NSObject+nilOrValue.h"

@implementation BCCreateChatCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    assert([parsedDictionary isKindOfClass:[NSDictionary class]]);
    
    BCCreateChatCallResult *result = [[BCCreateChatCallResult alloc] init];
    [self fillSuccessAndErrorFromDictionary:parsedDictionary forResult:result];
    
    result.chatId = [parsedDictionary[@"ChatID"] bcNilOrStringValue];
    result.chatKey = [parsedDictionary[@"ChatKey"] bcNilOrStringValue];
    result.visitorId = [parsedDictionary[@"VisitorID"] bcNilOrStringValue];
    result.name = [parsedDictionary[@"Name"] bcNilOrStringValue];
    result.clientId = [parsedDictionary[@"ClientID"] bcNilOrStringValue];
    result.longPollURL = [parsedDictionary[@"LongPollURL"] bcNilOrStringValue];
    result.webSocketURL = [parsedDictionary[@"WebSocketURL"] bcNilOrStringValue];
    result.language = [parsedDictionary[@"Language"] bcNilOrStringValue];
    result.clientTimeout =[parsedDictionary[@"ClientTimeout"] bcNilOrIntegerValue];
    result.answerTimeout =[parsedDictionary[@"AnswerTimeout"] bcNilOrIntegerValue];
    result.unavailableReason = [parsedDictionary[@"UnavailableReason"] bcNilOrStringValue];
    result.unavailableForm = [BCFormFieldParser formFields:((NSDictionary *)(parsedDictionary[@"UnavailableForm"]))[@"Fields"]];
    if (!result.unavailableForm && parsedDictionary[@"UnavailableForm"]) result.unavailableForm = @[];
    
    result.preChat = [BCFormFieldParser formFields:((NSDictionary *)(parsedDictionary[@"PreChat"]))[@"Fields"]];
    if (!result.preChat && parsedDictionary[@"PreChat"]) result.preChat = @[];
    
    result.brandings = parsedDictionary[@"Brandings"];
    
    return result;
}

@end

//
//  BCSubmitPreChatCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/10/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCSubmitPreChatCallParser.h"
#import "BCSubmitPreChatCallResult.h"
#import "NSObject+nilOrValue.h"
#import "BCFormFieldParser.h"

@implementation BCSubmitPreChatCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    assert([parsedDictionary isKindOfClass:[NSDictionary class]]);
    
    BCSubmitPreChatCallResult *result = [[BCSubmitPreChatCallResult alloc] init];
    [self fillSuccessAndErrorFromDictionary:parsedDictionary forResult:result];
    
    result.clientId = [parsedDictionary[@"ClientID"] bcNilOrStringValue];
    result.name = [parsedDictionary[@"Name"] bcNilOrStringValue];
    result.longPollURL = [parsedDictionary[@"LongPollURL"] bcNilOrStringValue];
    result.webSocketURL = [parsedDictionary[@"WebSocketURL"] bcNilOrStringValue];
    result.clientTimeout =[parsedDictionary[@"ClientTimeout"] bcNilOrIntegerValue];
    result.answerTimeout =[parsedDictionary[@"AnswerTimeout"] bcNilOrIntegerValue];
    result.unavailableReason = [parsedDictionary[@"UnavailableReason"] bcNilOrStringValue];
    result.unavailableForm = [BCFormFieldParser formFields:((NSDictionary *)(parsedDictionary[@"UnavailableForm"]))[@"Fields"]];
    if (!result.unavailableForm && parsedDictionary[@"UnavailableForm"]) result.unavailableForm = @[];
    
    return result;
}


@end

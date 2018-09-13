//
//  BCStartChatCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/28/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCStartChatCallParser.h"
#import "BCStartChatCallResult.h"
#import "NSObject+nilOrValue.h"

@implementation BCStartChatCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    assert([parsedDictionary isKindOfClass:[NSDictionary class]]);
    
    BCStartChatCallResult *result = [[BCStartChatCallResult alloc] init];
    [self fillSuccessAndErrorFromDictionary:parsedDictionary forResult:result];
    
    result.clientId = [parsedDictionary[@"ClientID"] bcNilOrStringValue];
    result.longPollURL = [parsedDictionary[@"LongPollURL"] bcNilOrStringValue];
    result.webSocketURL = [parsedDictionary[@"WebSocketURL"] bcNilOrStringValue];
    result.clientTimeout =[parsedDictionary[@"ClientTimeout"] bcNilOrIntegerValue];
    result.answerTimeout =[parsedDictionary[@"AnswerTimeout"] bcNilOrIntegerValue];
    
    return result;
}

@end

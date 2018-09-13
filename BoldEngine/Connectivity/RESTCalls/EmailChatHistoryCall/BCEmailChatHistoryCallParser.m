//
//  BCEmailChatHistoryCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/10/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCEmailChatHistoryCallParser.h"
#import "BCEmailChatHistoryCallResult.h"

@implementation BCEmailChatHistoryCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    assert([parsedDictionary isKindOfClass:[NSDictionary class]]);
    
    BCEmailChatHistoryCallResult *result = [[BCEmailChatHistoryCallResult alloc] init];
    [self fillSuccessAndErrorFromDictionary:parsedDictionary forResult:result];
    
    return result;
}

@end

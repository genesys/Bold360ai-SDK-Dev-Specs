//
//  BCFinishChatCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/2/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCFinishChatCallParser.h"
#import "BCFinishChatCallResult.h"
#import "BCFormFieldParser.h"

@implementation BCFinishChatCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    assert([parsedDictionary isKindOfClass:[NSDictionary class]]);
    
    BCFinishChatCallResult *result = [[BCFinishChatCallResult alloc] init];
    [self fillSuccessAndErrorFromDictionary:parsedDictionary forResult:result];
    result.postChat = [BCFormFieldParser formFields:((NSDictionary *)(parsedDictionary[@"PostChat"]))[@"Fields"]];
    if (!result.postChat && parsedDictionary[@"PostChat"]) result.postChat = @[];
    return result;
}


@end

//
//  BCSendMessageCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/2/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCSendMessageCallParser.h"
#import "BCSendMessageCallResult.h"

@implementation BCSendMessageCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    assert([parsedDictionary isKindOfClass:[NSDictionary class]]);
    
    BCSendMessageCallResult *result = [[BCSendMessageCallResult alloc] init];
    [self fillSuccessAndErrorFromDictionary:parsedDictionary forResult:result];
    
    return result;
}


@end

//
//  BCOSSJSONResponsePreProcessor.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/31/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSJSONResponsePreProcessor.h"

@implementation BCOSSJSONResponsePreProcessor

- (NSDictionary *)preProcessResponse:(NSObject *)resonse withError:(__autoreleasing NSError **)error {
    NSError *parseError = nil;
    NSData *responseData = [resonse isKindOfClass:[NSData class]] ? (NSData *)resonse : [((NSString *)resonse) dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parseError];
    if (parseError) {
        *error = parseError;
        return nil;
    } else {
        *error = nil;
        return parsedDictionary;
    }
    
}


@end

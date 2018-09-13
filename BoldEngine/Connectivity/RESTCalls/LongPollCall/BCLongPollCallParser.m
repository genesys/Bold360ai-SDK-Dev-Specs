//
//  BCLongPollCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/4/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCLongPollCallParser.h"

@implementation BCLongPollCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSArray *parsedArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    return parsedArray;
}


@end

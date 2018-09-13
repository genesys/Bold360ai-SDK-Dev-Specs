//
//  NSString+RandomIdentifier.m
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "NSString+RandomIdentifier.h"

@implementation NSString (BCRandomIdentifier)

+ (NSString *)bcRandomIdentifier {
    NSString *retval = @"";
    
    for (NSInteger idx = 0; idx < 19; idx++) {
        long randInt;
        if (idx == 0) {
            randInt = (arc4random() % 8) + 1; // 1 to 8
            //			randInt = RANDOM_INT(1,8);
        } else {
            randInt = (arc4random() % 10); // 0 to 9
            //			randInt = RANDOM_INT(0,9);
        }
        retval = [retval stringByAppendingFormat:@"%ld", randInt];
    }
    return retval;
}

@end

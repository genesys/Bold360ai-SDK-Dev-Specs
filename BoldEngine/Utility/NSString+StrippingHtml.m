//
//  NSString+StrippingHtml.m
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "NSString+StrippingHtml.h"

@implementation NSString (BCStrippingHtml)

-(NSString *)bcStringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end

//
//  NSObject+nilOrValue.m
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "NSObject+nilOrValue.h"

@implementation NSObject (BCNilOrValue)

- (NSString *)bcNilOrStringValue {
    if ([self isKindOfClass:[NSNull class]]) {
        return nil;
    } else if ([self isKindOfClass:[NSString class]]) {
        if (((NSString *)self).length > 0) {
            return (NSString *)self;
        } else {
            return nil;
        }
        
    } else if ([self isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)self) stringValue];
    }
    
    return nil;
}

- (NSInteger)bcNilOrIntegerValue {
    if ([self isKindOfClass:[NSNull class]]) {
        return 0;
    } else if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self) integerValue];
    } else if ([self isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)self) integerValue];
    }
    
    return 0;
}

- (BOOL)bcNilOrBoolValue {
    if ([self isKindOfClass:[NSNull class]]) {
        return NO;
    } else if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self) boolValue];
    } else if ([self isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)self) boolValue];
    }
    return NO;
}

@end

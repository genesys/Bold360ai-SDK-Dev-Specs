//
//  NSMutableArray+nonRetaining.m
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "NSMutableArray+nonRetaining.h"

@implementation NSMutableArray (BCNonRetaining)

+ (id)bcMutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    // We create a weak reference array
    return (__bridge_transfer id)(CFArrayCreateMutable(0, capacity, &callbacks));
}


+ (id)bcNonRetainingArrayWithCapacity:(NSUInteger)itemNum {
    return [self bcMutableArrayUsingWeakReferencesWithCapacity:itemNum];
}

@end
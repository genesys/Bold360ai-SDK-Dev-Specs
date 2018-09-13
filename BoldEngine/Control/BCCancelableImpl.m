//
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCCancelableImpl.h"
#import "BCCancelable.h"

@implementation BCCancelableImpl

- (instancetype)initWithDelegate:(id<BCCancelableImplDelegate>)delegate {
    if ((self = [super init])) {
        _delegate = delegate;
    }
    return self;
}

- (void)cancel {
    [_delegate bcCancelableImplDidCancel:self];
}

- (void)clear {
    _delegate = nil;
}

@end

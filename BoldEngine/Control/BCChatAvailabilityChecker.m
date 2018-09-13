//
//  BCChatAvailabilityCheckerImpl.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/9/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCChatAvailabilityChecker.h"
#import "BCGetChatAvailabilityCall.h"
#import "NSMutableArray+nonRetaining.h"
#import "BCErrorCodes.h"

static const NSTimeInterval __BCChatAvailabilityChecker_CachePeriod = 60.0;

/**
 BCChatAvailabilityCheckerImpl private interface.
 @since Version 1.0
 */
@interface BCChatAvailabilityChecker () <BCGetChatAvailabilityCallDelegate>

/**
 The inner state.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL running;

/**
 The chat is available.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL chatIsAvailable;

/**
 The reason why the chat is not available.
 @since Version 1.0
 */
@property(nonatomic, assign)BCUnavailableReason unavailableReason;

/**
 The getChatAvailability remote call.
 @since Version 1.0
 */
@property(nonatomic, strong)BCGetChatAvailabilityCall *call;

/**
 The shared connectivity manager.
 @since Version 1.0
 */
@property(nonatomic, strong)BCConnectivityManager *connectivityManager;

/**
 The array of delegates to call back.
 @since Version 1.0
 */
@property(nonatomic, strong)NSMutableArray *delegates;

/**
 The array of cancelables to call back with.
 @since Version 1.0
 */
@property(nonatomic, strong)NSMutableArray *cancelables;

/**
 The array of delegates to call back.
 @since Version 1.0
 */
@property(nonatomic, assign)NSTimeInterval lastCallTime;

/**
 The last error that was returned by the REST call. Network and formatting style errors are not stored here.
 @since Version 1.0
 */
@property(nonatomic, strong)NSError *lastReturnedError;


/**
 Initiate remote call.
 @since Version 1.0
 */
- (void)initiateCall;

/**
 Creates error for known error related message.
 @since Version 1.0
 */
- (NSError *)errorForString:(NSString *)stringValue;


/**
 Cast string to unavailability reason.
 @since Version 1.0
 */
- (BCUnavailableReason)unavailableReasonForString:(NSString *)stringValue;

/**
 Propagate cached result of the availability check.
 @since Version 1.0
 */
- (void)propagateResult;

/**
 Propagate error received.
 @param error The error to propagate.
 @since Version 1.0
 */
- (void)propagateError:(NSError *)error;

@end

@implementation BCChatAvailabilityChecker

@synthesize running = _running;
@synthesize chatIsAvailable = _chatIsAvailable;
@synthesize unavailableReason = _unavailableReason;
@synthesize visitorId = _visitorId;
@synthesize call = _call;
@synthesize connectivityManager = _connectivityManager;
@synthesize lastCallTime = _lastCallTime;
@synthesize delegates = _delegates;
@synthesize cancelables = _cancelables;
@synthesize lastReturnedError = _lastReturnedError;


- (id)initWithConnectivityManager:(BCConnectivityManager *)connectivityManager visitorId:(NSString *)visitorId {
    if ((self = [self init])) {
        self.connectivityManager = connectivityManager;
        self.visitorId = visitorId;
        self.delegates = [NSMutableArray bcNonRetainingArrayWithCapacity:2];
        self.cancelables = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)requestAvailabilityWithCancelable:(BCCancelableImpl *)cancelable delegate:(id<BCChatAvailabilityDelegate>)delegate {
    [self.delegates addObject:delegate];
    [self.cancelables addObject:cancelable];
    if (!self.running) {
        if (self.lastCallTime + __BCChatAvailabilityChecker_CachePeriod <= [NSDate date].timeIntervalSince1970 ) {
            self.running = YES;
            [self initiateCall];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                if (!self.running) {
                    [self propagateResult];
                    [self.cancelables removeAllObjects];
                    [self.delegates removeAllObjects];
                }
            });
        }
    }
}

- (void)propagateResult {
    for (int i = 0; i < self.delegates.count; i++) {
        BCCancelableImpl *cancelable = self.cancelables[i];
        id<BCChatAvailabilityDelegate> delegate = self.delegates[i];
        if (self.lastReturnedError) {
            [delegate bcChatAvailability:cancelable didFailWithError:self.lastReturnedError];
        } else if (self.chatIsAvailable) {
            [delegate bcChatAvailabilityChatAvailable:cancelable];
        } else {
            [delegate bcChatAvailability:cancelable chatUnavailableForReason:self.unavailableReason];
        }
    }
}

- (void)propagateError:(NSError *)error {
    for (int i = 0; i < self.delegates.count; i++) {
        BCCancelableImpl *cancelable = self.cancelables[i];
        id<BCChatAvailabilityDelegate> delegate = self.delegates[i];
        [delegate bcChatAvailability:cancelable didFailWithError:error];
    }
}

- (void)initiateCall {
    self.call = [self.connectivityManager getChatAvailabilityCall];
    self.call.delegate = self;
    self.call.visitorId = self.visitorId;
    [self.call start];
}

- (NSError *)errorForString:(NSString *)stringValue {
    if ([stringValue isEqualToString:@"No chat api settings found"] || [stringValue isEqualToString:@"Not authorized"]) {
        return [NSError errorWithDomain:@"ChatAvailabilityChecker" code:BCGeneralInvalidAccessKeyError userInfo: stringValue ? @{@"localisedReason":stringValue} : nil];
    }
    return [NSError errorWithDomain:@"ChatAvailabilityChecker" code:BCGeneralUnknownError userInfo: stringValue ? @{@"localisedReason":stringValue} : nil];;
}

- (BCUnavailableReason)unavailableReasonForString:(NSString *)stringValue {
    BCUnavailableReason reason = BCUnavailableReasonUnknown;
    if ([stringValue isEqualToString:@"queue_full"]) {
        reason = BCUnavailableReasonQueueFull;
    } else if ([stringValue isEqualToString:@"no_operators"]) {
        reason = BCUnavailableReasonNoOperators;
    } else if ([stringValue isEqualToString:@"visitor_blocked"]) {
        reason = BCUnavailableReasonVisitorBlocked;
    } else if ([stringValue isEqualToString:@"outside_hours"]) {
        reason = BCUnavailableReasonOutsideHours;
    } else if ([stringValue isEqualToString:@"unsecure"]) {
        reason = BCUnavailableReasonUnsecure;
    }
    return reason;
}

#pragma mark -
#pragma mark BCGetChatAvailabilityCallDelegate
- (void)bcGetChatAvailabilityCall:(BCGetChatAvailabilityCall *)getChatAvailabilityCall didFinishWithResult:(BCGetChatAvailabilityCallResult *)result {
    self.running = NO;
    self.lastCallTime = [NSDate date].timeIntervalSince1970;
    if (result.statusSuccess) {
        self.lastReturnedError = nil;
        if (result.available) {
            self.chatIsAvailable = YES;
        } else {
            BCUnavailableReason reason = [self unavailableReasonForString:result.unavailableReason];
            self.chatIsAvailable = NO;
            self.unavailableReason = reason;
        }
    } else {
        self.lastReturnedError = [self errorForString:result.errorMessage];
    }
    for (BCCancelableImpl *cancelable in self.cancelables) {
        [cancelable clear];
    }
    [self propagateResult];
    [self.cancelables removeAllObjects];
    [self.delegates removeAllObjects];
}

- (void)bcGetChatAvailabilityCall:(BCGetChatAvailabilityCall *)getChatAvailabilityCall didFinishWithError:(NSError *)error {
    self.running = NO;
    for (BCCancelableImpl *cancelable in self.cancelables) {
        [cancelable clear];
    }
    [self propagateError:error];
    [self.cancelables removeAllObjects];
    [self.delegates removeAllObjects];
}

#pragma mark -
#pragma mark BCCancelableImplDelegate
- (void)bcCancelableImplDidCancel:(BCCancelableImpl *)cancelableImpl {
    NSUInteger index = [self.cancelables indexOfObject:cancelableImpl];
    if (index != NSNotFound) {
        BCCancelableImpl *cancelable = ((BCCancelableImpl *)(self.cancelables[index]));
        [cancelable clear];
        [self.cancelables removeObjectAtIndex:index];
        [self.delegates removeObjectAtIndex:index];
    }
    if (self.cancelables.count <= 0) {
        self.call.delegate = nil;
        [self.call cancel];
        self.call = nil;
        self.running = NO;
    }
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
    self.call.delegate = nil;
    [self.call cancel];
    self.call = nil;
}

@end

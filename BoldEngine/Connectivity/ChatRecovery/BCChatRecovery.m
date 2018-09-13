//
//  BCChatRecovery.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/15/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCChatRecovery.h"
#import "BCTimer.h"
#import "BCPingChatCall.h"
#import "BCConnectivityManager.h"

/**
 Recapture testing periodicity.
 @since Version 1.0
 */
static const NSTimeInterval __BCChatRecovery_Timeout = 30.0;

/**
 BCChatRecovery private interface.
 @since Version 1.0
 */
@interface BCChatRecovery () <BCPingChatCallDelegate>

/**
 YES if chat recapture is available.
 @since version 1.0
 */
@property(nonatomic, assign)BOOL recaptureAvailable;

/**
 The timer to time between pingChat calls.
 @since version 1.0
 */
@property(nonatomic, strong)BCTimer *timer;

/**
 The REST call to check recapture.
 @since version 1.0
 */
@property(nonatomic, strong)BCPingChatCall *pingChatCall;

/**
 The operations are running.
 @since version 1.0
 */
@property(nonatomic, assign)BOOL running;

/**
 Strong pointer to self. Used for survival of the owner if closed is sent.
 @since version 1.0
 */
@property(nonatomic, strong)NSObject *ownedSelf;



@end

@implementation BCChatRecovery

@synthesize delegate = _delegate;
@synthesize chatKey = _chatKey;
@synthesize recaptureAvailable = _recaptureAvailable;
@synthesize timer = _timer;
@synthesize pingChatCall = _pingChatCall;
@synthesize running = _running;
@synthesize connectivityManager = _connectivityManager;
@synthesize ownedSelf = _ownedSelf;

- (void)start {
    if (self.running) return;
    self.running = YES;
    
    [self.timer invalidate];
    self.timer = [BCTimer scheduledNonRetainingTimerWithTimeInterval:__BCChatRecovery_Timeout target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    
    self.pingChatCall = [self.connectivityManager pingChatCall];
    self.pingChatCall.delegate = self;
    self.pingChatCall.chatKey = self.chatKey;
    self.pingChatCall.closed = NO;
    [self.pingChatCall start];
}

- (void)stop {
    if (!self.running) return;
    self.running = NO;
    
    [self.pingChatCall cancel];
    self.pingChatCall = nil;
    [self.timer invalidate];
    self.timer = nil;
}
- (void)sendClosedAndStop {
    [self stop];
    [self.timer invalidate];
    self.timer = nil;
    
    self.ownedSelf = self;
    self.pingChatCall = [self.connectivityManager pingChatCall];
    self.pingChatCall.delegate = self;
    self.pingChatCall.chatKey = self.chatKey;
    self.pingChatCall.closed = YES;
    [self.pingChatCall start];
}

#pragma mark -
#pragma mark Timer
- (void)timerTick {
    [self.pingChatCall cancel];
    
    self.pingChatCall = [self.connectivityManager pingChatCall];
    self.pingChatCall.delegate = self;
    self.pingChatCall.chatKey = self.chatKey;
    self.pingChatCall.closed = NO;
    [self.pingChatCall start];
    self.ownedSelf = nil;
}

#pragma mark -
#pragma mark BCPingChatCallDelegate
- (void)bcPingChatCall:(BCPingChatCall *)pingChatCall didFinishWithResult:(BCPingChatCallResult *)result {
    if (result.statusSuccess) {
        if (result.recapture != self.recaptureAvailable) {
            self.recaptureAvailable = result.recapture;
            [self.delegate bcChatRecovery:self didReceiveRecaptureAvailable:result.recapture];
        }
    }
    if (pingChatCall.closed) {
        if ([self.delegate respondsToSelector:@selector(bcChatRecoveryCloseDidFinish:)]) {
            [self.delegate bcChatRecoveryCloseDidFinish:self];
        }
        self.running = NO;
    }
    self.ownedSelf = nil;
}

- (void)bcPingChatCall:(BCPingChatCall *)pingChatCall didFinishWithError:(NSError *)error {
    if (pingChatCall.closed) {
        if ([self.delegate respondsToSelector:@selector(bcChatRecovery:didFailToSendCloseWithError:)]) {
            [self.delegate bcChatRecovery:self didFailToSendCloseWithError:error];
        }
        self.running = NO;
    }
    self.ownedSelf = nil;
}

- (void)dealloc {
    
}

@end

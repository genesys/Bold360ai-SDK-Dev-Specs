//
//  BCRESTCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/27/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCRESTCall.h"
#import <UIKit/UIKit.h>
#import "BCTimer.h"
#import "BCErrorCodes.h"
#import "GTMNSString+BCURLArguments.h"

typedef void (^BCRESTCallDelayedCallback)(void);

/**
 JSON HTTP request URL pattern.
 @since Version 1.0
 */
static NSString * const __BCJSONHTTPConnection_URL = @"https://api%@.boldchat.com/aid/%@/rest/json/v1/%@?auth=%@";

/**
 Number of times the component tries run the request after failure.
 @since Version 1.0
 */
static const NSInteger MAX_CONNECT_RETRY_COUNT = 15;

/**
 Timeout of a request.
 @since Version 1.0
 */
static const NSInteger CONNECTION_TIMEOUT = 30;

/** @file */
/**
 BCRESTCall internal states.
 @since Version 1.0
 */
typedef enum {
    BCRestCallStateIdle, /**< Idle state*/
    BCRestCallStateOngoingRequest,/**< the connection is running.*/
    BCRestCallStateCanceled /**< the connection is cancelled.*/
}BCRestCallState;

/**
 BCRESTCall private interface.
 @since Version 1.0
 */
@interface BCRESTCall () <BCHTTPConnectionDelegate>

/**
 BCRESTCall internal state.
 @since Version 1.0
 */
@property(assign)BCRestCallState state;

/**
 Underlying connection.
 @since Version 1.0
 */
@property(strong)BCHTTPConnection *connection;

/**
 Timer for timeouts and reconnect waits.
 @since Version 1.0
 */
@property(strong)BCTimer *timer;

/**
 Number of times the connection was tried.
 @since Version 1.0
 */
@property(assign)NSInteger connectRetryCount;

/**
 Currently running NSURLRequest.
 @since Version 1.0
 */
@property(strong)NSURLRequest *currentRequest;

/**
 The current running is suspended
 @since Version 1.0
 */
@property(assign)BOOL suspended;

/**
 If a network callback happened after being suspended the delegate callback is hold in this block.
 @since Version 1.0
 */
@property(copy)BCRESTCallDelayedCallback delayedCallback;

/**
 The request did succeed. This is called back on the main thread.
 @since Version 1.0
 */
- (void)didSucceedWithArray:(NSArray *)array;

/**
 The request did fail. This is called back on the main thread.
 @since Version 1.0
 */
- (void)didFailWithArray:(NSArray *)array;

/**
 Start to run the request.
 @since Version 1.0
 */
- (void)startOperation;

/**
 Start the timer for the reason defined by the current state.
 @since Version 1.0
 */
- (void)startTimer;

/**
 Stop the timer.
 @since Version 1.0
 */
- (void)stopTimer;

@end

@implementation BCRESTCall

@synthesize state = _state;
@synthesize delegate = _delegate;
@synthesize accountId = _accountId;
@synthesize methodName = _methodName;
@synthesize params = _params;
@synthesize connection = _connection;
@synthesize parser = _parser;
@synthesize infiniteTimeout = _infiniteTimeout;
@synthesize connectRetryCount = _connectRetryCount;
@synthesize timer = _timer;
@synthesize customUrl = _customUrl;
@synthesize currentRequest = _currentRequest;
@synthesize suspended = _suspended;

@synthesize serverSet = _serverSet;

+ (id)restCallWithHttpConnection:(BCHTTPConnection *)connection {
    return [[[self class] alloc] initWithHttpConnection:connection];
}

- (id)initWithHttpConnection:(BCHTTPConnection *)connection {
    if ((self = [self init])) {
        self.connection = connection;
    }
    return self;
}

- (void)start {
    if (self.state == BCRestCallStateOngoingRequest) return;
    self.connectRetryCount = 0;
    [self startTimer];
    [self startOperation];
}

- (void)startOperation {
    self.state = BCRestCallStateOngoingRequest;
    //creating auth param
    NSString *authParam = nil;
    if ([[NSData data] respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        //iOS7
        authParam = [[[NSString stringWithFormat:@"%@:%@",self.accountId,self.accessKey] dataUsingEncoding:NSASCIIStringEncoding] base64EncodedStringWithOptions:0];
    } else {
        //before iOS7
        authParam = [[[NSString stringWithFormat:@"%@:%@",self.accountId,self.accessKey] dataUsingEncoding:NSASCIIStringEncoding] base64Encoding];
    }
    //cretating the url to call
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:self.customUrl ? self.customUrl :
                                       __BCJSONHTTPConnection_URL,
                                       self.serverSet.length ? [NSString stringWithFormat:@"-%@",self.serverSet] : @"",
                                       self.accountId,
                                       self.methodName,authParam]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    //setting request headers
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSString* userAgent = [NSString stringWithFormat:@"BoldChatAPI/1.0 (%@; CPU %@ %@ like MAC OS X) %@/%@ (%.0fx%.0f)", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemName], [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"], [[NSBundle mainBundle] bundleIdentifier], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], [UIScreen mainScreen].bounds.size.width*[[UIScreen mainScreen] scale], [UIScreen mainScreen].bounds.size.height * [[UIScreen mainScreen] scale]];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    //authorization header
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", authParam];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    //setting message body
    NSMutableString *queryString = [NSMutableString string];
    for (NSString* key in [self.params allKeys]){
        if ([queryString length]>0)
            [queryString appendString:@"&"];
        [queryString appendFormat:@"%@=%@", key, [[self.params objectForKey:key] bc_gtm_stringByEscapingForURLArgument]];
    }
    NSData *bodyData = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)(bodyData.length)] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:bodyData];
    
    //starting connection
    self.connection.request = self.currentRequest = request;
    self.connection.delegate = self;
    [self.connection start];
}

- (void)cancel {
    self.state = BCRestCallStateCanceled;
    self.connectRetryCount = 0;
    [self stopTimer];
    self.currentRequest = nil;
    self.connection.delegate = nil;//needed to avoid memory leak and synchronization
    [self.connection cancel];
    self.delayedCallback = nil;
}

- (void)suspend {
    if (self.suspended) return;
    self.suspended = YES;
    
    if (self.state == BCRestCallStateOngoingRequest) {
        [self stopTimer];
        self.connectRetryCount = 0;
    }
}

- (void)resume {
    if (!self.suspended) return;
    self.suspended = NO;
    
    if (self.state == BCRestCallStateOngoingRequest) {
        [self startTimer];
    } if (self.state == BCRestCallStateIdle && self.delayedCallback) {
        self.delayedCallback();
        self.delayedCallback = nil;
    }
}

- (void)startTimer {
    [self stopTimer];
    if (!self.infiniteTimeout) {
        self.timer = [BCTimer scheduledNonRetainingTimerWithTimeInterval:CONNECTION_TIMEOUT target:self selector:@selector(timerTick) userInfo:nil repeats:NO];
    }
}

- (void)stopTimer {
    [self.timer invalidate];
}

- (void)timerTick {
    if (self.state == BCRestCallStateOngoingRequest) {
        self.state = BCRestCallStateIdle;
        [self.connection cancel];
        self.connectRetryCount = 0;
        
        if (self.suspended) {

            __block __unsafe_unretained BCRESTCall *block_self = self;
            self.delayedCallback = ^() {
                if (block_self.state != BCRestCallStateCanceled) {
                    [block_self.delegate bcRestCall:block_self didFinishWithError:[NSError errorWithDomain:@"BCRESTCall" code:BCGeneralTimeoutError userInfo:@{@"reason" : @"timeout"}]];
                }
            };
        } else {
            [self.delegate bcRestCall:self didFinishWithError:[NSError errorWithDomain:@"BCRESTCall" code:BCGeneralTimeoutError userInfo:@{@"reason" : @"timeout"}]];
        }
    }
}

- (void)didSucceedWithArray:(NSArray *)array {
    NSURLRequest *request = array[1];
    NSObject *object = array[2];
    
    if (request == self.currentRequest && self.state == BCRestCallStateOngoingRequest) {
        self.state = BCRestCallStateIdle;
        [self stopTimer];
        if (self.suspended) {
            
            __block __unsafe_unretained BCRESTCall *block_self = self;
            self.delayedCallback = ^() {
                if (block_self.state != BCRestCallStateCanceled) {
                    [block_self.delegate bcRestCall:block_self didFinishWithResult:object];
                }
            };
            
        } else {
            [self.delegate bcRestCall:self didFinishWithResult:object];
        }
    }
}

- (void)didFailWithArray:(NSArray *)array {
    NSURLRequest *request = array[1];
    NSError *error = array[2];
    
    if (request == self.currentRequest && self.state == BCRestCallStateOngoingRequest) {
        self.connectRetryCount++;
        if(self.connectRetryCount > MAX_CONNECT_RETRY_COUNT) {
            self.state = BCRestCallStateIdle;
            [self stopTimer];
            self.connectRetryCount = 0;
            if (self.suspended) {
                
                __block __unsafe_unretained BCRESTCall *block_self = self;
                self.delayedCallback = ^() {
                    if (block_self.state != BCRestCallStateCanceled) {
                        [block_self.delegate bcRestCall:block_self didFinishWithError:error];
                    }
                };
            } else {
                [self.delegate bcRestCall:self didFinishWithError:error];
            }
            
            
        } else {
            [self startOperation];
        }
    }
}

#pragma mark -
#pragma mark BCHTTPConnectionDelegate
//BEWARE!!! there calls are on background thread if the operation queue is set
- (void)bcHttpConnection:(BCHTTPConnection *)connection request:(NSURLRequest *)request didSucceedWithData:(NSData *)data {
    self.connectRetryCount = 0;
    NSError *error = nil;
    NSObject *result = [self.parser parse:data error:&error];
    if (error) {
        error = [NSError errorWithDomain:@"BCRESTCall" code:BCGeneralFormattingError userInfo:@{@"reason" : @"Formatting error"}];
        [self performSelectorOnMainThread:@selector(didFailWithArray:) withObject:@[connection, request, error] waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(didSucceedWithArray:) withObject:@[connection, request, result] waitUntilDone:NO];
    }
}

- (void)bcHttpConnection:(BCHTTPConnection *)connection request:(NSURLRequest *)request didFailWithError:(NSError *)error {
    error = [NSError errorWithDomain:@"BCRESTCall" code:BCGeneralNetworkError userInfo:@{@"reason" : @"Network Error"}];
    [self performSelectorOnMainThread:@selector(didFailWithArray:) withObject:@[connection, request, error] waitUntilDone:NO];
}

- (void)dealloc {
    [self cancel];
}

@end

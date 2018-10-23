//
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCChatImpl.h"
#import <BoldEngine/BCMessage.h>
#import "BCStartChatCall.h"
#import "BCOSSCommunicator.h"
#import "NSString+RandomIdentifier.h"
#import <BoldEngine/BCPerson.h>
#import "BCFinishChatCall.h"
#import "BCForm.h"
#import "BCTimer.h"
#import "BCErrorCodes.h"
#import "NSMutableArray+nonRetaining.h"
#import "BCChatImpl+Notifications.h"
#import "BCGetUnavailableFormCall.h"

#define GEOFLUENT 0

/** @file */
/**
 * @brief The inner state of the BCChatImpl.
 @since Version 1.0
 */
typedef enum {
    BCChatImplStateIdle,/**< Chat is in idle state. @since Version 1.0*/
    BCChatImplStateError, /**< Chat is in error state.  @since Version 1.0*/
    BCChatImplStateChatStarting, /**< StartChat is being called.  @since Version 1.0*/
    BCChatImplStateChatStarted, /**< Chat is started by startChat or createChat, or submitPreChatAnswers. @since Version 1.0*/
    BCChatImplStateOSSStarting, /**< OSS is started. @since Version 1.0*/
    BCChatImplStateOSSStarted, /**< OSS notified being connected and running. @since Version 1.0*/
    BCChatImplStateSendingVisitorMessagesBeforeFinishing, /**< The previously added messages sent before starting to finish the chat. @since Version 1.0*/
    BCChatImplStateFinishing, /**< Calling finishChat. @since Version 1.0*/
    BCChatImplStateFinishingUpdateArrived, /**<Calling finishChat, updateChat arrived from being closed. @since Version 1.0*/
    BCChatImplStateFinishedUpdateNotArrived, /**<finishChat finished, waiting for updateChat to arrive. @since Version 1.0*/
    BCChatImplStateGettingUnavailableForm, /**<finishChat finished, waiting for updateChat to arrive. @since Version 1.0*/
    BCChatImplStateFinished /**<Chatting is finished. @since Version 1.0*/
}BCChatImplState;

/**
 BCChatImpl private interface.
 @since Version 1.0
 */
@interface BCChatImpl () <BCStartChatCallDelegate,BCFinishChatCallDelegate, BCOSSCommunicatorDelegate, BCGetUnavailableFormCallDelegate>

/**
 The inner state.
 @since Version 1.0
 */
@property(nonatomic, assign)BCChatImplState state;

/**
 Suspended state.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL suspended;

/**
 The chat ID.
 @since Version 1.0
 */
@property(nonatomic, copy)NSString *chatId;

/**
 The chat key;
 @since Version 1.0
 */
@property(nonatomic, copy)NSString *chatKey;

/**
 The client ID.
 @since Version 1.0
 */
@property(nonatomic, copy)NSString *clientId;

/**
 The websocket URL.
 @since Version 1.0
 */
@property(nonatomic, copy)NSString *webSocketURL;

/**
 The long poll URL.
 @since Version 1.0
 */
@property(nonatomic, copy)NSString *longPollURL;

/**
 The client timeout.
 @since Version 1.0
 */
@property(nonatomic, assign)NSInteger clientTimeout;

/**
The time in seconds that states if an operator did not send a message to the client within this time, call for the unavailable form and show it, meaning the chat is closed.
@since Version 1.0
*/
@property(nonatomic, assign)NSInteger answerTimeout;

/**
 The common connectivity manager.
 @since Version 1.0
 */
@property(nonatomic, strong)BCConnectivityManager *connectivityManager;

/**
 StartChat call.
 @since Version 1.0
 */
@property(nonatomic, strong)BCStartChatCall *startChatCall;

/**
 FinishChat call.
 @since Version 1.0
 */
@property(nonatomic, strong)BCFinishChatCall *finishChatCall;

/**
 GetUnavailableFormCall object.
 @since Version 1.0
 */
@property (nonatomic, strong)BCGetUnavailableFormCall *getUnavailableFormCall;

/**
 The oss communicator.
 @since Version 1.0
 */
@property(nonatomic, strong)BCOSSCommunicator *ossCommunicator;

/**
 Array of operators and the visitor who participate in the chat. This is for caching their data.
 @since Version 1.0
 */
@property(nonatomic, strong)NSMutableArray *persons;

/**
 The previous messages of this chat.
 @since Version 1.0
*/
@property(nonatomic, strong)NSArray *messages;

/**
 The system message for the current state. It can occur if the user started a chat but it was not still answered by any operator.
 @since Version 1.0
 */
@property(nonatomic, strong)BCMessage *currentSystemMessage;

/**
 Last chat message ID received from the server.
 @since Version 1.0
 */
@property(nonatomic, assign)long long lastChatMessageId;

/**
 The current visitor who participates the chat.
 @since Version 1.0
 */
@property(nonatomic, strong)BCPerson *visitor;

/**
 Messages that were received from the visitor, but were not sent through the oss yet.
 @since Version 1.0
 */
@property(nonatomic, strong)NSMutableArray *bufferedMessages;

/**
 The visitor current typing state.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL bufferedTyping;

/**
 The end reason of the chat if it ended.
 @since Version 1.0
 */
@property(nonatomic, assign)BCChatEndReason currentReason;

/**
 The end date of the chat if it ended.
 @since Version 1.0
 */
@property(nonatomic, strong)NSDate *currentEndDate;

/**
 The current post-chat form description if the chat ended and it was requested.
 @since Version 1.0
 */
@property(nonatomic, strong)BCForm *currentPostChatForm;

/**
 If the operator is busy and the unavailable for can be shown to the visitor.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL operatorBusyUnavailableFormAvailable;

/**
 A timer for checking if the chat was answered in the time limit given by answerTimeout.
 @since Version 1.0
 */
@property(nonatomic, strong)BCTimer *answerTimeoutTimer;

/**
 The answer timer was suspended on suspend.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL answerTimeoutCanceledOnSuspend;

/**
 The chat was answered by an operator.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL answered;

/**
 Starts the startChat call
 @since Version 1.0
 */
- (void)startStartChatCall;

/**
 Starts the finishChat call
 @since Version 1.0
 */
- (void)startFinishChatCall;

/**
 Starts or restarts the answer timeout timer.
 @since Version 1.0
 */
- (void)restartAnswerTimeoutTimer;

/**
 Stops the answer timeout timer.
 @since Version 1.0
 */
- (void)stopAnswerTimeoutTimer;

/**
 Callback for answer timeout timer.
 @since Version 1.0
 */
- (void)answerTimeoutTimerTick;

@end

@implementation BCChatImpl

@synthesize state = _state;
@synthesize suspended = _suspended;
@synthesize messages = _messages;
@synthesize currentSystemMessage = _currentSystemMessage;
@synthesize chatId = _chatId;
@synthesize chatKey = _chatKey;
@synthesize clientId = _clientId;
@synthesize connectivityManager = _connectivityManager;
@synthesize webSocketURL = _webSocketURL;
@synthesize longPollURL = _longPollURL;
@synthesize clientTimeout = _clientTimeout;
@synthesize persons = _persons;
@synthesize visitor = _visitor;
@synthesize startChatCall = _startChatCall;
@synthesize getUnavailableFormCall = _getUnavailableFormCall;
@synthesize bufferedMessages = _bufferedMessages;
@synthesize currentReason = _currentReason;
@synthesize currentEndDate = _currentEndDate;
@synthesize currentPostChatForm = _currentPostChatForm;
@synthesize operatorBusyUnavailableFormAvailable = _operatorBusyUnavailableFormAvailable;
@synthesize answerTimeoutTimer = _answerTimeoutTimer;
@synthesize answerTimeoutCanceledOnSuspend = _answerTimeoutCanceledOnSuspend;

@synthesize chatTyperDelegates = _chatTyperDelegates;
@synthesize chatMessageDelegates = _chatMessageDelegates;
@synthesize chatQueueDelegates = _chatQueueDelegates;
@synthesize chatStateDelegates = _chatStateDelegates;
@synthesize lastChatMessageId = _lastChatMessageId;

@synthesize language = _language;

- (long long)lastChatMessageId {
    if (self.ossCommunicator) {
        return self.ossCommunicator.lastChatMessageId;
    } else {
        return _lastChatMessageId;
    }
}

- (id)initWithChatId:(NSString *)chatId chatKey:(NSString *)chatKey clientId:(NSString *)clientId visitor:(BCPerson *)visitor  connectivityManager:(BCConnectivityManager *)connectivityManager webSocketUrl:(NSString *)webSocketUrl longPollUrl:(NSString *)longPollUrl  clientTimeout:(NSInteger)clientTimeout answerTimeout:(NSInteger)answerTimeout{
    if ((self = [self init])) {
        self.state = BCChatImplStateChatStarted;
        self.chatId = chatId;
        self.chatKey = chatKey;
        self.clientId = clientId;
        self.visitor = visitor;
        self.connectivityManager = connectivityManager;
        self.webSocketURL = webSocketUrl;
        self.longPollURL = longPollUrl;
        self.clientTimeout = clientTimeout;
        self.answerTimeout = answerTimeout;
        self.persons = [NSMutableArray array];
        self.messages = [NSMutableArray array];
        self.bufferedMessages = [NSMutableArray array];
        self.chatTyperDelegates = [NSMutableArray bcNonRetainingArrayWithCapacity:2];
        self.chatMessageDelegates = [NSMutableArray bcNonRetainingArrayWithCapacity:2];
        self.chatQueueDelegates = [NSMutableArray bcNonRetainingArrayWithCapacity:2];
        self.chatStateDelegates = [NSMutableArray bcNonRetainingArrayWithCapacity:2];
    }
    return self;
}

- (void)addChatTyperDelegate:(id<BCChatTyperDelegate>)delegate {
    [self.chatTyperDelegates addObject:delegate];
}

- (void)removeChatTyperDelegate:(id<BCChatTyperDelegate>)delegate {
    [self.chatTyperDelegates removeObject:delegate];
}

- (void)addChatMessageDelegate:(id<BCChatMessageDelegate>)delegate {
    [self.chatMessageDelegates addObject:delegate];
}

- (void)removeChatMessageDelegate:(id<BCChatMessageDelegate>)delegate {
    [self.chatMessageDelegates removeObject:delegate];
}

- (void)addChatQueueDelegate:(id<BCChatQueueDelegate>)delegate {
    [self.chatQueueDelegates addObject:delegate];
}

- (void)removeChatQueueDelegate:(id<BCChatQueueDelegate>)delegate {
    [self.chatQueueDelegates removeObject:delegate];
}

- (void)addChatStateDelegate:(id<BCChatStateDelegate>)delegate {
    [self.chatStateDelegates addObject:delegate];
}

- (void)removeChatStateDelegate:(id<BCChatStateDelegate>)delegate {
    [self.chatStateDelegates removeObject:delegate];
}

- (void)startChat {
    if (self.suspended) return;
    if (self.state == BCChatImplStateIdle || self.state == BCChatImplStateError) {
        self.state = BCChatImplStateChatStarting;
        [self startStartChatCall];
    } else if (self.state == BCChatImplStateChatStarted) {
        self.state = BCChatImplStateOSSStarting;
        self.ossCommunicator = [self.connectivityManager ossCommunicator];
        self.ossCommunicator.webSocketURL = self.webSocketURL;
        self.ossCommunicator.longPollURL = self.longPollURL;
        self.ossCommunicator.chatKey = self.chatKey;
        self.ossCommunicator.clientId = self.clientId;
        self.ossCommunicator.delegate = self;
        self.ossCommunicator.timeoutInSeconds = self.clientTimeout;
        [self.ossCommunicator start];
    }
}

- (void)startStartChatCall {
    [self.startChatCall cancel], self.startChatCall = nil;
    self.startChatCall = [self.connectivityManager startChatCall];
    self.startChatCall.chatKey = self.chatKey;
    self.startChatCall.delegate = self;
    self.startChatCall.lastChatMessageId = self.lastChatMessageId;
    [self.startChatCall start];
}

- (void)startFinishChatCall {
    [self.finishChatCall cancel], self.finishChatCall = nil;
    self.finishChatCall = [self.connectivityManager finishChatCall];
    self.finishChatCall.chatKey = self.chatKey;
    self.finishChatCall.clientId = self.clientId;
    self.finishChatCall.delegate = self;
    [self.finishChatCall start];
}

- (void)finishChat {
    if (self.suspended) return;
    
    [self stopAnswerTimeoutTimer];
    self.currentReason = BCChatEndReasonVisitorFinished;
    self.currentEndDate = [NSDate date];
    
    if (self.state == BCChatImplStateChatStarting) {
        [self.startChatCall cancel];
        self.startChatCall = nil;
        [self startFinishChatCall];
        self.state = BCChatImplStateFinishing;
    } else if ( self.state == BCChatImplStateOSSStarting || self.state == BCChatImplStateChatStarted) {
        self.state = BCChatImplStateFinished;
        [self.ossCommunicator close];
        self.ossCommunicator = nil;
        [self propagateDidFinishWithReason:BCChatEndReasonVisitorFinished time:[NSDate date] postChatForm:nil];
    } else if (self.state == BCChatImplStateOSSStarted) {
        if ([self.ossCommunicator countOfUnsentMessages]) {
            self.state = BCChatImplStateSendingVisitorMessagesBeforeFinishing;
        } else {
            [self startFinishChatCall];
            self.state = BCChatImplStateFinishing;
        }
    } else if ( self.state == BCChatImplStateGettingUnavailableForm ) {
        //nothing to do if finish is called and getting unavailable
    } else if (self.state != BCChatImplStateFinished &&
               self.state != BCChatImplStateFinishing &&
               self.state != BCChatImplStateFinishingUpdateArrived &&
               self.state != BCChatImplStateFinishedUpdateNotArrived){
        self.state = BCChatImplStateFinished;
        [self.ossCommunicator close];
        self.ossCommunicator = nil;
        [self propagateDidFinishWithReason:BCChatEndReasonVisitorFinished time:[NSDate date] postChatForm:nil];
    }
}

- (BOOL)finishChatToAnswerUnavailableForm {
    if (self.state == BCChatImplStateGettingUnavailableForm) {
        return NO;
    }
    [self stopAnswerTimeoutTimer];
    self.state = BCChatImplStateFinished;
    [self.startChatCall cancel];
    self.startChatCall = nil;
    [self.finishChatCall cancel];
    self.finishChatCall = nil;
    [self.ossCommunicator close];
    self.ossCommunicator = nil;
    
    self.state = BCChatImplStateGettingUnavailableForm;
    self.getUnavailableFormCall = [self.connectivityManager getUnavailableFormCall];
    self.getUnavailableFormCall.chatKey = self.chatKey;
    self.getUnavailableFormCall.clientId = self.clientId;
    self.getUnavailableFormCall.delegate = self;
    [self.getUnavailableFormCall start];
    return YES;
}

- (void)suspend {
    if (self.suspended) return;
    
    if (self.state == BCChatImplStateChatStarting) {
        [self.startChatCall suspend];
    } else if (self.state == BCChatImplStateOSSStarting || self.state == BCChatImplStateOSSStarted || self.state == BCChatImplStateSendingVisitorMessagesBeforeFinishing) {
        [self.ossCommunicator suspend];
        if (self.answerTimeoutTimer) {
            self.answerTimeoutCanceledOnSuspend = YES;
            [self stopAnswerTimeoutTimer];
        }
    } else if (self.state == BCChatImplStateFinishing || self.state == BCChatImplStateFinishingUpdateArrived) {
        [self.finishChatCall suspend];
        [self.ossCommunicator suspend];
    } else if (self.state == BCChatImplStateGettingUnavailableForm) {
        [self.getUnavailableFormCall suspend];
    }
    self.suspended = YES;
}

- (void)resume {
    if (!self.suspended) return;
    
    self.suspended = NO;
    if (self.state == BCChatImplStateChatStarting) {
        [self.startChatCall resume];
    } else if (self.state == BCChatImplStateOSSStarting || self.state == BCChatImplStateOSSStarted || self.state == BCChatImplStateSendingVisitorMessagesBeforeFinishing){
        if (self.answerTimeoutCanceledOnSuspend) {
            self.answerTimeoutCanceledOnSuspend = NO;
            [self restartAnswerTimeoutTimer];
        }
        [self.ossCommunicator resume];
    } else if (self.state == BCChatImplStateFinishing  || self.state == BCChatImplStateFinishingUpdateArrived) {
        [self.finishChatCall resume];
        [self.ossCommunicator resume];
    } else if (self.state == BCChatImplStateGettingUnavailableForm) {
        [self.getUnavailableFormCall resume];
    }
}

- (void)sendMessage:(BCMessage *)message {
    if (self.suspended) return;
    
    if (!message.sender) {
        message.sender = self.visitor;
    }
    
    if (self.state == BCChatImplStateIdle || self.state == BCChatImplStateChatStarting || self.state == BCChatImplStateChatStarted) {
        [self.bufferedMessages addObject:message];
    } else if (self.state == BCChatImplStateOSSStarting || self.state == BCChatImplStateOSSStarted){
        [self.bufferedMessages addObject:message];
        [self.ossCommunicator sendMessage:message];
    }
}

- (BCMessage *)sendMessageText:(NSString *)messageText {
    
    BCMessage *message = [[BCMessage alloc] initWithID:[NSString bcRandomIdentifier]
                                            sender:nil
                                               created:[NSDate dateWithTimeIntervalSinceNow:0]
                                               updated:[NSDate dateWithTimeIntervalSinceNow:0]
                                              htmlText:messageText];
    message.sender = self.visitor;
    [self sendMessage:message];
    return message;
}

- (void)sendVisitorTyping:(BOOL)visitorTyping {
    if (self.suspended) return;
    
    if (self.state == BCChatImplStateIdle || self.state == BCChatImplStateChatStarting || self.state == BCChatImplStateChatStarted) {
        self.bufferedTyping = visitorTyping;
    } else if (self.state == BCChatImplStateOSSStarting || self.state == BCChatImplStateOSSStarted){
        [self.ossCommunicator sendTyping:visitorTyping];
    }
    
}

#pragma mark -
#pragma mark Answer Timeout Timer
- (void)restartAnswerTimeoutTimer {
    [self stopAnswerTimeoutTimer];
    if (self.answerTimeout) {
        self.answerTimeoutTimer = [BCTimer scheduledNonRetainingTimerWithTimeInterval:self.answerTimeout target:self selector:@selector(answerTimeoutTimerTick) userInfo:nil repeats:NO];
    }
}

- (void)stopAnswerTimeoutTimer {
    [self.answerTimeoutTimer invalidate];
    self.answerTimeoutTimer = nil;
}

- (void)answerTimeoutTimerTick {
    [self finishChatToAnswerUnavailableForm];
}

#pragma mark -
#pragma mark BCStartChatCallDelegate
- (void)bcStartChatCall:(BCStartChatCall *)startChatCall didFinishWithResult:(BCStartChatCallResult *)result {
    if (result.statusSuccess) {
        self.clientId = result.clientId;
        self.ossCommunicator = [self.connectivityManager ossCommunicator];
        self.ossCommunicator.webSocketURL = result.webSocketURL;
        self.ossCommunicator.longPollURL = result.longPollURL;
        self.ossCommunicator.chatKey = self.chatKey;
        self.ossCommunicator.clientId = self.clientId;
        self.ossCommunicator.delegate = self;
        self.ossCommunicator.timeoutInSeconds = result.clientTimeout;
        self.state = BCChatImplStateOSSStarting;
        [self.ossCommunicator start];
    } else {
        self.state = BCChatImplStateError;
        [self propagateDidFinishWithError:[NSError errorWithDomain:@"BCChat" code:BCChatErrorFailedToStart userInfo:@{@"reason":@"start fail", @"localisedReason":result.errorMessage ? result.errorMessage : @""}]];
    }
}

- (void)bcStartChatCall:(BCStartChatCall *)startChatCall didFinishWithError:(NSError *)error {
    self.state = BCChatImplStateError;
    [self.ossCommunicator close];
    self.ossCommunicator = nil;
    [self propagateDidFinishWithError:[NSError errorWithDomain:@"BCChat" code:BCChatErrorFailedToStart userInfo:@{@"reason":@"network error"}]];
}

#pragma mark -
#pragma mark BCFinishChatCallDelegate
- (void)bcFinishChatCall:(BCFinishChatCall *)finishMessageCall didFinishWithResult:(BCFinishChatCallResult *)result {
    [self stopAnswerTimeoutTimer];
    if (result.statusSuccess) {
        BCForm *postChatDescription = [[BCForm alloc] initWithFormFields:result.postChat];
        self.currentPostChatForm = postChatDescription;
        /*if (self.state == BCChatImplStateFinishing) {
            self.state = BCChatImplStateFinishedUpdateNotArrived;
            self.currentPostChatForm = postChatDescription;
        } else*/ if (self.state == BCChatImplStateFinishing || self.state == BCChatImplStateFinishingUpdateArrived) {
            self.state = BCChatImplStateFinished;
            [self.ossCommunicator close];
            self.ossCommunicator = nil;
            [self propagateDidFinishWithReason:self.currentReason time:self.currentEndDate postChatForm:postChatDescription];
        }
    } else {
        self.state = BCChatImplStateError;
        [self.ossCommunicator close];
        self.ossCommunicator = nil;
        [self propagateDidFinishWithError:[NSError errorWithDomain:@"BCChat" code:BCChatErrorFailedToFinish userInfo:@{@"reason":@"finish fail", @"localisedReason":result.errorMessage ? result.errorMessage : @""}]];
    }
}

- (void)bcFinishChatCall:(BCFinishChatCall *)finishMessageCall didFinishWithError:(NSError *)error {
    self.state = BCChatImplStateError;
    [self.ossCommunicator close];
    self.ossCommunicator = nil;
    [self propagateDidFinishWithError:[NSError errorWithDomain:@"BCChat" code:BCChatErrorFailedToFinish userInfo:@{@"reason":@"network error"}]];
}

#pragma mark -
#pragma mark BCGetUnavailableFormCallDelegate
- (void)bcGetUnavailableFormCall:(BCGetUnavailableFormCall *)getUnavailableFormCall didFinishWithResult:(BCGetUnavailableFormCallResult *)result {
    if (result.statusSuccess) {
        [self propagateDidFinishWithUnavailableReason:BCUnavailableReasonUnknown unavailableForm:[BCForm formWithFormFields:result.unavailableForm] unavailableMessage:nil];
    }else {
        self.state = BCChatImplStateError;
        [self.ossCommunicator close];
        self.ossCommunicator = nil;
        [self propagateDidFinishWithError:[NSError errorWithDomain:@"BCChat" code:BCChatErrorFailedToGetUnavailableForm userInfo:@{@"reason":@"get unavailable form", @"localisedReason":result.errorMessage ? result.errorMessage : @""}]];
    }
}

- (void)bcGetUnavailableFormCall:(BCGetUnavailableFormCall *)getUnavailableFormCall didFinishWithError:(NSError *)error {
    [self propagateDidFinishWithError:[NSError errorWithDomain:@"BCChat" code:BCChatErrorFailedToGetUnavailableForm userInfo:@{@"reason":@"get unavailable form"}]];
}

#pragma mark -
#pragma mark BCOSSCommunicatorDelegate
- (void)ossCommunicatorDidSucceedToConnect:(BCOSSCommunicator *)ossCommunicator {
    self.state = BCChatImplStateOSSStarted;
    [self restartAnswerTimeoutTimer];
    [self propagateDidConnect];
    if (self.bufferedTyping) {
        [self.ossCommunicator sendTyping:YES];
        self.bufferedTyping = NO;
    }
    
    for (BCMessage *message in self.bufferedMessages) {
        [self.ossCommunicator sendMessage:message];
    }
    //[self.bufferedMessages removeAllObjects];
}

- (void)ossCommunicator:(BCOSSCommunicator *)ossCommunicator didFailToConnectWithError:(NSError *)error {
    self.state = BCChatImplStateError;
    [self.ossCommunicator close];
    self.ossCommunicator = nil;
    [self propagateDidFinishWithError:[NSError errorWithDomain:@"BCChat" code:BCChatErrorOSSConnection userInfo:@{@"reason":@"oss connecting failed"}]];

}

- (void)ossCommunicator:(BCOSSCommunicator *)ossCommunicator didReceivePerson:(BCPerson *)person typing:(BOOL)typing {
    BCPerson *foundPerson = nil;
    
    for (BCPerson *p in self.persons) {
        if ([p.personId isEqualToString:person.personId]) {
            foundPerson = p;
            break;
        }
    }
    if (foundPerson) {
        if (person.personType) foundPerson.personType = person.personType;
        if (person.name) foundPerson.name = person.name;
        if (person.imageUrl) foundPerson.imageUrl = person.imageUrl;
        
    } else {
        BCPerson *newPerson = [[BCPerson alloc] init];
        newPerson.personId = person.personId;
        newPerson.personType = person.personType;
        newPerson.imageUrl = person.imageUrl;
        newPerson.name = person.name;
        foundPerson = newPerson;
        [self.persons addObject:newPerson];
    }
    
    if (person.personId == nil) {
        int i = 9;
        i++;
    }
    
    if (![self.visitor.personId isEqualToString:person.personId]) {
        [self propagateDidUpdateTyper:foundPerson typing:typing];
    }
}

- (void)ossCommunicator:(BCOSSCommunicator *)ossCommunicator didReceiveMessage:(BCMessage *)message {
    
    //filter if the message was notified before
    for (BCMessage *prevMessage in self.messages) {
        if ([prevMessage.ID isEqualToString:message.ID]) {
            return;
        }
    }
    //finish answer timer, operator message got
    if (message.sender.personType == BCPersonTypeOperator) {
        [self stopAnswerTimeoutTimer];
        self.answered = YES;
        self.currentSystemMessage = nil;
    }
    
    BCPerson *foundPerson = nil;
    for (BCPerson *p in self.persons) {
        if ([p.personId isEqualToString:message.sender.personId]) {
            foundPerson = p;
            break;
        }
    }
    if (foundPerson) {
        if (message.sender.personType) foundPerson.personType = message.sender.personType;
        if (message.sender.name) foundPerson.name = message.sender.name;
        if (message.sender.imageUrl) foundPerson.imageUrl = message.sender.imageUrl;
        
        if (foundPerson.personType) message.sender.personType = foundPerson.personType;
        if (foundPerson.name) message.sender.name = foundPerson.name;
        if (foundPerson.imageUrl) message.sender.imageUrl = foundPerson.imageUrl;
    } else {
        BCPerson *newPerson = [[BCPerson alloc] init];
        newPerson.personId = message.sender.personId;
        newPerson.personType = message.sender.personType;
        newPerson.imageUrl = message.sender.imageUrl;
        newPerson.name = message.sender.name;
        [self.persons addObject:newPerson];
    }
#if GEOFLUENT
    if ([self.language hasPrefix:@"en"]) {
        if (message.sender.personType == BCPersonTypeSystem) {
            
            return;
        } else {
            [((NSMutableArray *)(self.messages)) addObject:message];
        }
    } else {
    
        if (message.sender.personType == BCPersonTypeOperator) {
            return;
        } else if (message.sender.personType == BCPersonTypeSystem) {
            if ([message.sender.personId isEqualToString:self.visitor.personId]) {
                return;
            }
            
            BCPerson *foundPerson = nil;
            for (BCPerson *p in self.persons) {
                if ([p.personId isEqualToString:message.sender.personId]) {
                    foundPerson = p;
                    break;
                }
            }
            
            if (foundPerson) {
                message.sender = foundPerson;
                message.sender.personType = BCPersonTypeOperator;
            } else {
                return;
            }
            
        }
    }
#else
    if (message.sender.personType == BCPersonTypeSystem) {
        if (!self.answered) {
            self.currentSystemMessage = message;
        }
    } else {
        [((NSMutableArray *)(self.messages)) addObject:message];
    }
#endif
    [self propagateDidAddMessage:message];
}

- (void)ossCommunicator:(BCOSSCommunicator *)ossCommunicator didReceiveAutoMessage:(BCMessage *)message {
    [self propagateDidAddAutoMessage:message];
}

- (void)ossCommunicator:(BCOSSCommunicator *)ossCommunicator didReceiveBusyWithPosition:(NSInteger)position unavailableFormAvailable:(BOOL)unavailableFormAvailable {
    BOOL hasOperatorAnswer = NO;
    for (BCMessage *message in self.messages) {
        if (message.sender.personType == BCPersonTypeOperator) {
            hasOperatorAnswer = YES;
            break;
        }
    }
    //cancel these callbacks if the chat was answered
    if (!hasOperatorAnswer) {
        self.operatorBusyUnavailableFormAvailable = (position > 0) && unavailableFormAvailable;
        [self propagateDidUpdateQueuePosition:position unavailableFormAvailable:unavailableFormAvailable];
    }
}

- (void)ossCommunicator:(BCOSSCommunicator *)ossCommunicator didEndWithReason:(BCOSSCommunicatorEndReason)reason time:(NSDate *)date error:(NSError *)error {
    [self stopAnswerTimeoutTimer];
    if (self.state == BCChatImplStateFinished) return;
    switch (reason) {
        case BCOSSCommunicatorEndReasonVisitor:
            self.currentReason = BCChatEndReasonVisitorFinished;
            self.currentEndDate = date;
            if ( self.state == BCChatImplStateFinishing) {
                self.state = BCChatImplStateFinishingUpdateArrived;
            } else if (self.state == BCChatImplStateFinishedUpdateNotArrived) {
                self.state = BCChatImplStateFinished;
                [self.ossCommunicator close];
                self.ossCommunicator = nil;
                [self propagateDidFinishWithReason:self.currentReason time:self.currentEndDate postChatForm:self.currentPostChatForm];
            }
            break;
            
        case BCOSSCommunicatorEndReasonOperator:
            self.currentReason = BCChatEndReasonOperatorFinished;
            self.currentEndDate = date;
            if (self.state == BCChatImplStateOSSStarted) {
                self.state = BCChatImplStateFinishingUpdateArrived;
                [self startFinishChatCall];
            }
            break;
        
        //case BCOSSCommunicatorEndReasonDisconnect:
        //case BCOSSCommunicatorEndReasonTimeout:
        //case BCOSSCommunicatorEndReasonClosed:
        default:
            self.currentEndDate = date;
            if (self.state == BCChatImplStateFinishing) {
                self.currentReason = BCChatEndReasonVisitorFinished;
                self.state = BCChatImplStateFinishingUpdateArrived;
                [self.ossCommunicator close];
                self.ossCommunicator = nil;
            } else if (self.state == BCChatImplStateFinishedUpdateNotArrived) {
                self.currentReason = BCChatEndReasonVisitorFinished;
                self.state = BCChatImplStateFinished;
                [self.ossCommunicator close];
                self.ossCommunicator = nil;
                [self propagateDidFinishWithReason:self.currentReason time:self.currentEndDate postChatForm:self.currentPostChatForm];
                
            } else {
                self.currentReason = BCChatEndReasonChatTimeout;
                self.state = BCChatImplStateFinishingUpdateArrived;
                [self.ossCommunicator close];
                self.ossCommunicator = nil;
                [self startFinishChatCall];
            }
            
            break;
    }
}

- (void)ossCommunicator:(BCOSSCommunicator *)ossCommunicator didAcceptChat:(NSString *)acceptTime {
    if (acceptTime) {
        [self propagateDidAccept];
    }
}

- (void)ossCommunicator:(BCOSSCommunicator *)ossCommunicator didSendMessage:(BCMessage *)message {
    BCMessage *foundMessage = nil;
    for (BCMessage *bufferedMessage in self.bufferedMessages) {
        if ([bufferedMessage.ID isEqualToString:message.ID]) {
            foundMessage = bufferedMessage;
            break;
        }
    }
    if (foundMessage) [self.bufferedMessages removeObject:foundMessage];
    
    [self propagateDidSendVisitorMessage:message];
    if (self.state == BCChatImplStateSendingVisitorMessagesBeforeFinishing) {
        if ([self.ossCommunicator countOfUnsentMessages] == 0) {
            [self startFinishChatCall];
            self.state = BCChatImplStateFinishing;
        }
    }
}

- (void)ossCommunicator:(BCOSSCommunicator *)ossCommunicator didSendTyping:(BOOL)typing {
    [self propagateDidSendVisitorTyping:typing];
}

- (void)ossCommunicatorDidReset:(BCOSSCommunicator *)ossCommunicator {
    self.state = BCChatImplStateIdle;
    self.lastChatMessageId = self.ossCommunicator.lastChatMessageId;
    self.ossCommunicator.delegate = nil;
    [self.ossCommunicator close];
    self.ossCommunicator = nil;
    [self startChat];
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
    [self.startChatCall cancel];
    self.startChatCall = nil;
    [self.finishChatCall cancel];
    self.finishChatCall = nil;
    [self.ossCommunicator close];
    self.ossCommunicator = nil;
    [self stopAnswerTimeoutTimer];
    [self.getUnavailableFormCall cancel];
    self.getUnavailableFormCall = nil;
}


@end

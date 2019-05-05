//
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCUnavailableReason.h"
#import "BCChat.h"
#import "BCSubmitUnavailableEmailDelegate.h"
#import "BCErrorCodes.h"
#import "BCCancelable.h"
#import "BCSubmitPreChatDelegate.h"
#import "BCSubmitPostChatDelegate.h"
#import "BCEmailChatHistoryDelegate.h"
#import "BCChangeLanguageDelegate.h"
#import "BCChatRecaptureDelegate.h"

@protocol BCChatSession;
@protocol BCChat;
@class BCForm;
@class BCPerson;

/**
 * @brief The main class protocol that is used to interact with an active chat session.
 * @details <p>The chat session is for performing the actual chat session. It is created by \link BCAccount \endlink through calling \link BCAccount::createChatSessionWithDelegate:language:\endlink and \link BCAccount::createChatSessionWithDelegate:language:visitorId:skipPreChat:externalParams:\endlink.
 * The working chat session is returned through \link BCCreateChatSessionDelegate \endlink callbacks.</p>
 * <p>It holds the pre, post and unavailable chat forms, and has an interface for their submissions. Moreover it has calls for requesting chat transcript in email and change language. There is also a delegate for chat recovery.</p>
 * @since Version 1.0
 */
@protocol BCChatSession <NSObject>

/**
 * @brief While the user fills the unavailable chat form, an operator can become active. This delegate is used to be notifed on this event.
 * @since Version 1.0
 */
@property(nonatomic, assign) id<BCChatRecaptureDelegate> chatRecaptureDelegate;

/**
 * @brief Current language string. 
 * @details It is an ISO 639-1 language code optionally followed by a dash then an ISO 3166-1 country code (en-US). If not set, the application's current language is going to be set.
 * @since Version 1.0
 */
@property (nonatomic, copy, readonly) NSString *language;

/**
 * @brief The Department ID.
 * @since Version 1.0
 */
@property (nonatomic, copy, readonly) NSString *departmentId;

/**
 * @brief The chat key of the current chat session. It gets a valid value, when the chat is created.
 * @since Version 1.0
 */
@property (nonatomic, copy, readonly) NSString *chatKey;

/**
 * @brief The person object of the current visitor. It is autogenerated with the \link BCAccount::createChatSessionWithDelegate:language:visitorId:skipPreChat:externalParams: visitorId \endlink given on creation.
 * @since Version 1.0
 */
@property (nonatomic, strong, readonly) BCPerson *visitor;

/**
 * @brief If the visitor was shown the unavailable chat form, this value shows if an operator became available meanwhile.
 * @since Version 1.0
 */
@property (nonatomic, readonly) BOOL recaptureAvailable;

/**
 * @brief The end reason of the chat if the chat ended.
 * @since Version 1.0
 */
@property (nonatomic, readonly) BCChatEndReason endReason;

/**
 * @brief If the chat is unavailable, this value shows the cause of unavailability.
 * @since Version 1.0
 */
@property (nonatomic, readonly) BCUnavailableReason unavailableReason;

/**
 * @brief If the chat is unavailable it has the textural description of unavailability.
 * @since Version 1.0
 */
@property (nonatomic, readonly) NSString *unavailableMessage;

/**
 * @brief The pre-chat form for the current chat session. It is filled on chat creation if there is pre-chat defined for the chat.
 * @since Version 1.0
 */
@property (nonatomic, readonly) BCForm *preChatForm;

/**
 * @brief The post chat form for the current chat session. It is filled after the chat ended.
 * @since Version 1.0
 */
@property (nonatomic, readonly) BCForm *postChatForm;

/**
 * @brief The unavailable chat form. It is filled only when it is needed to be displayed.
 * @since Version 1.0
 */
@property (nonatomic, readonly) BCForm *unavailableForm;

/**
 * @brief The chat instance for sending and receiving chat messages. It is set only when the chat is available.
 * @since Version 1.0
 */
@property (nonatomic, readonly)id<BCChat> chat;

/**
 * @brief A dictionary that contains the localized strings for the current set language.
 * @since Version 1.0
 */
@property (nonatomic, copy, readonly)NSDictionary *branding;

/**
 * @brief A dictionary that contains chat window settings.
 */
@property (nonatomic, copy, readonly)NSDictionary *chatWindowSettings;

/**
 * @brief Stop and finish of the current session. It can be called any time to cancel and close the session. There are no calls on the delegate after this call.
 * @since Version 1.0
 */
- (void)finishChatSession;

/**
 * @brief Suspends the current session. It needs to be called when the application goes to background.
 * @since Version 1.0
 */
- (void)suspend;

/**
 * @brief Resumes the suspended session. It needs to be called if the application resumes from background state.
 * @since Version 1.0
 */
- (void)resume;

/**
 * @brief Submit the answers for the unavailable chat form.
 * @param unavailableForm The form with the answers.
 * @param submitUnavailableEmailDelegate The delegate to call back the result
 * @since Version 1.0
 */
- (id<BCCancelable>)submitUnavailableEmail:(BCForm *)unavailableForm delegate:(id<BCSubmitUnavailableEmailDelegate>)submitUnavailableEmailDelegate;

/**
 * @brief Submit the answers for the pre chat form.
 * @param preChatForm The form with the answers.
 * @param submitPreChatDelegate The delegate to call back the result.
 * @since Version 1.0
 */
- (id<BCCancelable>)submitPreChat:(BCForm *)preChatForm andStartChatWithDelegate:(id<BCSubmitPreChatDelegate>)submitPreChatDelegate;

/**
 * @brief Submit the answers for the post chat form.
 * @param postChatForm The form with the answers.
 * @param submitPostChatDelegate The delegate to call back the result.
 * @since Version 1.0
 */
- (id<BCCancelable>)submitPostChat:(BCForm *)postChatForm delegate:(id<BCSubmitPostChatDelegate>)submitPostChatDelegate;

/**
 * @brief Requests to send the transcript of the chat the given email address, when the chat ended.
 * @param emailAddress The email address to send the transcript to.
 * @param emailChatHistoryDelegate The delegate to call back the result.
 * @since Version 1.0
 */
- (id<BCCancelable>)emailChatHistory:(NSString *)emailAddress delegate:(id<BCEmailChatHistoryDelegate>)emailChatHistoryDelegate;

/** 
 * @brief Request to change the current language. It changes the value of the brandings dictionary when finished and successful.
 * @param languageString The language string. This parameter must be an ISO 639-1 language code optionally followed by a dash then an ISO 3166-1 country code (en-US). If a language code is passed that is not recognized or supported en-US strings will be returned instead.
 * @param changeLanguageDelegate The delegate to call back the result.
 * @since Version 1.0
 */
- (id<BCCancelable>)changeLanguage:(NSString *)languageString delegate:(id<BCChangeLanguageDelegate>)changeLanguageDelegate;

@end

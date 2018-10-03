//
//  BoldEngine.h
//  BoldEngine
//
//  Created by Nissim Pardo on 13/09/2018.
//  Copyright © 2018 Nissim Pardo. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for BoldEngine.
FOUNDATION_EXPORT double BoldEngineVersionNumber;

//! Project version string for BoldEngine.
FOUNDATION_EXPORT const unsigned char BoldEngineVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BoldEngine/PublicHeader.h>

#import "BCChatRecovery.h"
#import "BCConnectivityManager.h"
#import "BCHTTPConnection.h"
#import "BCHTTPConnection_URLConnection.h"
#import "BCHTTPConnection_URLSession.h"
#import "BCOSSCall.h"
#import "BCOSSConnectCall.h"
#import "BCOSSFinishChatCall.h"
#import "BCOSSHeartBeatCall.h"
#import "BCOSSSendMessageCall.h"
#import "BCOSSVisitorTypingCall.h"
#import "BCOSSCommunicator.h"
#import "BCOSSLink.h"
#import "BCOSSLongPollLink.h"
#import "BCOSSWebSocketLink.h"
#import "BCOSSNotification.h"
#import "BCOSSAddMessageNotification.h"
#import "BCOSSAutoMessageNotification.h"
#import "BCOSSConnectNotification.h"
#import "BCOSSHeartBeatNotification.h"
#import "BCOSSUpdateBusyNotification.h"
#import "BCOSSUpdateChatNotification.h"
#import "BCOSSUpdateTyperNotification.h"
#import "BCOSSJSONResponsePreProcessor.h"
#import "BCOSSResponsePreProcessor.h"
#import "SRWebSocket.h"
#import "BCCall.h"
#import "BCRESTCall.h"
#import "BCRESTCallResult.h"
#import "BCRestCallResultParser.h"
#import "BCChangeLanguageCall.h"
#import "BCChangeLanguageCallParser.h"
#import "BCChangeLanguageCallResult.h"
#import "BCCreateChatCall.h"
#import "BCCreateChatCallParser.h"
#import "BCCreateChatCallResult.h"
#import "BCEmailChatHistoryCall.h"
#import "BCEmailChatHistoryCallParser.h"
#import "BCEmailChatHistoryCallResult.h"
#import "BCFinishChatCall.h"
#import "BCFinishChatCallParser.h"
#import "BCFinishChatCallResult.h"
#import "BCFormFieldParser.h"
#import "BCGetChatAvailabilityCall.h"
#import "BCGetChatAvailabilityCallParser.h"
#import "BCGetChatAvailabilityCallResult.h"
#import "BCGetUnavailableFormCall.h"
#import "BCGetUnavailableFormCallParser.h"
#import "BCGetUnavailableFormCallResult.h"
#import "BCLongPollCall.h"
#import "BCLongPollCallParser.h"
#import "BCPingChatCall.h"
#import "BCPingChatCallParser.h"
#import "BCPingChatCallResult.h"
#import "BCSendMessageCall.h"
#import "BCSendMessageCallParser.h"
#import "BCSendMessageCallResult.h"
#import "BCStartChatCall.h"
#import "BCStartChatCallParser.h"
#import "BCStartChatCallResult.h"
#import "BCSubmitPostChatCall.h"
#import "BCSubmitPostChatCallParser.h"
#import "BCSubmitPostChatCallResult.h"
#import "BCSubmitPreChatCall.h"
#import "BCSubmitPreChatCallParser.h"
#import "BCSubmitPreChatCallResult.h"
#import "BCSubmitUnavailableEmailCall.h"
#import "BCSubmitUnavailableEmailCallParser.h"
#import "BCSubmitUnavailableEmailCallResult.h"
#import "BCVisitorTypingCall.h"
#import "BCVisitorTypingCallParser.h"
#import "BCVisitorTypingCallResult.h"
#import "BCAccount+ServerSet.h"
#import "BCAccount.h"
#import "BCCancelable.h"
#import "BCCancelableImpl.h"
#import "BCChangeLanguageDelegate.h"
#import "BCChat.h"
#import "BCChatAvailability.h"
#import "BCChatAvailabilityChecker.h"
#import "BCChatImpl+Notifications.h"
#import "BCChatImpl.h"
#import "BCChatMessageDelegate.h"
#import "BCChatQueueDelegate.h"
#import "BCChatRecaptureDelegate.h"
#import "BCChatSession.h"
#import "BCChatSessionImpl.h"
#import "BCChatStateDelegate.h"
#import "BCChatTyperDelegate.h"
#import "BCCreateChatSessionDelegate.h"
#import "BCEmailChatHistoryDelegate.h"
#import "BCErrorCodes.h"
#import "BCSubmitPostChatDelegate.h"
#import "BCSubmitPreChatDelegate.h"
#import "BCSubmitUnavailableEmailDelegate.h"
#import "BCUnavailableReason.h"
#import "BCForm.h"
#import "BCFormField.h"
#import "BCFormFieldOption.h"
#import "BCMessage.h"
#import "BCPerson.h"
#import "BCBuiltInLocalisation.h"
#import "BCTimer.h"
#import "GTMNSString+BCURLArguments.h"
#import "NSMutableArray+nonRetaining.h"
#import "NSObject+nilOrValue.h"
#import "NSString+BCValidation.h"
#import "NSString+RandomIdentifier.h"
#import "NSString+StrippingHtml.h"

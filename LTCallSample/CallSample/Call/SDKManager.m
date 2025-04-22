//
//  SDKManager.m
//  CallSample
//
//  Created by Zayn on 2020/11/30.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "SDKManager.h"
#import "UserInfo.h"

@implementation SDKManager

+ (instancetype)sharedInstance {
    static SDKManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Login

- (void)initSDK {
    LTSDKOptions *options = [[LTSDKOptions alloc] init];
    options.licenseKey = [UserInfo licenseKey];
    options.userID = [UserInfo userID];
    options.uuid = [UserInfo uuid];
    options.url = [UserInfo url];
    
    //LTSDK
    [LTSDK initWithOptions:options completion:^(LTResponse * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response.returnCode == 0) {
                NSLog(@"init SDK success");
                [LTSDK getUsersWithCompletion:^(LTResponse * _Nonnull response, NSArray<LTUser *> * _Nullable users) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (response.returnCode == LTReturnCodeSuccess) {
                            NSLog(@"start SDK success");
                        } else {
                            NSLog(@"%@", response.returnMessage);
                        }
                    });
                }];
            } else if (response.returnCode == LTReturnCodeNotCurrentUser) {
                [LTSDK clean];
                [self initSDK];
            } else {
                NSLog(@"%@", response.returnMessage);
            }
        });
    }];
    
    //LTCallCenterManager
    [LTSDK getCallCenterManager].delegate = self;
    
    //CallKit
    [[LTCallKitProxy sharedInstance] configureProviderWithLocalizedName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] ringtoneSound:@"" iconTemplateImage:[UIImage imageNamed:@"iconCalling"]];
    
}

- (void)uploadNotificationKey:(void(^)(NSString *returnMsg))completion {

#ifdef DEBUG
    BOOL isDebug = YES;
#else
    BOOL isDebug = NO;
#endif
    
    [LTSDK updateNotificationKeyWithAPNSToken:self.voipToken voipToken:self.voipToken cleanOld:YES isDebug:isDebug completion:^(LTResponse * _Nonnull response) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (response.returnCode == LTReturnCodeSuccess) {
                    completion([NSString stringWithFormat:@"Update Token success: %@",self.voipToken]);
                } else {
                    completion(@"Update Token fail");
                }
            });
        }
    }];
}

#pragma mark - Call

- (void)startCallWithOptions:(LTCallOptions *)options account:(NSString *)account {

    LTCall *call = [[LTSDK getCallCenterManager] startCallWithUserID:[UserInfo userID] options:options setDelegate:self.delegate];

    if (call) {
        //Callkit
        CXHandle *callHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:account];
        CXCallUpdate *callkitUpdate = [[CXCallUpdate alloc] init];
        callkitUpdate.remoteHandle = callHandle;
        callkitUpdate.localizedCallerName = account;
        [[LTCallKitProxy sharedInstance] startOutgoingCall:call update:callkitUpdate];
        
        if ([self.delegate respondsToSelector:@selector(SDKManagerStartOutgoingCall:)]) {
            [self.delegate SDKManagerStartOutgoingCall:call];
        }
    }
}

- (void)startGroupCallWithOptions:(LTCallOptions *)options {

    LTCall *call = [[LTSDK getCallCenterManager] startCallWithUserID:[UserInfo userID] options:options setDelegate:self.delegate];
    if (call) {
        if ([self.delegate respondsToSelector:@selector(SDKManagerStartOutgoingCall:)]) {
            [self.delegate SDKManagerStartOutgoingCall:call];
        }
    }
}

- (void)parseIncomingPushWithNotifyWithPayload:(NSDictionary *)payload {
    [LTSDK parseIncomingPushWithNotify:payload];
}

- (void)queryCDR:(void(^)(NSString *returnMsg))completion {
    [[LTSDK getCallCenterManager] queryCDRWithUserID:[UserInfo userID] markTS:[[NSDate date] timeIntervalSince1970] * 1000 afterN:-20 completion:^(LTUserCDRResponse * _Nonnull response) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (response.returnCode == LTReturnCodeSuccess) {
                    NSMutableString *mutableString = [[NSMutableString alloc] init];
                    [mutableString appendFormat:@"queryCDR success %@ count\n", @(response.count)];
                    for (LTCallCDRNotificationMessage *cdrMessage in response.cdrMessages) {
                        
                        NSDate *date = [NSDate dateWithTimeIntervalSince1970:cdrMessage.callStartTime/1000];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
                        NSString *planStartDate = [dateFormatter stringFromDate:date];
                        
                        NSString *caller = cdrMessage.callerInfo.phoneNumber;
                        if (caller.length == 0) {
                            caller = cdrMessage.callerInfo.semiUID;
                        }
                        
                        NSString *callee = cdrMessage.calleeInfo.phoneNumber;
                        if (callee.length == 0) {
                            callee = cdrMessage.calleeInfo.semiUID;
                        }
                        
                        [mutableString appendFormat:@"caller:%@ callee:%@ \n startTime:%@ \n duringTime:%ds\n\n", caller,callee,planStartDate,cdrMessage.billingSecond];
                    }
                    completion(mutableString);
                } else {
                    completion(@"queryCDR fail..");
                }
            });
        }
    }];
}

#pragma mark - UserStatus

- (void)getUserStatusWithPhone:(NSString *)phone completion:(void(^)(NSString *returnMsg))completion {
    [LTSDK getUserStatusWithPhoneNumbers:@[phone] completion:^(LTResponse * _Nonnull response, NSArray<LTUserStatus *> * _Nullable userStatuses) {
        [self getUserStatusWithResponse:response userStatuses:userStatuses completion:completion];
    }];
}

- (void)getUserStatusWithSemiUID:(NSString *)semiUID completion:(void(^)(NSString *returnMsg))completion {
    [LTSDK getUserStatusWithSemiUIDs:@[semiUID] completion:^(LTResponse * _Nonnull response, NSArray<LTUserStatus *> * _Nullable userStatuses) {
        [self getUserStatusWithResponse:response userStatuses:userStatuses completion:completion];
    }];
}

- (void)getUserStatusWithResponse:(LTResponse *)response userStatuses:(NSArray<LTUserStatus *> *)userStatuses completion:(void(^)(NSString *returnMsg))completion {
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response.returnCode == LTReturnCodeSuccess) {
                LTUserStatus *userStatus = userStatuses.firstObject;
                completion([NSString stringWithFormat:@"phoneNumber:%@\nsemiUID:%@\nuserID:%@\n%@",userStatus.phoneNumber,userStatus.semiUID,userStatus.userID,userStatus.canVOIP ? @"can VoIP" : @"can not VoIP"]);
            } else {
                completion(response.returnMessage);
            }
        });
    }
}

#pragma mark - LTCallCenterDelegate

- (void)LTCallNotification:(LTCallNotificationMessage *_Nonnull)notificationMessage {
    CXCallUpdate *callkitUpdate = [[CXCallUpdate alloc] init];
    
    NSString *phoneNumber = notificationMessage.callerInfo.phoneNumber ?: @"Unknow Number";
    callkitUpdate.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:phoneNumber];
    callkitUpdate.localizedCallerName = phoneNumber;
    
    [[LTCallKitProxy sharedInstance] startIncomingCallWithUpdate:callkitUpdate completion:^id<LTCallKitDelegate> _Nullable(NSError * _Nullable error, NSUUID * _Nullable callUUID) {
        id<LTCallKitDelegate> callkitCall = nil;
        LTCall *call = [[LTSDK getCallCenterManager] startCallWithNotificationMessage:notificationMessage setDelegate:self.delegate];
        if (call) {
            LTCall *currentVoiceCall = nil;
            if ([self.delegate respondsToSelector:@selector(getVoiceCall)]) {
                currentVoiceCall = [self.delegate getVoiceCall];
            }
            
            if (!currentVoiceCall) {
                callkitCall = call;
                if ([self.delegate respondsToSelector:@selector(SDKManagerReceiveImcomingCall:)]) {
                    [self.delegate SDKManagerReceiveImcomingCall:call];
                }
            } else {
                [call busyCall];
            }
        }
        return callkitCall;
    }];
}


@end

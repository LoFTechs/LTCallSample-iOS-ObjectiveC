//
//  CallCenterManager.h
//  CallSample
//
//  Created by Zayn on 2020/11/30.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LTSDK/LTSDK.h>
#import <LTCallSDK/LTCallSDK.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SDKManagerDelegate <NSObject>
- (void)SDKManagerStartOutgoingCall:(LTCall *)call;
- (void)SDKManagerReceiveImcomingCall:(LTCall *)call;
- (LTCall *)getVoiceCall;

@end

@interface SDKManager : NSObject<LTCallCenterDelegate>

@property (weak, nonatomic) id<SDKManagerDelegate,LTCallDelegate> delegate;

@property (strong, nonatomic) NSString *apnsToken;
@property (strong, nonatomic) NSString *voipToken;

+ (instancetype)sharedInstance;

#pragma mark - Login

- (void)initSDK;
- (void)uploadNotificationKey:(void(^)(NSString *returnMsg))completion;

#pragma mark - Call

- (void)startCallWithOptions:(LTCallOptions *)options account:(NSString *)account;
- (void)startGroupCallWithOptions:(LTCallOptions *)options;
- (void)parseIncomingPushWithNotifyWithPayload:(NSDictionary *)payload;
- (void)queryCDR:(void(^)(NSString *returnMsg))completion;

#pragma mark - UserStatus

- (void)getUserStatusWithPhone:(NSString *)phone completion:(void(^)(NSString *returnMsg))completion;
- (void)getUserStatusWithSemiUID:(NSString *)semiUID completion:(void(^)(NSString *returnMsg))completion;


@end

NS_ASSUME_NONNULL_END

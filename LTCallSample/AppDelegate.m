//
//  AppDelegate.m
//  LTCallSample
//
//  Created by shane on 2023/2/7.
//

#import <Intents/Intents.h>
#import <UserNotifications/UserNotifications.h>
#import <LTSDK/LTSDK.h>

#import "AppDelegate.h"
#import "CallViewController.h"
#import "UserInfo.h"
#import "SDKManager.h"

@interface AppDelegate ()<PKPushRegistryDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupPushKit];

    SDKManager *manager = [SDKManager sharedInstance];
    manager.delegate = [CallViewController sharedInstance];
    [manager initSDK];
        
    return YES;
}

- (void)setupPushKit {
    _voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    _voipRegistry.delegate = self;
    _voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

#pragma mark - PKPushRegistryDelegate
- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    NSLog(@"didInvalidatePushTokenForType");
}

- (void)pushRegistry:(nonnull PKPushRegistry *)registry didUpdatePushCredentials:(nonnull PKPushCredentials *)pushCredentials forType:(nonnull PKPushType)type {
    SDKManager *manager = [SDKManager sharedInstance];
    manager.voipToken = [AppDelegate hexadecimalStringFromData:pushCredentials.token];
    [manager uploadNotificationKey:^(NSString * _Nonnull returnMsg) {
        NSLog(@"%@", returnMsg);
    }];
    NSLog(@"pushRegistry:voipToken:%@",manager.voipToken);
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    if ([type isEqualToString:PKPushTypeVoIP]) {
        NSLog(@"pushRegistry:%@", payload.dictionaryPayload);
        [[SDKManager sharedInstance] parseIncomingPushWithNotifyWithPayload:payload.dictionaryPayload];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completion();
    });
}

+ (NSString *)hexadecimalStringFromData:(NSData *)data {
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return nil;
    }
    
    const unsigned char *dataBuffer = data.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return [NSString stringWithFormat:@"%@",hexString];
}


@end

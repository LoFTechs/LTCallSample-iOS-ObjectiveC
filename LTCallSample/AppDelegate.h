//
//  AppDelegate.h
//  LTCallSample
//
//  Created by shane on 2023/2/7.
//

#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PKPushRegistryDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) PKPushRegistry *voipRegistry;

@end


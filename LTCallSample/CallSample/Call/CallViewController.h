//
//  CallViewController.h
//  CallSample
//
//  Created by LoFTech on 2018/10/16.
//  Copyright © 2018 LoFTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDKManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,CallViewStyle) {
    CallViewStyleIncoming,
    CallViewStyleOutgoing,
    CallViewStyleConnected
};

@interface CallViewController : UIViewController <SDKManagerDelegate,LTCallDelegate>
@property (strong, nonatomic, nullable) LTCall *call;
+ (instancetype)sharedInstance;
- (void)setViewStyle:(CallViewStyle)style;
- (void)setName:(NSString *)name;
- (void)setPhoneNumber:(NSString *)phoneNumber;
- (void)setCallState:(NSString *)callState;
- (void)show;
- (void)hide;
@end

NS_ASSUME_NONNULL_END

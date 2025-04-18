//
//  UserInfo.h
//  CallSample
//
//  Created by LoFTech on 2018/10/16.
//  Copyright © 2018 LoFTech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo : NSObject
+ (NSString *)licenseKey;
+ (NSString *)userID;
+ (NSString *)uuid;
+ (NSString *)url;
@end

NS_ASSUME_NONNULL_END

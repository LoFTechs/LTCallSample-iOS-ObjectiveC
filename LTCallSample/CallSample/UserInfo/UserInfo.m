//
//  UserInfo.m
//  CallSample
//
//  Created by LoFTech on 2018/10/16.
//  Copyright © 2018 LoFTech. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

static NSDictionary *userInfo = nil;
+ (NSDictionary *)getUserInfo {
    if (!userInfo) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"UserInfo" ofType:@"plist"];
        userInfo = [[NSDictionary alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    }
    return userInfo;
}

+ (NSString *)licenseKey {
    return [[self getUserInfo] objectForKey:@"LICENSEKEY"];
}

+ (NSString *)userID {
    return [[self getUserInfo] objectForKey:@"USERID"];
}

+ (NSString *)uuid {
    return [[self getUserInfo] objectForKey:@"UUID"];
}

+ (NSString *)url {
    return [[self getUserInfo] objectForKey:@"URL"];
}

@end

//
//  UIWindowSegue.m
//  CallSample
//
//  Created by LoFTech on 2018/10/16.
//  Copyright © 2018 LoFTech. All rights reserved.
//

#import "UIWindowSegue.h"
#import "AppDelegate.h"
@implementation UIWindowSegue
- (void)perform {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = [self destinationViewController];
}
@end

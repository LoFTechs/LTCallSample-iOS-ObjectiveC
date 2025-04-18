//
//  StatusBarViewController.h
//  CallSample
//
//  Created by LoFTech on 2018/10/16.
//  Copyright © 2018 LoFTech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol StatusBarDelegate <NSObject>
- (void)tapStatusBar;
@end

@interface StatusBarViewController : UIViewController
@property (nonatomic, assign) id<StatusBarDelegate> delegate;
+ (instancetype)sharedInstance;
- (void)setBarText:(NSString *)text;
- (void)show;
- (void)hide;
@end

NS_ASSUME_NONNULL_END

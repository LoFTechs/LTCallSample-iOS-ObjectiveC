//
//  StatusBarViewController.m
//  CallSample
//
//  Created by LoFTech on 2018/10/16.
//  Copyright © 2018 LoFTech. All rights reserved.
//

#import "StatusBarViewController.h"

@interface StatusBarViewController ()
@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) IBOutlet UILabel *lblBarText;

@end

@implementation StatusBarViewController
+ (instancetype)sharedInstance {
    static StatusBarViewController *_sharedInstance = nil;
    if (!_sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view from its nib.
}

- (void)initView {
    self.view.backgroundColor = [UIColor colorWithRed:(41.0/255.0) green:(171.0/255.0) blue:(226.0/255.0) alpha:1.0];
}

#pragma mark - Public
- (void)setBarText:(NSString *)text {
    [self.lblBarText setText:text];
}

- (void)show {
    if (self.window == nil) {
        CGRect frame = CGRectMake(0, 0, [UIApplication sharedApplication].statusBarFrame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height+20);
        self.window = [[UIWindow alloc] initWithFrame:frame];
        self.window.windowLevel = UIWindowLevelNormal + 1;
        self.window.hidden = NO;
        self.window.backgroundColor = [UIColor clearColor];
        [self.window setRootViewController:self];
        UITapGestureRecognizer *tapDataView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewEventHandler:)];
        [self.window addGestureRecognizer:tapDataView];
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        [[UIApplication sharedApplication] keyWindow].rootViewController.view.frame = CGRectMake(0, 20, screenWidth, screenHeight - 20);
    }
}

- (void)hide {
    self.lblBarText.text = @"";
    self.window = nil;
    [[UIApplication sharedApplication] keyWindow].rootViewController.view.frame = [UIScreen mainScreen].bounds;
}

- (IBAction)tapViewEventHandler:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tapStatusBar)]) {
        [self.delegate tapStatusBar];
    }
}

@end

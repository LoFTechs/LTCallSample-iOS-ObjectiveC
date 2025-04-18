//
//  CallViewController.m
//  CallSample
//
//  Created by LoFTech on 2018/10/16.
//  Copyright © 2018 LoFTech. All rights reserved.
//

#import "CallViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CallViewController ()
@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) CallViewStyle style;
@property (strong, nonatomic) NSString *phone;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnHangUp;
@property (weak, nonatomic) IBOutlet UIButton *btnOption;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end

@implementation CallViewController
+ (instancetype)sharedInstance {
    static CallViewController *_sharedInstance = nil;
    if (!_sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

- (CallViewController *)init {
    self = [super init];
    if (self) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.windowLevel = UIWindowLevelNormal + 1;
        self.window.backgroundColor = [UIColor clearColor];
        [self.window setRootViewController:self];
        self.window.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewStyle:self.style];
    [self setPhoneNumber:self.phone];
}

#pragma mark - public

- (void)show {
    self.window.hidden = NO;
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)hide {
    self.window.hidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)showMicrophonePrivacy:(BOOL)isTerminated {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"APP needs access to your phone's microphone" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (isTerminated) {
            self.call = nil;
            [self hide];
        } else {
            [self.call hangUpCall];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        if (isTerminated) {
            self.call = nil;
            [self hide];
        } else {
            [self.call hangUpCall];
        }
    }]];
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)setName:(NSString *)name {
    [self.lblName setText:name];
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phone = phoneNumber;
    [self.lblPhoneNumber setText:phoneNumber];
}

- (void)setCallState:(NSString *)callState {
    [self.lblDuration setText:callState];
}

- (IBAction)acceptAction:(id)sender {
    if (self.call) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){
            if (granted) {
                [self.call acceptCall];
            } else {
                [self showMicrophonePrivacy:NO];
            }
        }];
    };
}

- (IBAction)hangUpAction:(id)sender {
    if (self.call) {
        [self.call hangUpCall];
    }
    [self hide];
}

- (void)setViewStyle:(CallViewStyle)style {
    _style = style;
    if (style ==     CallViewStyleIncoming) {
        self.btnAccept.hidden = NO;
        [self setCallState:@""];
    } else if (style ==     CallViewStyleConnected) {
        self.btnAccept.hidden = YES;
    } else if (style ==     CallViewStyleOutgoing) {
        [self setCallState:@""];
        self.lblDuration.text = @"dialing...";
        self.btnAccept.hidden = YES;
    }
}

- (IBAction)optionAction:(id)sender {
    
    if (!self.call) {
        return;
    };
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    BOOL isMute = [self.call isCallMuted];
    [alert addAction:[UIAlertAction actionWithTitle:isMute ? @"UnMute" : @"Mute" style:isMute ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.call setCallMuted:!isMute];
    }]];
    
    BOOL isSpeaker = ([self.call getCurrentAudioRoute] == LTAudioRouteSpeaker);
    [alert addAction:[UIAlertAction actionWithTitle:@"Speaker" style:isSpeaker ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.call setAudioRoute:isSpeaker ? LTAudioRouteBuiltin : LTAudioRouteSpeaker];
    }]];
    
    BOOL isHeld = [self.call isCallHeld];
    [alert addAction:[UIAlertAction actionWithTitle:isHeld ? @"UnHold ":@"Hold" style:isHeld ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.call setCallHeld:!isHeld];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)hiddenAction:(id)sender {
    self.window.hidden = YES;
}

#pragma mark - SDKManagerDelegate

- (void)SDKManagerStartOutgoingCall:(LTCall *)call {
    if (!self.call) {
        _call = call;
    }
}

- (void)SDKManagerReceiveImcomingCall:(LTCall *)call {
    if (!self.call) {
        _call = call;
        if (call.options.phoneNumber.length > 0) {
            [self setPhoneNumber:call.options.phoneNumber];
        } else if (call.options.semiUID.length > 0) {
            [self setPhoneNumber:call.options.semiUID];
        } else if (call.options.userID.length > 0) {
            [self setPhoneNumber:call.options.userID];
        }
    }
}

- (LTCall *)getVoiceCall {
    return self.call;
}

#pragma mark - LTCallDelegate

- (void)LTCallStateRegistered:(LTCall *_Nonnull)call {
    if (call == self.call) {
    }
}

- (void)LTCallStateConnected:(LTCall *_Nonnull)call {
    if (call == self.call) {
        [self setViewStyle: CallViewStyleConnected];
        [self show];
    }
}

- (void)LTCallStateWarning:(LTCall *_Nonnull)call statusCode:(LTCallStatusCode)statusCode {
    NSLog(@"Warning:%ld",statusCode);
    if (statusCode == LTCallStatusCodeNoRecordPermission) {
        [self setViewStyle: CallViewStyleIncoming];
        [self show];
        [self showMicrophonePrivacy:NO];
    }
}

- (void)LTCallStateTerminated:(LTCall *_Nullable)call statusCode:(LTCallStatusCode)statusCode {
    NSLog(@"Terminated:%ld",statusCode);
    if (statusCode == LTCallStatusCodeNoRecordPermission) {
        [self showMicrophonePrivacy:YES];
    } else  if (call == self.call) {
        if (statusCode == LTCallStatusCodeMiss) {
            NSLog(@"Miss:%ld",statusCode);
        }
        _call = nil;
        [self hide];
    }
}

- (void)LTCallMediaStateChanged:(LTCall *_Nonnull)call mediaType:(LTMediaType)mediaType {
    if (call == self.call) {
        if (mediaType == LTMediaTypeAudioRoute) {
            NSLog(@"LTCallMediaStateChanged:%ld", (long)[call getCurrentAudioRoute]);
        } else if (mediaType == LTMediaTypeCallMuted) {
            NSLog(@"LTCallMediaStateChanged:%d", [call isCallMuted]);
        } else if (mediaType == LTMediaTypeCallHeld) {
            NSLog(@"LTCallMediaStateChanged:%d", [call isCallHeld]);
        }
    }
}

- (void)LTCallConnectDuration:(LTCall *_Nonnull)call duration:(long)duration {
    if (call == self.call) {
        int sec = duration % 60;
        int min = (int)(duration / 60);
        self.lblDuration.text = [NSString stringWithFormat:@"%02i:%02i",min / 60 , sec];
    }
}

@end

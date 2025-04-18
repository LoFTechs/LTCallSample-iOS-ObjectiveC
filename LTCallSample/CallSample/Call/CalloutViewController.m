//
//  CalloutViewController.m
//  CallSample
//
//  Created by LoFTech on 2018/10/17.
//  Copyright © 2018 LoFTech. All rights reserved.
//

#import "CalloutViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UserInfo.h"
#import "SDKManager.h"
#import "CallViewController.h"

typedef NS_ENUM(NSInteger, CalleeType) {
    CalleeTypePhoneNumber,
    CalleeTypeSemiUID,
    CalleeTypeUserID
};

@interface CalloutViewController ()
@property (strong, nonatomic) IBOutlet UITextView *txtPhone;
@property (strong, nonatomic) IBOutlet UILabel *lblDeviceID;
@property (strong, nonatomic) IBOutlet UITextView *tvLog;
@property (assign, nonatomic) CalleeType calleeType;

@end
@implementation CalloutViewController
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (IBAction)callOutAction:(id)sender {
    if (self.txtPhone.text.length > 0) {
        NSArray *phones = [self.txtPhone.text componentsSeparatedByString:@"\n"];
        NSMutableArray *accountArray = [[NSMutableArray alloc] init];
        [phones enumerateObjectsUsingBlock:^(NSString * _Nonnull phone, NSUInteger idx, BOOL * _Nonnull stop) {
            if (phone.length > 0 && ![accountArray containsObject:phone]) {
                [accountArray addObject:phone];
            }
        }];
        
        CallViewController *vc = [CallViewController sharedInstance];
        [vc setViewStyle:CallViewStyleOutgoing];
        [vc setPhoneNumber:[accountArray componentsJoinedByString:@","]];
        [vc show];
        
        LTCallOptions *options = nil;
        if (accountArray.count > 1) {//Group Call
            options = [LTCallOptions initWithGroupCallPhoneNumberBuilder:^(LTGroupCallBuilder *builder) {
                builder.groupCallMembers = accountArray;
            }];
            
            [[SDKManager sharedInstance] startGroupCallWithOptions:options];
            
        } else {
            NSString *account = [accountArray lastObject];
            if (self.calleeType == CalleeTypeSemiUID) {
                options = [LTCallOptions initWithSemiUIDBuilder:^(LTCallSemiUIDBuilder *builder)  {
                    builder.semiUID = account;
                }];
            } else if (self.calleeType == CalleeTypeUserID) {
                options = [LTCallOptions initWithUserIDBuilder:^(LTCallUserIDBuilder *builder) {
                    builder.userID = account;
                }];
            } else {
                options = [LTCallOptions initWithPhoneNumberBuilder:^(LTCallPhoneNumberBuilder *builder)  {
                    builder.phoneNumber = account;
//                    builder.isrCode = @""; //for saving call
                }];
            }
            
            [[SDKManager sharedInstance] startCallWithOptions:options account:account];
        }
        
    }
}

- (IBAction)refreshTokenAction:(id)sender {
    SDKManager *manager = [SDKManager sharedInstance];
    self.tvLog.text = @"Update Token...";
    [manager uploadNotificationKey:^(NSString * _Nonnull returnMsg) {
        self.tvLog.text = returnMsg;
    }];
}

- (IBAction)changeAccountTypeAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"PhoneNumber" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [btn setTitle:@"PhoneNumber" forState:UIControlStateNormal];
        self.txtPhone.text = @"";
        self.txtPhone.keyboardType = UIKeyboardTypePhonePad;
        self.calleeType = CalleeTypePhoneNumber;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"SemiUID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [btn setTitle:@"SemiUID" forState:UIControlStateNormal];
        self.txtPhone.text = @"";
        self.txtPhone.keyboardType = UIKeyboardTypeDefault;
        self.calleeType = CalleeTypeSemiUID;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"UserID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [btn setTitle:@"UserID" forState:UIControlStateNormal];
        self.txtPhone.text = @"";
        self.txtPhone.keyboardType = UIKeyboardTypeDefault;
        self.calleeType = CalleeTypeUserID;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)getUserStatus:(id)sender {
    
    if (self.txtPhone.text.length == 0) {
        self.tvLog.text = @"Please input phonenumber..";
        return;
    }
    
    NSArray *phones = [self.txtPhone.text componentsSeparatedByString:@"\n"];
    NSString *phone = phones.lastObject;
    if (phone.length == 0) {
        if (self.calleeType == CalleeTypePhoneNumber) {
            self.tvLog.text = @"Please input callee phoneNumber..";
        } else if (self.calleeType == CalleeTypeSemiUID) {
            self.tvLog.text = @"Please input callee semiUID..";
        } else if (self.calleeType == CalleeTypeUserID) {
            self.tvLog.text = @"Please input callee userID..";
        }
        return;
    }
    
    SDKManager *manager = [SDKManager sharedInstance];
    self.tvLog.text = @"getUserStatus...";
    
    if (self.calleeType == CalleeTypePhoneNumber) {
        [manager getUserStatusWithPhone:phone completion:^(NSString * _Nonnull returnMsg) {
            self.tvLog.text = returnMsg;
        }];
    } else if (self.calleeType == CalleeTypeSemiUID) {
        [manager getUserStatusWithSemiUID:phone completion:^(NSString * _Nonnull returnMsg) {
            self.tvLog.text = returnMsg;
        }];
    } else {
        self.tvLog.text = @"Only phoneNumber or semiUID can getUserStatus.";
    }
}

- (IBAction)addGroupCall:(id)sender {
    if (self.txtPhone.text.length == 0) {
        self.tvLog.text = @"Please input phonenumber..";
        return;
    }
    self.txtPhone.text = [NSString stringWithFormat:@"%@\n",self.txtPhone.text];
    [self.txtPhone becomeFirstResponder];
}

- (IBAction)queryCDR:(id)sender {
    SDKManager *manager = [SDKManager sharedInstance];
    self.tvLog.text = @"queryCDR...";
    [manager queryCDR:^(NSString * _Nonnull returnMsg) {
        self.tvLog.text = returnMsg;
    }];
}

- (void)hideKeyboard {
    [self.txtPhone resignFirstResponder];
}

@end

//
//  ViewController.h
//  extraSlice
//
//  Created by Administrator on 19/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *errorText;
@property (weak, nonatomic) IBOutlet UIView *errorLyt;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIImageView *rememberMe;
@property (weak, nonatomic) IBOutlet UILabel *signUp;

@property (weak, nonatomic) IBOutlet UILabel *guestSignup;

@property (weak, nonatomic) IBOutlet UILabel *forgotPwd;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorLytHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorImageHeight;



- (IBAction)verifyAndLogin:(id)sender;
@end


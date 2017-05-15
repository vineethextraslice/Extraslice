//
//  ViewController.h
//  WalkNPay
//
//  Created by Irshad on 11/17/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WnPUserModel.h"
#import "WnPUtilities.h"
#import <CoreLocation/CoreLocation.h>

@interface LoginViewController : UIViewController<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailValue;
@property (weak, nonatomic) IBOutlet UITextField *passwordValue;
@property(strong,nonatomic) WnPUserModel *userModel;
- (IBAction)validateAndLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *forgotPwd;
@property (weak, nonatomic) IBOutlet UILabel *signup;
@property (weak, nonatomic) IBOutlet UIView *errorLyt;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property(strong,nonatomic) WnPUtilities *utils;

@property (weak, nonatomic) IBOutlet UIButton *vLogin;
@property (weak, nonatomic) IBOutlet UIButton *vCancel;
@property (weak, nonatomic) IBOutlet UITextField *vVerifCode;
@property (weak, nonatomic) IBOutlet UITextField *vPassword;
@property (weak, nonatomic) IBOutlet UITextField *vEmail;
@property (weak, nonatomic) IBOutlet UIView *vErrorLyt;
@property (weak, nonatomic) IBOutlet UIImageView *vErrorImg;
@property (weak, nonatomic) IBOutlet UILabel *vErrorMsg;

- (IBAction)LoginWithVerificationCode:(id)sender;
- (IBAction)cancelLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *vResendvCode;
@property (weak, nonatomic) IBOutlet UIImageView *remmbMe;
@property (weak, nonatomic) IBOutlet UIView *remView;
@property (weak, nonatomic) IBOutlet UILabel *orText;
@property(strong,nonatomic)CLLocationManager *locationManager;

@end


//
//  GustSignupViewController.h
//  extraSlice
//
//  Created by Administrator on 10/01/17.
//  Copyright © 2017 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuestSignup : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *back;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confPassword;
@property (weak, nonatomic) IBOutlet UILabel *tcText;
@property (weak, nonatomic) IBOutlet UIImageView *tcChBox;
@property (weak, nonatomic) IBOutlet UIButton *signup;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
- (IBAction)signupAsGuest:(id)sender;
- (IBAction)cancelSignup:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *errorimg;

@property (weak, nonatomic) IBOutlet UIView *errorLyt;
@property (weak, nonatomic) IBOutlet UILabel *errorText;
@property (weak, nonatomic) IBOutlet UILabel *header;

@end

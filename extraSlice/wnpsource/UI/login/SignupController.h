//
//  SignupController.h
//  WalkNPay
//
//  Created by Irshad on 12/8/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WnPUtilities.h"

@interface SignupController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UIImageView *errorImage;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confPassword;
- (IBAction)signUp:(id)sender;
- (IBAction)cancelSignup:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *tcLabel;
@property(strong, nonatomic) WnPUtilities *utils;
@property (weak, nonatomic) IBOutlet UIImageView *tcCheckbox;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *signupBtn;
@end

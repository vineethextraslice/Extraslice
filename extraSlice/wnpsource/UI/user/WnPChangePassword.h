//
//  ChangePassword.h
//  walkNPay
//
//  Created by Administrator on 28/01/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WnPUserModel.h"

@interface WnPChangePassword : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *currPwd;
@property (weak, nonatomic) IBOutlet UITextField *nPassword;
@property (weak, nonatomic) IBOutlet UITextField *confPwd;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
- (IBAction)cancelPopup:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
- (IBAction)sumbitChange:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIView *errorView;

@property(strong,nonatomic) WnPUserModel *userModel;
@end

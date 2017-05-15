//
//  ForgotPwd.h
//  WalkNPay
//
//  Created by Administrator on 14/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPwd : UIViewController
@property (weak, nonatomic) IBOutlet UIView *errorLyt;
@property (weak, nonatomic) IBOutlet UIImageView *errorImg;
@property (weak, nonatomic) IBOutlet UILabel *errorText;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
- (IBAction)cancelAction:(id)sender;
- (IBAction)submitAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

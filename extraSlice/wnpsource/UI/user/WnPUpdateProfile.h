//
//  UpdateProfile.h
//  walkNPay
//
//  Created by Administrator on 28/01/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WnPUserModel.h"

@interface WnPUpdateProfile : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *sumbitBtn;
- (IBAction)submitChanges:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
- (IBAction)cancelPopup:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *addr1;
@property (weak, nonatomic) IBOutlet UITextField *addr2;
@property (weak, nonatomic) IBOutlet UITextField *addr3;
@property (weak, nonatomic) IBOutlet UITextField *state;
@property (weak, nonatomic) IBOutlet UITextField *zip;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property(strong,nonatomic) WnPUserModel *userModel;

@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;


@end

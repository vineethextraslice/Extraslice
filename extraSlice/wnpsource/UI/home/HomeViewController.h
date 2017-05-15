//
//  HomeViewController.h
//  WalkNPay
//
//  Created by Irshad on 11/17/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuController.h"


@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *outerBoarder;
@property (weak, nonatomic) IBOutlet UIView *containerView;


@property (strong, nonatomic) IBOutlet UIView *inner11;
@property (strong, nonatomic) IBOutlet UIView *inner20;
@property (strong, nonatomic) IBOutlet UIView *inner21;
@property (strong, nonatomic) IBOutlet UIView *inner22;
@property (strong, nonatomic) IBOutlet UIView *inner31;


@property (strong, nonatomic) IBOutlet UIImageView *store;
@property (strong, nonatomic) IBOutlet UIImageView *scan;
@property (strong, nonatomic) IBOutlet UIImageView *cart1;
@property (strong, nonatomic) IBOutlet UIImageView *cart2;
@property (strong, nonatomic) IBOutlet UIImageView *checkout;


@property (weak, nonatomic) IBOutlet UILabel *count;
@property(nonatomic) NSNumber *totalAmount;
@property(nonatomic) BOOL resetPwd;
@property (weak, nonatomic) IBOutlet UIView *resetPwdPopup;
@property (weak, nonatomic) IBOutlet UITextField *resetNewPwd;
@property (weak, nonatomic) IBOutlet UITextField *resetConfPwd;
@property (weak, nonatomic) IBOutlet UIButton *resetPwdSubmit;


@property (strong, nonatomic) IBOutlet UILabel *storeTxt;
@property (strong, nonatomic) IBOutlet UILabel *scanTxt;
@property (strong, nonatomic) IBOutlet UILabel *cart1Txt;
@property (strong, nonatomic) IBOutlet UILabel *cart2Txt;
@property (strong, nonatomic) IBOutlet UILabel *checkoutTxt;


@end

//
//  ParentViewController.h
//  WalkNPay
//
//  Created by Irshad on 11/24/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionModel.h"
#import "StoreModel.h"
static  NSString *viewName;
@interface ParentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *homeImage;


@property (weak, nonatomic) UIStoryboard *stryBrd;
@property (strong, nonatomic) IBOutlet UIView *cotView;

- (void)loadViewData:(id)sender;
@property(nonatomic) Boolean *paymentStatus;
@property (weak,nonatomic)NSNumber *totalAmount;
@property (weak,nonatomic)NSNumber *payableAmount;
@property(nonatomic) BOOL loadScanpopup;
@property(nonatomic) BOOL status;
@property(nonatomic) BOOL resetPwd;
@property(weak,nonatomic) NSString *errorMessage;
@property(strong,nonatomic) StoreModel *storeModel;
@property(weak,nonatomic) TransactionModel *reciept;
-(void )setViewName:(NSString *) newView;
-(void)changeOrientation:(NSNotification *)note;
@end

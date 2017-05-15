//
//  CouponPopup.h
//  WalkNPay
//
//  Created by Administrator on 14/01/16.
//  Copyright © 2016 Extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponPopup : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *couponTable;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property(strong,nonatomic) NSNumber *totalAmount;
- (IBAction)cancelPopup:(id)sender;

- (IBAction)addAppliedCoupons:(id)sender;


@end

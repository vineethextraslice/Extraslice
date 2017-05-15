//
//  MyCards.h
//  walkNPay
//
//  Created by Administrator on 03/02/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StripePaymentViewController;

@protocol StripePaymentViewControllerDelegate<NSObject>

- (void)stripePaymentViewController:(StripePaymentViewController *)controller didFinish:(NSError *)error;

@end
@interface MyCards : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardTableHt;
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;
@property (weak, nonatomic) IBOutlet UILabel *rechargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UIView *seperator1;
@property (weak, nonatomic) IBOutlet UIView *seperator2;
@property (weak, nonatomic) IBOutlet UIView *seperator3;
@property (weak, nonatomic) IBOutlet UITableView *cardTable;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UILabel *prepaidHeader;

@property (weak, nonatomic) IBOutlet UIImageView *addNewCard;
@property (weak, nonatomic) IBOutlet UILabel *addSubsLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardHeader;

@end

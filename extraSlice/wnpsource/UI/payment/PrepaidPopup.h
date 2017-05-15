//
//  PrepaidPopup.h
//  WalkNPay
//
//  Created by Administrator on 23/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"
#import "STPPaymentCardTextField.h"
#import "STPAPIClient.h"
#import "Stripe.h"
@class PaymentViewController;

@protocol PaymentViewControllerDelegate<NSObject>

- (void)paymentViewController:(PaymentViewController *)controller didFinish:(NSError *)error;

@end
@interface PrepaidPopup : UIViewController<PayPalPaymentDelegate,STPPaymentCardTextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)cancelPrepaid:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIImageView *customRadio;
@property (weak, nonatomic) IBOutlet UILabel *customLabel;
@property (weak, nonatomic) IBOutlet UIImageView *couponRadio;
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UITextField *amountText;
@property (weak, nonatomic) IBOutlet UIImageView *strpBtn;
@property (weak, nonatomic) IBOutlet UIImageView *paypalBtn;
@property (weak, nonatomic) IBOutlet UIView *couponView;
@property (weak, nonatomic) IBOutlet UITableView *couponTable;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UILabel *totalPayableAmt;
@property (weak, nonatomic) IBOutlet UILabel *totalUsabeleAmt;
@property (weak, nonatomic) IBOutlet UILabel *minimumAmtLabel;

@property (nonatomic, weak) id<PaymentViewControllerDelegate> delegate;

- (IBAction)submitOnClick:(id)sender;

@property(strong,nonatomic) NSString *strpPubKey;
@property(strong,nonatomic) NSString *paypalEnv;
@property(strong,nonatomic) NSString *paypalClientId;
@property(strong,nonatomic) NSString *currencyCode;
@property(strong,nonatomic) NSNumber *custRechMinAmt;


@end

//
//  PaymentGateway.h
//  WalkNPay
//
//  Created by Irshad on 11/24/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"
#import "PrepaidPopup.h"
#import "STPAPIClient.h"
#import "Stripe.h"
#import "CouponModel.h"
#import "ProductModel.h"


@class StripePaymentViewController;

@protocol StripePaymentViewControllerDelegate<NSObject>

- (void)stripePaymentViewController:(StripePaymentViewController *)controller didFinish:(NSError *)error;

@end
static NSNumber *totalAmountForOffer;
static NSMutableArray *offerCoupons;
static NSMutableArray *selectedCoupons;
static NSNumber *offerAmount;
@interface PaymentGateway : UIViewController<PayPalPaymentDelegate>


@property (weak, nonatomic) IBOutlet UILabel *totalAmountTv;
@property (weak, nonatomic) IBOutlet UILabel *selectpayment;
@property (weak, nonatomic) IBOutlet UIView *couponLyt;
@property (weak, nonatomic) IBOutlet UIView *payableLyt;
@property (weak, nonatomic) IBOutlet UIView *prepaidAppliedLyt;

@property (weak, nonatomic) IBOutlet UIView *balanceLyt;
@property (weak, nonatomic) IBOutlet UIImageView *payWithStrp;
@property (weak, nonatomic) IBOutlet UILabel *showCpnDetl;
@property (weak, nonatomic) IBOutlet UIImageView *payWithPaypal;
@property (weak, nonatomic) IBOutlet UIImageView *payWithPrepaid;
@property (weak, nonatomic) IBOutlet UIView *prepaifPGLyt;
@property (weak, nonatomic) IBOutlet UIView *strpPGLyt;
@property (weak, nonatomic) IBOutlet UIView *paypalPGLyt;
@property (weak, nonatomic) IBOutlet UIView *checkoutLyt;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkouBtn;
@property (weak, nonatomic) IBOutlet UIView *seperator;
@property (weak, nonatomic) IBOutlet UILabel *prepaidChkText;
@property (weak, nonatomic) IBOutlet UILabel *balancePayableLabel;
@property (weak, nonatomic) IBOutlet UILabel *preapidAppliedLabel;
@property (weak, nonatomic) IBOutlet UILabel *offerAppliedAmtTV;
@property (weak, nonatomic) IBOutlet UILabel *rechargeLink;

@property (nonatomic, weak) id<StripePaymentViewControllerDelegate> delegate;

@property(strong,nonatomic) NSString *selectedPayMethod;

@property(nonatomic) NSNumber *prepaidBalance;
@property(nonatomic) NSNumber *prepaidApplied;
@property(nonatomic) NSNumber *payableBalance;
@property(nonatomic)NSNumber *totalAmount;


@property(nonatomic) BOOL prepaidChecked;
@property (weak, nonatomic) IBOutlet UIView *errorView;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;




- (IBAction)submitStripePayment:(id)sender;
- (IBAction)cancelStripePayment:(id)sender;
- (IBAction)cancelCheckout:(id)sender;
- (IBAction)checkoutCart:(id)sender;

- (void)setTotalAmtForOffer:(NSNumber *)total;
- (NSNumber *)getTotalAmtForOffer;
- (NSMutableArray *)getOfferCoupons;
- (void)setOfferCoupons:(NSMutableArray *)offerCpns;
- (NSMutableArray *)getSelectedCoupons;
- (void)setSelectedCoupons:(NSMutableArray *)slctedCoupons;
- (void)addSelectedCoupon:(NSDictionary *)cpn;
- (void)removeAllSelectedCoupon;
- (NSDictionary *)getOfferCouponAt:(NSInteger *)index;
- (NSNumber *)getOfferAmount;
- (void)setOfferAmount:(NSNumber *)offrAmt;

- (void)setTotalAmountForOffer:(NSNumber *)amt;
- (NSNumber *)getTotalAmountForOffer;
@end

//
//  PaymentGateway.m
//  WalkNPay
//
//  Created by Irshad on 11/24/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "PaymentGateway.h"
#import "MenuController.h"
#import "TransactionModel.h"
#import "WnPConstants.h"
#import "WnPWebServiceDAO.h"
#import "PayPalMobile.h"
#import "PayPalPaymentViewController.h"
#import "TransactionDAO.h"
#import "StoreModel.h"
#import "StoreDAO.h"
#import "PrepaidPopup.h"
#import "WnPUtilities.h"
#import "NSString+AESCrypt.h"
#import "PrepaidPopup.h"
#import "StripeDAO.h"
#import "CouponDAO.h"
#import "CouponPopup.h"
#import "DealerDAO.h"
#import "DealerModel.h"



@interface PaymentGateway ()<STPPaymentCardTextFieldDelegate>
@property (weak,nonatomic) NSString *resultText;
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property(strong,nonatomic) TransactionModel *resultModel;
@property(strong,nonatomic) TransactionDAO *trxnDAO;
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(strong,nonatomic) StoreModel *selStrMdl;
@property(strong,nonatomic) StoreDAO *storeDAO;
@property(strong,nonatomic) UIView *prepaidPopuView;

@property(nonatomic) BOOL preRec_customSelected;
@property(nonatomic) BOOL preRec_strpSelected;
@property (weak,nonatomic) NSString *paymentFor;
@property(strong,nonatomic) STPPaymentCardTextField *strpPymntTf;
@property (strong, nonatomic) UIButton *strpSubmitBtn;
@property (strong, nonatomic) UIButton *strpCancelBtn;
@property(strong,nonatomic) WnPUtilities *utils ;
@property(strong,nonatomic) NSMutableArray *allCoupons;

@property(strong,nonatomic) CouponDAO *couponDao;
@property(strong,nonatomic) CouponModel *defCoupon;
@property(strong,nonatomic) StripeDAO *strpDAO;

@property(strong,nonatomic) NSNumberFormatter *formatter;
@property(strong,nonatomic) UIView *topLayer;

@end

@implementation PaymentGateway

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trxnDAO = [[TransactionDAO alloc]init];
    self.wnpCont = [[WnPConstants alloc]init];
    self.storeDAO = [[StoreDAO alloc]init];
    self.utils = [[WnPUtilities alloc]init];
    self.couponDao=[[CouponDAO alloc]init];
    self.strpDAO=[[StripeDAO alloc]init];
    self.checkouBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.cancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.seperator.backgroundColor=[self.wnpCont getThemeBaseColor];
    
    self.formatter= [[NSNumberFormatter alloc] init];
    [self.formatter setPositiveFormat:@"0.##"];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.rechargeLink.attributedText = [[NSAttributedString alloc] initWithString:@"Recharge" attributes:underlineAttribute];
    
    NSDictionary *showCpnUrl = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.showCpnDetl.attributedText = [[NSAttributedString alloc] initWithString:@"Show" attributes:showCpnUrl];
    
    
    self.rechargeLink.textColor=[self.wnpCont getThemeBaseColor];
    self.showCpnDetl.textColor=[self.wnpCont getThemeBaseColor];

    totalAmountForOffer=self.totalAmount;
    offerAmount=nil;
    selectedCoupons=nil;
    offerAmount = [NSNumber numberWithInt:0];
    offerCoupons = [[NSMutableArray alloc]init];
    selectedCoupons = [[NSMutableArray alloc]init];
    for(ProductModel *prdMdl in [self.wnpCont getItemsFromArray]){
        prdMdl.offerAppliedAmt=[NSNumber numberWithDouble:0];
        prdMdl.offerAppliedQty=[NSNumber numberWithInt:0];
    }
    
    @try {
        self.selStrMdl = [self.storeDAO getStoreById:[self.wnpCont getSelectedStoreId]];
        self.allCoupons = [self.couponDao getAllCouponsForPurchase:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId]];
        for(CouponModel *cpn in self.allCoupons){
            if([cpn.couponType isEqualToString:@"prepaid"]){
                self.defCoupon=cpn;
            }else{
                [cpn calcualteOfferAmount:FALSE reallocate:FALSE];
                [offerCoupons addObject:cpn];
            }
        }
        for(CouponModel *cpn in offerCoupons){
            if([cpn.applyBy isEqualToString:@"DEFAULT"]){
                [cpn calcualteOfferAmount:TRUE reallocate:FALSE];
                if(cpn.recalculatedOfferedAmount.doubleValue>0){
                    [selectedCoupons addObject:cpn];
                    offerAmount=[NSNumber numberWithDouble:(offerAmount.doubleValue+cpn.recalculatedOfferedAmount.doubleValue)];
                }
            }
        }
        UITapGestureRecognizer *rechargeURL = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showrechargePopup)];
        rechargeURL.numberOfTapsRequired = 1;
        rechargeURL.numberOfTouchesRequired = 1;
        [self.rechargeLink setUserInteractionEnabled:YES];
        [self.rechargeLink addGestureRecognizer:rechargeURL];
        
        UITapGestureRecognizer *showCpn = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showCouponView)];
        showCpn.numberOfTapsRequired = 1;
        showCpn.numberOfTouchesRequired = 1;
        [self.showCpnDetl setUserInteractionEnabled:YES];
        [self.showCpnDetl addGestureRecognizer:showCpn];
        if (offerCoupons.count <=0) {
            self.couponLyt.hidden=true;
        }
    }
    @catch (NSException *exception) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
        self.checkouBtn.userInteractionEnabled=false;
        self.couponLyt.hidden=true;
    }
    
    
    
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyCoupons) name:@"applyCoupons" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCouponPopup) name:@"cancelCoupons" object:nil];
    // [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectpayment attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.payableLyt attribute: NSLayoutAttributeBottom multiplier:1 constant:30]];
    // [self.couponTable dequeueReusableCellWithIdentifier:@"header"];
    
    
    
    self.totalAmountTv.text = [NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:self.totalAmount]];
    @try {
        self.prepaidBalance = [self.couponDao getPrepaidBalance:[self.wnpCont getUserId]];
    }@catch (NSException *exception) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
    if(self.prepaidBalance.doubleValue <= 0){
        self.payWithPrepaid.userInteractionEnabled = NO;
        [self.payWithPrepaid setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        self.prepaidChecked =NO;
        //self.prepaifPGLyt.hidden=TRUE;
        self.prepaidApplied = [NSNumber numberWithInt:0];
        //[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.strpPGLyt attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.prepaifPGLyt attribute:NSLayoutAttributeBottom multiplier:1 constant:25]];
        //self.prepaidAppliedLyt.hidden=TRUE;
        //self.balanceLyt.hidden=TRUE;
    }else{
        self.prepaidChecked =TRUE;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectPaymentGateway:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [self.payWithPrepaid setUserInteractionEnabled:YES];
        [self.payWithPrepaid addGestureRecognizer:singleTap];
        //self.prepaidAppliedLyt.hidden=FALSE;
        //self.balanceLyt.hidden=FALSE;
        
        
        if(self.prepaidBalance.doubleValue >= (self.totalAmount.doubleValue - offerAmount.doubleValue)){
            self.prepaidApplied= [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue)];
        }else{
            self.prepaidApplied = self.prepaidBalance;
            self.payableBalance = [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue-self.prepaidApplied.doubleValue)] ;
            if(self.payableBalance.doubleValue < 0.5){
                self.prepaidApplied = [NSNumber numberWithDouble:self.prepaidApplied.doubleValue-(0.5-self.payableBalance.doubleValue)];
                
            }

        }
        if(self.prepaidApplied.doubleValue < 0){
            self.prepaidApplied = [NSNumber numberWithInt:0];
        }
    }
    
    self.payableBalance = [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue-self.prepaidApplied.doubleValue)] ;
    if(self.payableBalance.doubleValue <= 0){
        self.payableBalance = [NSNumber numberWithInt:0];
    }
    self.preapidAppliedLabel.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:self.prepaidApplied]];
    self.balancePayableLabel.text =[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:self.payableBalance]];

    
    self.selectedPayMethod=@"Stripe";
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectPaymentGateway:)];
    singleTap1.numberOfTapsRequired = 1;
    singleTap1.numberOfTouchesRequired = 1;
    [self.payWithStrp setUserInteractionEnabled:YES];
    [self.payWithStrp addGestureRecognizer:singleTap1];
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectPaymentGateway:)];
    singleTap2.numberOfTapsRequired = 1;
    singleTap2.numberOfTouchesRequired = 1;
    [self.payWithPaypal setUserInteractionEnabled:YES];
    [self.payWithPaypal addGestureRecognizer:singleTap2];
    
    if(self.totalAmount.doubleValue <= self.prepaidBalance.doubleValue){
        self.selectpayment.hidden=true;
        self.seperator.hidden=true;
        NSMutableString *preapidStr = [NSMutableString stringWithFormat:@"Prepaid (Availabel %@",[self.wnpCont getCurrencySymbol]];
        NSNumber *prebal = [NSNumber numberWithDouble:(self.prepaidBalance.doubleValue-self.prepaidApplied.doubleValue)];
        [preapidStr appendString:[self.formatter stringFromNumber:[NSNumber numberWithDouble:prebal.doubleValue]]];
        [preapidStr appendString:@")"];
        self.prepaidChkText.text=preapidStr;
    }else{
        self.selectpayment.hidden=false;
        
        NSMutableString *preapidStr = [NSMutableString stringWithFormat:@"Pay balancel %@",[self.wnpCont getCurrencySymbol]];
        [preapidStr appendString:[self.formatter stringFromNumber:[NSNumber numberWithDouble:self.payableBalance.doubleValue]]];
        [preapidStr appendString:@" using"];
        self.selectpayment.text=preapidStr;
        self.prepaidChkText.text=[NSString stringWithFormat:@"Prepaid (Availabel %@0.00)",[self.wnpCont getCurrencySymbol]];

    }
    
    
    
    if(self.payableBalance.doubleValue <= 0){
        self.selectedPayMethod=@"Prepaid";
        self.strpPGLyt.hidden =TRUE;
        self.paypalPGLyt.hidden=TRUE;
    }else{
        self.strpPGLyt.hidden =FALSE;
        self.paypalPGLyt.hidden=FALSE;
    }
  
    self.offerAppliedAmtTV.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:offerAmount]];

}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



-(void)selectPaymentGateway:(UIGestureRecognizer *)recognizer {
    int id= (int)recognizer.view.tag;
    if(id == 0){
        //prepaid
        if(self.prepaidChecked){
            self.prepaidApplied = [NSNumber numberWithInt:0];
            [self.payWithPrepaid setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
            self.prepaidChecked = NO;
            self.selectedPayMethod=@"Stripe";
            if(self.payableBalance.doubleValue <=0){
                // self.selectedPayMethod=@"Prepaid";
                self.strpPGLyt.hidden=TRUE;
                self.paypalPGLyt.hidden=TRUE;
                
                // [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.checkoutLyt attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.prepaifPGLyt attribute:NSLayoutAttributeBottom multiplier:1 constant:50]];
            }else{
                self.strpPGLyt.hidden=FALSE;
                self.paypalPGLyt.hidden=FALSE;
            }
            NSMutableString *preapidStr = [NSMutableString stringWithFormat:@"Prepaid (Availabel %@",[self.wnpCont getCurrencySymbol]];
            [preapidStr appendString:[self.formatter stringFromNumber:[NSNumber numberWithDouble:self.prepaidBalance.doubleValue]]];
            [preapidStr appendString:@")"];
            self.prepaidChkText.text=preapidStr;
            
            
        }else{
            if(self.prepaidBalance.doubleValue >= (self.totalAmount.doubleValue - offerAmount.doubleValue)){
                self.prepaidApplied= [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue)];
            }else{
                self.prepaidApplied = self.prepaidBalance;
                self.payableBalance = [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue-self.prepaidApplied.doubleValue)] ;
                if(self.payableBalance.doubleValue < 0.5){
                    self.prepaidApplied = [NSNumber numberWithDouble:self.prepaidApplied.doubleValue-(0.5-self.payableBalance.doubleValue)];
                    
                }

            }
            if(self.prepaidApplied.doubleValue < 0){
                self.prepaidApplied = [NSNumber numberWithInt:0];
            }
            [self.payWithPrepaid setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
            self.payableBalance = [NSNumber numberWithDouble:(self.totalAmount.doubleValue-self.prepaidBalance.doubleValue)];
            self.prepaidChecked = YES;
            if(self.payableBalance.doubleValue <=0){
                self.selectedPayMethod=@"Prepaid";
                self.strpPGLyt.hidden=TRUE;
                self.paypalPGLyt.hidden=TRUE;
                
                // [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.checkoutLyt attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.prepaifPGLyt attribute:NSLayoutAttributeBottom multiplier:1 constant:50]];
            }else{
                self.strpPGLyt.hidden=FALSE;
                self.paypalPGLyt.hidden=FALSE;
                self.selectedPayMethod=@"Stripe";
            }
            NSMutableString *preapidStr = [NSMutableString stringWithFormat:@"Prepaid (Availabel %@",[self.wnpCont getCurrencySymbol]];
            NSNumber *prebal = [NSNumber numberWithDouble:(self.prepaidBalance.doubleValue-self.prepaidApplied.doubleValue)];
            [preapidStr appendString:[self.formatter stringFromNumber:[NSNumber numberWithDouble:prebal.doubleValue]]];
            [preapidStr appendString:@")"];
            self.prepaidChkText.text=preapidStr;
            
        }
        self.payableBalance = [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue-self.prepaidApplied.doubleValue)] ;
        if(self.payableBalance.doubleValue <= 0){
            self.payableBalance = [NSNumber numberWithInt:0];
        }
        
        self.preapidAppliedLabel.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:self.prepaidApplied]];
        self.balancePayableLabel.text =[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:self.payableBalance]];

        NSMutableString *payStr = [NSMutableString stringWithFormat:@"Pay balancel %@",[self.wnpCont getCurrencySymbol]];
        [payStr appendString:[self.formatter stringFromNumber:[NSNumber numberWithDouble:self.payableBalance.doubleValue]]];
        [payStr appendString:@" using"];
        self.selectpayment.text=payStr;
     self.offerAppliedAmtTV.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:offerAmount]];

        if(self.payableBalance.doubleValue <= 0){
            self.selectedPayMethod=@"Prepaid";
            self.strpPGLyt.hidden =TRUE;
            self.paypalPGLyt.hidden=TRUE;
            self.selectpayment.hidden=true;
            self.seperator.hidden=true;
        }else{
            self.strpPGLyt.hidden =FALSE;
            self.paypalPGLyt.hidden=FALSE;
            self.selectpayment.hidden=FALSE;
            self.seperator.hidden=FALSE;
        }
    }else if(id ==1){
        //stripe
        if([self.selectedPayMethod  isEqual: @"Stripe"]){
            [self.payWithStrp setImage:[UIImage imageNamed:@"rb_blue_unsel.png"]];
            [self.payWithPaypal setImage:[UIImage imageNamed:@"rb_blue_sel.png"]];
            self.selectedPayMethod=@"Paypal";
        }else{
            [self.payWithPaypal setImage:[UIImage imageNamed:@"rb_blue_unsel.png"]];
            [self.payWithStrp setImage:[UIImage imageNamed:@"rb_blue_sel.png"]];
            self.selectedPayMethod=@"Stripe";
        }
    }else{
        //paypal
        if([self.selectedPayMethod  isEqual: @"Paypal"]){
            [self.payWithPaypal setImage:[UIImage imageNamed:@"rb_blue_unsel.png"]];
            [self.payWithStrp setImage:[UIImage imageNamed:@"rb_blue_sel.png"]];
            self.selectedPayMethod=@"Stripe";
        }else{
            [self.payWithStrp setImage:[UIImage imageNamed:@"rb_blue_unsel.png"]];
            [self.payWithPaypal setImage:[UIImage imageNamed:@"rb_blue_sel.png"]];
            self.selectedPayMethod=@"Paypal";        }
    }
}
- (IBAction)checkoutCart:(id)sender {
    self.paymentFor=@"OrderPayment";
    if(selectedCoupons.count > 0){
        for(CouponModel *cpn in selectedCoupons){
            cpn.applicableAmount=cpn.recalculatedOfferedAmount;
            //cpn.couponApplied=true;
        }
    }
    if(self.prepaidChecked){
        self.defCoupon.applicableAmount=self.prepaidApplied;
        [selectedCoupons addObject:self.defCoupon];
    }
    if([self.selectedPayMethod  isEqual: @"Prepaid"]){
        NSMutableArray *cpnArray = [[NSMutableArray alloc]init];
        if(selectedCoupons.count > 0){
            @try{
                cpnArray = [self.couponDao applyAllCoupons:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] CouponList:selectedCoupons];
                self.resultModel = [self.trxnDAO addTransaction:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] Coupon:cpnArray PayMethod:@"Prepaid" ];
                [self.trxnDAO updateTransactionToPurchase:[self.wnpCont getUserId] OrderId:self.resultModel.orderId];
            }@catch (NSException *exception) {
                [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
            }
        }
        
        
        [self.wnpCont clearItemsArray];
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
        MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
        if(viewCtrl != nil){
            viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
            viewCtrl.viewName=@"PayStatus";
            viewCtrl.reciept = self.resultModel;
            viewCtrl.status = TRUE;
            [self presentViewController:viewCtrl animated:YES completion:nil];
        }
    }else if([self.selectedPayMethod  isEqual: @"Stripe"]){
        
        [self showStripePaymentPopup];
    }else{
        NSMutableArray *cpnArray = [[NSMutableArray alloc]init];
        @try {
            if(selectedCoupons.count > 0){
                cpnArray = [self.couponDao applyAllCoupons:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] CouponList:selectedCoupons];
            }
            
            self.resultModel = [self.trxnDAO addTransaction:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] Coupon:cpnArray PayMethod:@"Paypal" ];
            if([self.selStrMdl.paypalEnv isEqualToString:@"live"]){
                
                [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction :self.selStrMdl.paypalClientId}];
                [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
            }else{
                [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox :self.selStrMdl.paypalClientId}];
                
                [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
            }
            NSMutableString *desc = [[NSMutableString alloc]init];
            [desc appendString:@"Payment for Bill #"];
            [desc appendString:self.resultModel.orderId.stringValue];
            [self doPaypalPayment:self.resultModel.payableTotal description:desc currencyCode:@"USD"];
        }
        @catch (NSException *exception) {
            if(self.resultModel != nil ){
                [self.trxnDAO deleteTransaction:[self.wnpCont getUserId] OrderId:self.resultModel.orderId];
            }
            [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
        }
        
        
    }
    
}

- (IBAction)cancelCheckout:(id)sender {
    
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"Cart";
        viewCtrl.loadScanpopup=NO;
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
    
}


- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    self.strpSubmitBtn.enabled = textField.isValid;
    if(textField.isValid){
        [self hideKeyBord];
        self.strpSubmitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    }
    
}
-(void) showStripePaymentPopup{
    self.view.alpha=0.0;
    for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
        subViews.alpha=0.3;
        subViews.userInteractionEnabled=FALSE;
    }
    self.view.userInteractionEnabled=false;
    self.topLayer=[[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-135,self.view.center.y-95,270,190)];
    self.topLayer.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.topLayer.layer.borderWidth = 1.0f;
    self.topLayer.alpha=1.0;
    self.topLayer.backgroundColor=[UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self.topLayer];
    
    UILabel *headerLbl =[[UILabel alloc] initWithFrame:CGRectMake(0,0,270,35)];
    headerLbl.text=@"Stripe payment gateway";
    headerLbl.textAlignment=NSTextAlignmentCenter;
    UIFont *txtFont = [headerLbl.font fontWithSize:wnpFontSize];
    headerLbl.font = txtFont;
    headerLbl.textColor=[UIColor whiteColor];
    headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.topLayer addSubview:headerLbl];
    
    UILabel *descLabel =[[UILabel alloc] initWithFrame:CGRectMake(10,45,195,30)];
    descLabel.text=@"Payment for purchase";
    descLabel.textAlignment=NSTextAlignmentLeft;
    // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    descLabel.font = txtFont;
    descLabel.textColor=[UIColor blackColor];
    // headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.topLayer addSubview:descLabel];
    
    UILabel *amtLbl =[[UILabel alloc] initWithFrame:CGRectMake(210,45,50,30)];
    amtLbl.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter numberFromString:self.payableBalance.stringValue]];
    amtLbl.textAlignment=NSTextAlignmentLeft;
    // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    amtLbl.font = txtFont;
    amtLbl.textColor=[UIColor blackColor];
    // headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.topLayer addSubview:amtLbl];
    
    
    
    self.strpPymntTf = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(10,85,250,30)];
    self.strpPymntTf.delegate=self;
    [self.topLayer addSubview:self.strpPymntTf];
    
    self.strpSubmitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20,150,100,30)];
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    [self.strpSubmitBtn setTitle: @"Submit" forState: UIControlStateNormal];
    self.strpSubmitBtn.userInteractionEnabled=TRUE;
    self.strpSubmitBtn.enabled=FALSE;
    [self.strpSubmitBtn addTarget:self action:@selector(submitStripePayment:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.topLayer addSubview:self.strpSubmitBtn];
    
    self.strpCancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(150,150,100,30)];
    self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.strpCancelBtn setTitle: @"Cancel" forState: UIControlStateNormal];
    self.strpCancelBtn.userInteractionEnabled=TRUE;
    self.strpCancelBtn.enabled=TRUE;
    [self.strpCancelBtn addTarget:self action:@selector(cancelStripePayment:) forControlEvents: UIControlEventTouchUpInside];
    self.strpCancelBtn.enabled = TRUE;
    [self.topLayer addSubview:self.strpCancelBtn];
    [self.topLayer addSubview:self.strpCancelBtn];
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBord)];
    viewTap.numberOfTapsRequired = 1;
    viewTap.numberOfTouchesRequired = 1;
    [self.self.topLayer setUserInteractionEnabled:YES];
    [self.self.topLayer addGestureRecognizer:viewTap];
}
- (IBAction)submitStripePayment:(id)sender {
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    self.strpSubmitBtn.userInteractionEnabled=FALSE;
    self.strpSubmitBtn.enabled=FALSE;
    
    self.strpCancelBtn.backgroundColor=[UIColor grayColor];
    self.strpCancelBtn.userInteractionEnabled=FALSE;
    self.strpCancelBtn.enabled=FALSE;
    if(self.selStrMdl.stripePublushKey == (id)[NSNull null] || self.selStrMdl.stripePublushKey == nil){
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Invalid Stripe  account"];
        //[self.delegate stripePaymentViewController:self didFinish:error];
        for(UIView *subViews in [self.topLayer subviews]){
            [subViews removeFromSuperview];
        }
        for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
            subViews.alpha=1.0;
            subViews.userInteractionEnabled=TRUE;
        }
        [self.topLayer removeFromSuperview];
        self.view.alpha=1.0;
        self.view.userInteractionEnabled=TRUE;

        return;
    }
    NSString *publicKey=[self.utils decode:self.selStrMdl.stripePublushKey];
    STPAPIClient *strpClient = [[STPAPIClient alloc] initWithPublishableKey:publicKey];
    [Stripe setDefaultPublishableKey:publicKey];
    if (![self.strpPymntTf isValid]) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Invalid Card"];
        return;
    }
    
    if (![Stripe defaultPublishableKey]) {

        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Invalid key"];
        //[self.delegate stripePaymentViewController:self didFinish:error];
        for(UIView *subViews in [self.topLayer subviews]){
            [subViews removeFromSuperview];
        }
        for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
            subViews.alpha=1.0;
            subViews.userInteractionEnabled=TRUE;
        }
        [self.topLayer removeFromSuperview];
        self.view.alpha=1.0;

        self.view.userInteractionEnabled=TRUE;

        return;
    }
    
    [strpClient createTokenWithCard:self.strpPymntTf.card completion:^(STPToken *token, NSError *error) {
        if (error) {
            [self.delegate stripePaymentViewController:self didFinish:error];
            [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:error.description];
            for(UIView *subViews in [self.topLayer subviews]){
                [subViews removeFromSuperview];
            }
            for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
                subViews.alpha=1.0;
                subViews.userInteractionEnabled=TRUE;
            }
            [self.topLayer removeFromSuperview];
            self.view.alpha=1.0;
            self.view.userInteractionEnabled=TRUE;

            return;
        }else{
            NSMutableArray *cpnArray = [[NSMutableArray alloc]init];
            @try {
                if(selectedCoupons.count > 0){
                    cpnArray= [self.couponDao applyAllCoupons:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] CouponList:selectedCoupons];
                }
                self.resultModel = [self.trxnDAO addTransaction:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] Coupon:cpnArray PayMethod:@"Stripe" ];
                @try{
                NSString *status= [self.strpDAO doStripePayment:self.payableBalance ID:[self.wnpCont getSelectedStoreId] CardToken:token.tokenId Currency:@"usd" Description:[NSString stringWithFormat:@"%s%@","Payment for Bill # ",self.resultModel.orderId.stringValue] IsDealerAccount:FALSE];
                //do stripe payment
             //   if ([status isEqual:@"SUCCESS"]){
                    [self.trxnDAO updateTransactionToPurchase:[self.wnpCont getUserId] OrderId:self.resultModel.orderId];
                    for(UIView *subViews in [self.topLayer subviews]){
                        [subViews removeFromSuperview];
                    }
                    for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
                        subViews.alpha=1.0;
                        subViews.userInteractionEnabled=TRUE;
                    }
                    [self.topLayer removeFromSuperview];
                    self.view.alpha=1.0;
                    
                    self.view.userInteractionEnabled=TRUE;
                    [self.wnpCont clearItemsArray];
                    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
                    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
                    if(viewCtrl != nil){
                        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                        viewCtrl.viewName=@"PayStatus";
                        viewCtrl.reciept = self.resultModel;
                        viewCtrl.status = TRUE;
                        [self presentViewController:viewCtrl animated:YES completion:nil];
                    }

                }@catch (NSException *exception) {
                    [self.trxnDAO deleteTransaction:[self.wnpCont getUserId] OrderId:self.resultModel.orderId];
                    [self cancelStripePayment:sender];
                    [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
                }
             //  }else{
             //       [self.trxnDAO deleteTransaction:[self.wnpCont getUserId] OrderId:self.resultModel.orderId];
              //  }
                
                //if failed
                //
                
            }
            @catch (NSException *exception) {
                if(self.resultModel != nil ){
                    [self.trxnDAO deleteTransaction:[self.wnpCont getUserId] OrderId:self.resultModel.orderId];
                }
                [self cancelStripePayment:sender];
                [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
            }
            
            
        }
    }];
}

- (IBAction)cancelStripePayment:(id)sender {
    for(UIView *subViews in [self.topLayer subviews]){
        [subViews removeFromSuperview];
    }
    for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=TRUE;
    }
    [self.topLayer removeFromSuperview];
    self.view.alpha=1.0;

    self.view.userInteractionEnabled=TRUE;
}

- (void)doPaypalPayment:(NSString *)amount description:(NSString *)desc currencyCode:(NSString *) currCode{
    self.resultText = nil;
    NSNumber *nmbr =[self.formatter numberFromString:amount];
    
    NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:[self.formatter stringFromNumber:[NSNumber numberWithDouble:nmbr.doubleValue]]];
    PayPalPayment *payment = [[PayPalPayment alloc]init];
    payment.amount = total;
    payment.currencyCode = currCode;
    payment.shortDescription = desc;
    payment.items = nil;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = nil;//paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
    
    if (!payment.processable) {
    }
    // Update payPalConfig re accepting credit cards.
    self.payPalConfig.acceptCreditCards = YES;
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment configuration:self.payPalConfig delegate:self];
    [self.parentViewController presentViewController:paymentViewController animated:YES completion:nil];
}


- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    self.resultText = [completedPayment description];
    @try {
        [self.trxnDAO updateTransactionToPurchase:[self.wnpCont getUserId] OrderId:self.resultModel.orderId];
    }
    @catch (NSException *exception) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.wnpCont clearItemsArray];
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"PayStatus";
        viewCtrl.reciept = self.resultModel;
        viewCtrl.status = TRUE;
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
    
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    self.resultText = nil;
    @try {
        [self.trxnDAO deleteTransaction:[self.wnpCont getUserId] OrderId:self.resultModel.orderId];
    }
    @catch (NSException *exception) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) applyCoupons{
    if(self.prepaidChecked){
        if(self.prepaidBalance.doubleValue >= (self.totalAmount.doubleValue - offerAmount.doubleValue)){
            self.prepaidApplied= [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue)];
        }else{
            self.prepaidApplied = self.prepaidBalance;
            self.payableBalance = [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue-self.prepaidApplied.doubleValue)] ;
            if(self.payableBalance.doubleValue < 0.5){
                self.prepaidApplied = [NSNumber numberWithDouble:self.prepaidApplied.doubleValue-(0.5-self.payableBalance.doubleValue)];
                
            }

        }
        if(self.prepaidApplied.doubleValue < 0){
            self.prepaidApplied = [NSNumber numberWithInt:0];
        }
        
    }else{
        self.prepaidApplied = [NSNumber numberWithInt:0];
    }
    self.payableBalance = [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue-self.prepaidApplied.doubleValue)] ;
    if(self.payableBalance.doubleValue <= 0){
        self.payableBalance = [NSNumber numberWithInt:0];
    }
    self.preapidAppliedLabel.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:self.prepaidApplied]];
    self.balancePayableLabel.text =[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:self.payableBalance]];
    NSMutableString *payStr = [NSMutableString stringWithFormat:@"Pay balancel %@",[self.wnpCont getCurrencySymbol]];
    [payStr appendString:[self.formatter stringFromNumber:[NSNumber numberWithDouble:self.payableBalance.doubleValue]]];
    [payStr appendString:@" using"];
    self.selectpayment.text=payStr;
    self.offerAppliedAmtTV.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:offerAmount]];
    if(self.payableBalance.doubleValue <= 0){
        self.selectedPayMethod=@"Prepaid";
        self.strpPGLyt.hidden =TRUE;
        self.paypalPGLyt.hidden=TRUE;
        self.selectpayment.hidden=true;
        self.seperator.hidden=true;
    }else{
        self.strpPGLyt.hidden =FALSE;
        self.paypalPGLyt.hidden=FALSE;
        self.selectpayment.hidden=FALSE;
        self.seperator.hidden=FALSE;
    }
    
}
- (void) refreshPrepaidData{
    @try{
        self.prepaidBalance = [self.couponDao getPrepaidBalance:[self.wnpCont getUserId]];
    }
    @catch (NSException *exception) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
    if(self.prepaidBalance.doubleValue <= 0){
        self.payWithPrepaid.userInteractionEnabled = NO;
        [self.payWithPrepaid setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        self.prepaidChecked =NO;
        //self.prepaifPGLyt.hidden=TRUE;
        self.prepaidApplied = [NSNumber numberWithInt:0];
        //self.prepaidAppliedLyt.hidden=TRUE;
        //self.balanceLyt.hidden=TRUE;
    }else{
        self.prepaidAppliedLyt.hidden=FALSE;
        self.balanceLyt.hidden=FALSE;
        self.payWithPrepaid.userInteractionEnabled = TRUE;
        if(self.prepaidChecked){
            if(self.prepaidBalance.doubleValue >= (self.totalAmount.doubleValue - offerAmount.doubleValue)){
                self.prepaidApplied= [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue)];
            }else{
                self.prepaidApplied = self.prepaidBalance;
                self.payableBalance = [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue-self.prepaidApplied.doubleValue)] ;
                if(self.payableBalance.doubleValue < 0.5){
                    self.prepaidApplied = [NSNumber numberWithDouble:self.prepaidApplied.doubleValue-(0.5-self.payableBalance.doubleValue)];
                    
                }
            }
            if(self.prepaidApplied.doubleValue < 0){
                self.prepaidApplied = [NSNumber numberWithInt:0];
            }
        }
    }
    self.payableBalance = [NSNumber numberWithDouble:(self.totalAmount.doubleValue - offerAmount.doubleValue-self.prepaidApplied.doubleValue)] ;
    if(self.payableBalance.doubleValue <= 0){
        self.payableBalance = [NSNumber numberWithInt:0];
    }
    self.preapidAppliedLabel.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:self.prepaidApplied]];
    self.balancePayableLabel.text =[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter stringFromNumber:self.payableBalance]];

    NSMutableString *payStr = [NSMutableString stringWithFormat:@"Pay balancel %@",[self.wnpCont getCurrencySymbol]];
    [payStr appendString:[self.formatter stringFromNumber:[NSNumber numberWithDouble:self.payableBalance.doubleValue]]];
    [payStr appendString:@" using"];
    self.selectpayment.text=payStr;
    self.prepaidChecked =TRUE;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectPaymentGateway:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.payWithPrepaid setUserInteractionEnabled:YES];
    [self.payWithPrepaid addGestureRecognizer:singleTap];
    //self.prepaidAppliedLyt.hidden=FALSE;
    //self.balanceLyt.hidden=FALSE;
    if(self.payableBalance.doubleValue <= 0){
        self.selectedPayMethod=@"Prepaid";
        self.strpPGLyt.hidden =TRUE;
        self.paypalPGLyt.hidden=TRUE;
        self.selectpayment.hidden=true;
        self.seperator.hidden=true;
    }else{
        self.strpPGLyt.hidden =FALSE;
        self.paypalPGLyt.hidden=FALSE;
        self.selectpayment.hidden=FALSE;
        self.seperator.hidden=FALSE;
    }
    NSMutableString *preapidStr = [NSMutableString stringWithFormat:@"Prepaid (Availabel %@",[self.wnpCont getCurrencySymbol]];
    NSNumber *prebal = [NSNumber numberWithDouble:(self.prepaidBalance.doubleValue-self.prepaidApplied.doubleValue)];
    [preapidStr appendString:[self.formatter stringFromNumber:[NSNumber numberWithDouble:prebal.doubleValue]]];
    [preapidStr appendString:@")"];
    
    self.prepaidChkText.text=preapidStr;
}

- (void) showrechargePopup{
    @try{
        self.view.backgroundColor=[UIColor grayColor];
        DealerDAO *dlrDAO=[[DealerDAO alloc]init];
        NSArray *dealerArray=[dlrDAO getAllDealer];
        DealerModel *dlrModel = [dealerArray objectAtIndex:0];
        NSString *publicKey=[self.utils decode:dlrModel.stripePublushKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshPrepaidData" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPrepaidData) name:@"refreshPrepaidData" object:nil];
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"PrepaidPopup" bundle:nil];
        PrepaidPopup *viewController=[stryBrd instantiateViewControllerWithIdentifier:@"PrepaidPopup"];
        
        viewController.strpPubKey= publicKey ;
        viewController.paypalEnv=dlrModel.paypalEnv;
        viewController.paypalClientId=dlrModel.paypalClientId;
        viewController.currencyCode=@"USD";
        viewController.custRechMinAmt=dlrModel.minRechargeAmt;
        
        UIView *dashboardView = viewController.view;
        [dashboardView setFrame:CGRectMake(self.view.bounds.origin.x-155,self.view.bounds.origin.x-180,310,360)];
        
        [self.view addSubview:dashboardView];
        [self addChildViewController:viewController];
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=0.2;
            [subViews setUserInteractionEnabled:NO];
        }
        
        dashboardView.alpha=1;
        [dashboardView setUserInteractionEnabled:YES];
        dashboardView.center = self.view.center;
    }@catch (NSException *exception) {
        self.view.backgroundColor=[UIColor whiteColor];
      [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }

}

- (void) cancelCouponPopup{
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
    }
    
}

- (void)setTotalAmtForOffer:(NSNumber *)total{
    totalAmountForOffer =total;
}
- (NSNumber *)getTotalAmtForOffer{
    return totalAmountForOffer;
}

- (void)showCouponView{
    
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
    }
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"CouponPopup" bundle:nil];
    CouponPopup *viewController=[stryBrd instantiateViewControllerWithIdentifier:@"CouponPopup"];
    viewController.totalAmount=self.totalAmount;
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [self.view bringSubviewToFront:viewController.view];
    [viewController.view setUserInteractionEnabled:YES];
    viewController.view.center = self.view.center;
    for(UIView *uisv in [viewController.view subviews]){
        [uisv setUserInteractionEnabled:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [self.parentViewController touchesBegan:touches withEvent:event];
}
-(void) hideKeyBord{
    [self.strpPymntTf resignFirstResponder];
    [self.view endEditing:YES];
}
- (NSMutableArray *)getOfferCoupons{
    return offerCoupons;
}
- (void)setOfferCoupons:(NSMutableArray *)offerCpns{
    offerCoupons = offerCpns;
}

- (NSMutableArray *)getSelectedCoupons{
    return selectedCoupons;
}
- (void)setSelectedCoupons:(NSMutableArray *)slctedCoupons{
    selectedCoupons = slctedCoupons;
}
- (void)addSelectedCoupon:(NSDictionary *)cpn{
    CouponModel *mdl = [[CouponModel alloc]init];
    [selectedCoupons addObject:[mdl initWithDictionary:cpn]];
}
- (void)removeAllSelectedCoupon{
    
    selectedCoupons =[[NSMutableArray alloc]init];
}
- (NSDictionary *)getOfferCouponAt:(NSInteger *)index{
    CouponModel *mdl = [offerCoupons objectAtIndex:index];
    return  [mdl dictionaryWithAllPropertiesOfObject:mdl];
    
    
}
- (NSNumber *)getOfferAmount{
    return offerAmount;
    
}
- (void)setOfferAmount:(NSNumber *)offrAmt{
    offerAmount = offrAmt;
}

- (void)setTotalAmountForOffer:(NSNumber *)amt{
    totalAmountForOffer = amt;
}

- (NSNumber *)getTotalAmountForOffer{
    return totalAmountForOffer;
    
}
@end

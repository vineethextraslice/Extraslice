//
//  PrepaidPopup.m
//  WalkNPay
//
//  Created by Administrator on 23/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import "PrepaidPopup.h"
#import "WnPConstants.h"
#import "PayPalMobile.h"
#import "PayPalPaymentViewController.h"
#import "STPAPIClient.h"
#import "Stripe.h"
#import "PaymentGateway.h"
#import "CouponModel.h"
#import "CouponDAO.h"
#import "WnPUtilities.h"
#import "StripeDAO.h"


@interface PrepaidPopup()

@property(strong,nonatomic) NSMutableArray *prepaidCpnArray;
@property(strong,nonatomic) NSMutableArray *selectedCouponIds;
@property(strong,nonatomic) NSMutableArray *selectedCouponRowNos;
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(nonatomic) CGRect cpnViewBound;
@property(nonatomic) BOOL customSelected;
@property(nonatomic) BOOL strpSelected;
@property (weak,nonatomic) NSString *resultText;
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property (strong, nonatomic) UIButton *strpSubmitBtn;
@property (strong, nonatomic) UIButton *strpCancelBtn;
@property(strong,nonatomic) NSNumber *amountPayable;
@property(strong,nonatomic) NSNumber *amountUsable;
@property(strong,nonatomic) CouponDAO *cpnDAO;
@property(strong,nonatomic) CouponModel *customeCpnMdl;
@property(strong,nonatomic) WnPUtilities *utils;
@property(strong,nonatomic) NSNumberFormatter *nmbrFrmtr;
@property(strong,nonatomic) StripeDAO *strpDAO;
@property(strong,nonatomic) UIView *topLayer;
@property(strong,nonatomic) TransactionModel *trxnMdl;
@property(strong,nonatomic) UIView *scanCardView;
@property(nonatomic) UIImageView *selCardImg;
@property(strong,nonatomic) UILabel *selCardNum;
@property(strong,nonatomic) UILabel *selectedCardExp;
@property(strong,nonatomic) UILabel *selectedCardCVV;
@property(strong,nonatomic) CardIOCreditCardInfo *ioCard;
@property(strong,nonatomic) UILabel *scantxt;
@end


@implementation PrepaidPopup

- (void)viewDidLoad {
    [super viewDidLoad];
    self.prepaidCpnArray = [[NSMutableArray alloc]init];
    self.selectedCouponIds = [[NSMutableArray alloc]init];
    self.selectedCouponRowNos = [[NSMutableArray alloc]init];
    self.cpnDAO = [[CouponDAO alloc]init];
    self.wnpCont = [[WnPConstants alloc]init];
    self.utils = [[WnPUtilities alloc]init];

     self.view.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    self.nmbrFrmtr= [[NSNumberFormatter alloc] init];
    self.strpDAO=[[StripeDAO alloc]init];
    self.nmbrFrmtr.numberStyle = NSNumberFormatterDecimalStyle;
    self.customSelected = TRUE;
    self.strpSelected = TRUE;
    self.amountPayable = [NSNumber numberWithInt:0];
    self.amountUsable = [NSNumber numberWithInt:0];
    self.totalPayableAmt.text=[NSString stringWithFormat:@"Payable amount %@%@",[self.wnpCont getCurrencySymbol],[self.nmbrFrmtr numberFromString:self.amountPayable.stringValue]];
    self.totalUsabeleAmt.text=[NSString stringWithFormat:@"Usable amount %@%@",[self.wnpCont getCurrencySymbol],[self.nmbrFrmtr numberFromString:self.amountUsable.stringValue]];
    self.minimumAmtLabel.text=[NSString stringWithFormat:@"Minimum %@%@",[self.wnpCont getCurrencySymbol],self.custRechMinAmt.stringValue];
    self.submitBtn.backgroundColor=[UIColor grayColor];
    self.submitBtn.enabled=false;
    self.cancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    @try {
        self.prepaidCpnArray = [self.cpnDAO getAllPrepaidCoupons:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId]];
    }
    @catch (NSException *exception) {
        
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
    
    self.couponView.hidden=TRUE;
    if(self.prepaidCpnArray.count == 0){
        self.couponRadio.hidden=TRUE;
        self.couponLabel.hidden=TRUE;
    }else{
        self.couponRadio.hidden=FALSE;
        self.couponLabel.hidden=FALSE;
    }
    [self.view bringSubviewToFront:self.couponRadio];
    [self.view bringSubviewToFront:self.customRadio];
    //self.headerView.backgroundColor=[wnpCont getThemeHeaderColor];
    UITapGestureRecognizer *rechargeCstm = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectRechargeMethod:)];
    rechargeCstm.numberOfTapsRequired = 1;
    rechargeCstm.numberOfTouchesRequired = 1;
    [self.customRadio setUserInteractionEnabled:YES];
    [self.customRadio addGestureRecognizer:rechargeCstm];
    
    UITapGestureRecognizer *rechargeCpn = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectRechargeMethod:)];
    rechargeCpn.numberOfTapsRequired = 1;
    rechargeCpn.numberOfTouchesRequired = 1;
    [self.couponRadio setUserInteractionEnabled:YES];
    [self.couponRadio addGestureRecognizer:rechargeCpn];
    
    UITapGestureRecognizer *payByStrp = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectPaymentGateway:)];
    payByStrp.numberOfTapsRequired = 1;
    payByStrp.numberOfTouchesRequired = 1;
    [self.strpBtn setUserInteractionEnabled:YES];
    [self.strpBtn addGestureRecognizer:payByStrp];
    
    UITapGestureRecognizer *payByPpl = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectPaymentGateway:)];
    payByPpl.numberOfTapsRequired = 1;
    payByPpl.numberOfTouchesRequired = 1;
    [self.paypalBtn setUserInteractionEnabled:YES];
    [self.paypalBtn addGestureRecognizer:payByPpl];
    
    [self.amountText addTarget:self action:@selector(editQuantity:) forControlEvents: UIControlEventEditingDidEnd] ;
    
    self.couponTable.dataSource=self;
    self.couponTable.delegate=self;
    self.view.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    
    CGRect screenRect = [self.couponTable bounds];
    CGFloat tableWidth = screenRect.size.width-24;
    
    UIView *checkBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0 , 24, 24)];
    checkBox.backgroundColor=[self.wnpCont getThemeHeaderColor];
    [self.couponView addSubview:checkBox];
    
    
    UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(24, 0 , (tableWidth*0.5f), 24)];
    UIFont *txtFont = [code.font fontWithSize:12.0];
    code.font = txtFont;
    code.text=@"Coupon code";
    
    code.backgroundColor=[self.wnpCont getThemeHeaderColor];
    [self.couponView addSubview:code];
    
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(24+(tableWidth*0.5f), 0 , (tableWidth*0.3f), 24)];
    price.font = txtFont;
    price.text=@"Price";
    price.backgroundColor=[self.wnpCont getThemeHeaderColor];
    [self.couponView addSubview:price];
    
    UILabel *more = [[UILabel alloc] initWithFrame:CGRectMake(24+(tableWidth*0.8f), 0 , (tableWidth*0.2f), 24)];
    more.font = txtFont;
    more.text=@"Details";
    more.backgroundColor=[self.wnpCont getThemeHeaderColor];
    [self.couponView addSubview:more];
    
    self.couponView.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.couponView.layer.borderWidth = 1.0f;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(IBAction) editQuantity:(UITextField *)textView{
    
    if(self.amountText.text.length>0){
        self.submitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
        self.submitBtn.enabled=true;
    }else{
        self.submitBtn.backgroundColor=[UIColor grayColor];
        self.submitBtn.enabled=false;
    }
    self.amountPayable = [self.nmbrFrmtr numberFromString:self.amountText.text];
    self.amountUsable = [self.nmbrFrmtr numberFromString:self.amountText.text];
    self.totalPayableAmt.text=[NSString stringWithFormat:@"Payable amount %@%@",[self.wnpCont getCurrencySymbol],[self.nmbrFrmtr numberFromString:self.amountPayable.stringValue]];
    self.totalUsabeleAmt.text=[NSString stringWithFormat:@"Usable amount %@%@",[self.wnpCont getCurrencySymbol],[self.nmbrFrmtr numberFromString:self.amountUsable.stringValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.prepaidCpnArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CouponModel *cpnMdl =[self.prepaidCpnArray objectAtIndex:indexPath.row];
    
    NSString *celId =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
    }
    
    CGRect screenRect = [self.couponTable bounds];
    CGFloat tableWidth = screenRect.size.width-24;
    
    UIImageView *checkBox = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2 , 22, 22)];
    [checkBox setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
    [checkBox setUserInteractionEnabled:YES];
    [self.couponTable bringSubviewToFront:checkBox];
    UITapGestureRecognizer *delSelected=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCoupon:)];
    checkBox.tag=indexPath.row;
    [delSelected setNumberOfTapsRequired:1];
    [checkBox addGestureRecognizer:delSelected];
    [cell addSubview:checkBox];
    
    
    UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(26, 2 , (tableWidth*0.5f)-4, 22)];
    UIFont *txtFont = [code.font fontWithSize:12.0];
    code.font = txtFont;
    code.text=cpnMdl.couponCode;
    [cell addSubview:code];
    
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(28+(tableWidth*0.5f), 2 , (tableWidth*0.3f)-4, 22)];
    price.font = txtFont;
    price.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.nmbrFrmtr numberFromString:cpnMdl.couponPrice.stringValue]];
    [cell addSubview:price];
    
    UILabel *more = [[UILabel alloc] initWithFrame:CGRectMake(30+(tableWidth*0.8f), 2 , (tableWidth*0.2f)-4, 22)];
    more.font = txtFont;
    more.text=@"more";
    [cell addSubview:more];
    
    
    return cell;
}
- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *) newIndexPath{
    //UITextField* tf = (UITextField *) [tableView viewWithTag:newIndexPath.row+1000];
    
}



- (IBAction)cancelPrepaid:(id)sender {
    for(UIView *subViews in [self.parentViewController.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    for(UIView *subViews in [self.parentViewController.parentViewController.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    self.parentViewController.view.backgroundColor=[UIColor whiteColor];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    // [self.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)selectRechargeMethod:(id)sender {
    self.selectedCouponIds = [[NSMutableArray alloc]init];
    self.selectedCouponRowNos = [[NSMutableArray alloc]init];
    
    self.amountPayable = [NSNumber numberWithInt:0];
    self.amountUsable = [NSNumber numberWithInt:0];
    self.totalPayableAmt.text=[NSString stringWithFormat:@"Payable amount %@%@",[self.wnpCont getCurrencySymbol],[self.nmbrFrmtr numberFromString:self.amountPayable.stringValue]];
    self.totalUsabeleAmt.text=[NSString stringWithFormat:@"Usable amount %@%@",[self.wnpCont getCurrencySymbol],[self.nmbrFrmtr numberFromString:self.amountUsable.stringValue]];
    self.amountText.text=@"";
    self.selectedCouponRowNos=nil;
    self.selectedCouponRowNos=[[NSMutableArray alloc]init];
    self.submitBtn.backgroundColor=[UIColor grayColor];
    self.submitBtn.enabled=false;
    
    if(self.customSelected){
        self.customSelected=FALSE;
        [self.customRadio setImage:[UIImage imageNamed:@"rb_blue_unsel.png"]];
        [self.couponRadio setImage:[UIImage imageNamed:@"rb_blue_sel.png"]];
        self.couponLabel.hidden=FALSE;
        self.couponView.hidden=FALSE;
    }else{
        [self.couponTable beginUpdates];
        [self.couponTable endUpdates];
        self.customSelected=TRUE;
        [self.customRadio setImage:[UIImage imageNamed:@"rb_blue_sel.png"]];
        [self.couponRadio setImage:[UIImage imageNamed:@"rb_blue_unsel.png"]];
        self.couponLabel.hidden=TRUE;
        self.couponView.hidden=TRUE;
    }
}
- (IBAction)selectPaymentGateway:(id)sender {
    if(self.strpSelected){
        self.strpSelected=FALSE;
        [self.strpBtn setImage:[UIImage imageNamed:@"rb_blue_unsel.png"]];
        [self.paypalBtn setImage:[UIImage imageNamed:@"rb_blue_sel.png"]];
    }else{
        self.strpSelected=TRUE;
        [self.strpBtn setImage:[UIImage imageNamed:@"rb_blue_sel.png"]];
        [self.paypalBtn setImage:[UIImage imageNamed:@"rb_blue_unsel.png"]];
    }
}

- (IBAction)submitOnClick:(id)sender {
    self.view.alpha=0.0;
    
    //[UIApplication sharedApplication].keyWindow.alpha=0.3;
    if(self.customSelected){
        self.amountPayable = [self.nmbrFrmtr numberFromString:self.amountText.text];
        self.amountUsable = [self.nmbrFrmtr numberFromString:self.amountText.text];
    }else{
        for(NSNumber *number in self.selectedCouponRowNos){
            CouponModel *cpnMdl =[self.prepaidCpnArray objectAtIndex:number.integerValue];
            [self.selectedCouponIds addObject:cpnMdl.couponId];
        }
    }
    self.customeCpnMdl= [[CouponModel alloc]init];
    self.customeCpnMdl.couponType=@"PREPAID";
    self.amountPayable = [self.nmbrFrmtr numberFromString:self.amountPayable.stringValue];
    self.amountUsable = [self.nmbrFrmtr numberFromString:self.amountUsable.stringValue];
    self.customeCpnMdl.couponPrice=self.amountPayable;
    self.customeCpnMdl.offeredAmount = self.amountUsable;
    if([self.wnpCont getSelectedStoreId].intValue >0){
        self.customeCpnMdl.storeId=[self.wnpCont getSelectedStoreId];
    }else{
        self.customeCpnMdl.storeId=[NSNumber numberWithInt:-1];
    }
    
    self.customeCpnMdl.userId=[self.wnpCont getUserId];
    if(self.strpSelected){
        for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
            subViews.alpha=0.3;
            subViews.userInteractionEnabled=FALSE;
        }
        self.topLayer=[[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-135,self.view.center.y-95,270,265)];
        self.topLayer.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
        self.topLayer.layer.borderWidth = 1.0f;
        [[UIApplication sharedApplication].keyWindow addSubview:self.topLayer];
        self.topLayer.alpha=1.0;
        self.topLayer.backgroundColor=[UIColor whiteColor];
        
        UILabel *headerLbl =[[UILabel alloc] initWithFrame:CGRectMake(0,0,270,35)];
        headerLbl.text=@"Stripe payment gateway";
        headerLbl.textAlignment=NSTextAlignmentCenter;
        UIFont *txtFont = [headerLbl.font fontWithSize:wnpFontSize];
        headerLbl.font = txtFont;
        headerLbl.textColor=[UIColor whiteColor];
        headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
        [self.topLayer addSubview:headerLbl];
        
        
        UILabel *descLabel =[[UILabel alloc] initWithFrame:CGRectMake(10,45,195,30)];
        descLabel.text=[NSString stringWithFormat:@"%s%@","Amount for prepaid recharge for user ",[self.wnpCont getUserName]];
        descLabel.textAlignment=NSTextAlignmentLeft;
       // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
        descLabel.font = txtFont;
        descLabel.textColor=[UIColor blackColor];
       // headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
        [self.topLayer addSubview:descLabel];
        
        UILabel *amtLbl =[[UILabel alloc] initWithFrame:CGRectMake(210,45,50,30)];
        amtLbl.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],self.amountPayable.stringValue];
        amtLbl.textAlignment=NSTextAlignmentLeft;
        // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
        amtLbl.font = txtFont;
        amtLbl.textColor=[UIColor blackColor];
        // headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
        [self.topLayer addSubview:amtLbl];

        
        
        self.scanCardView = [[UIView alloc] initWithFrame:CGRectMake(25,85,220,50)];
        [self.topLayer addSubview:self.scanCardView];
        UITapGestureRecognizer *scanCardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(scanCard:)];
        scanCardTap.numberOfTapsRequired = 1;
        scanCardTap.numberOfTouchesRequired = 1;
        [self.scanCardView setUserInteractionEnabled:YES];
        [self.scanCardView addGestureRecognizer:scanCardTap];
        self.scanCardView.layer.borderColor= [self.wnpCont getThemeBaseColor].CGColor;
        self.scanCardView.layer.borderWidth = 1.0f;
        self.scanCardView.backgroundColor=[self.wnpCont getThemeColorWithTransparency:0.2];
         self.scantxt=[[UILabel alloc] initWithFrame:CGRectMake(57,5,150,40)];
        self.scantxt.text=@"Scan your card";
        self.scantxt.textAlignment=NSTextAlignmentCenter;
        [self.scantxt setFont:[UIFont boldSystemFontOfSize:17.0]];
        [self.scanCardView addSubview:self.scantxt];
        self.scanCardView.layer.cornerRadius = 5;
        self.scanCardView.layer.masksToBounds = YES;
        UIImageView *scanImage =[[UIImageView alloc] initWithFrame:CGRectMake(12,5,40,40)];
        [scanImage setImage:[UIImage imageNamed:@"camera_bl.png"]];
        [self.scanCardView addSubview:scanImage];
        
        self.selCardImg=[[UIImageView alloc] initWithFrame:CGRectMake(25,145,40,30)];
        
        [self.topLayer addSubview:self.selCardImg];
        
        self.selCardNum=[[UILabel alloc] initWithFrame:CGRectMake(70,145,175,30)];
        self.selCardNum.textAlignment=NSTextAlignmentRight;
        self.selCardNum.textColor = [self.wnpCont getThemeBaseColor];
        txtFont = [self.selCardNum.font fontWithSize:16];
        self.selCardNum.font = txtFont;
        [self.topLayer addSubview:self.selCardNum];
        
        self.selectedCardExp=[[UILabel alloc] initWithFrame:CGRectMake(30,185,80,30)];
        self.selectedCardExp.textAlignment=NSTextAlignmentCenter;
        txtFont = [self.selectedCardExp.font fontWithSize:16];
        self.selectedCardExp.font = txtFont;
        self.selectedCardExp.textColor = [self.wnpCont getThemeBaseColor];
        [self.topLayer addSubview:self.selectedCardExp];
        
        self.selectedCardCVV=[[UILabel alloc] initWithFrame:CGRectMake(165,185,80,30)];
        self.selectedCardCVV.textAlignment=NSTextAlignmentCenter;
        self.selectedCardCVV.textColor = [self.wnpCont getThemeBaseColor];
        txtFont = [self.selectedCardCVV.font fontWithSize:16];
        self.selectedCardCVV.font = txtFont;
        [self.topLayer addSubview:self.selectedCardCVV];
        
        
        
        
        self.strpSubmitBtn = [[UIButton alloc] initWithFrame:CGRectMake(15,225,100,30)];
        self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
        [self.strpSubmitBtn setTitle: @"Submit" forState: UIControlStateNormal];
        self.strpSubmitBtn.userInteractionEnabled=TRUE;
        self.strpSubmitBtn.enabled=FALSE;
        [self.strpSubmitBtn addTarget:self action:@selector(submitStripePayment:) forControlEvents: UIControlEventTouchUpInside];
        
        [self.topLayer addSubview:self.strpSubmitBtn];
        
        self.strpCancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(155,225,100,30)];
        self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
        [self.strpCancelBtn setTitle: @"Cancel" forState: UIControlStateNormal];
        self.strpCancelBtn.userInteractionEnabled=TRUE;
        self.strpCancelBtn.enabled=TRUE;
        [self.strpCancelBtn addTarget:self action:@selector(cancelStripePayment:) forControlEvents: UIControlEventTouchUpInside];
        self.strpCancelBtn.enabled = TRUE;
         [self.topLayer addSubview:self.strpCancelBtn];
        UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBord)];
        viewTap.numberOfTapsRequired = 1;
        viewTap.numberOfTouchesRequired = 1;
        [self.self.topLayer setUserInteractionEnabled:YES];
        [self.self.topLayer addGestureRecognizer:viewTap];
        [self scanCard:nil];
        
    }else{
        self.resultText = nil;

        @try {
            self.trxnMdl = [self.cpnDAO addPrepaidBalance:[self.wnpCont getUserId] CoupunIds:self.selectedCouponIds CustomeCouponModel:self.customeCpnMdl StoreId:[self.wnpCont getSelectedStoreId] PayWith:@"Paypal"];
           
        }
        @catch (NSException *exception) {
            
            [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
        }
        
        NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:self.amountPayable.stringValue];
        
        PayPalPayment *payment = [[PayPalPayment alloc]init];
        payment.amount = total;
        payment.currencyCode = self.currencyCode;
        NSMutableString *desc = [[NSMutableString alloc]init];
        [desc appendString:@"(ios) Amount for prepaid recharge for user "];
        [desc appendString:[self.wnpCont getUserName]];
        
        payment.shortDescription = desc;
        payment.items = nil;  // if not including multiple items, then leave payment.items as nil
        payment.paymentDetails = nil;//paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
        
        if (!payment.processable) {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
        }
        
        // Update payPalConfig re accepting credit cards.
        self.payPalConfig.acceptCreditCards = YES;
        if([self.paypalEnv isEqualToString:@"live"]){
            [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction :self.paypalClientId}];
            [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
        }else{
            [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox :self.paypalClientId}];
            [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
        }
        
        PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment configuration:self.payPalConfig delegate:self];
        [self presentViewController:paymentViewController animated:YES completion:nil];
    }
    
}


- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    self.resultText = [completedPayment description];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.cpnDAO updatePrepaidToComplete:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] OrderId:self.trxnMdl.orderId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPrepaidData" object:nil];
    for(UIView *subViews in [self.parentViewController.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    NSLog(@"gggggg");
    [self cancelPrepaid:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
     [self.cpnDAO reAllocatePrepaid:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] OrderId:self.trxnMdl.orderId];
    self.view.alpha=1.0;
    self.resultText = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)cancelStripePayment:(id)sender {
    for(UIView *subViews in [self.topLayer subviews]){
       [subViews removeFromSuperview];
    }
    for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=TRUE;
    }
    [self.topLayer removeFromSuperview];
    self.view.alpha=1.0;
}

- (void)submitStripePayment:(id)sender {
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    self.strpSubmitBtn.userInteractionEnabled=FALSE;
    self.strpSubmitBtn.enabled=FALSE;
    
    self.strpCancelBtn.backgroundColor=[UIColor grayColor];
    self.strpCancelBtn.userInteractionEnabled=FALSE;
    self.strpCancelBtn.enabled=FALSE;

    STPAPIClient *strpClient = [[STPAPIClient alloc] initWithPublishableKey:self.strpPubKey];
    [Stripe setDefaultPublishableKey:self.strpPubKey];
    STPCardParams *strpcardParams = [[STPCardParams alloc]init];
    strpcardParams.cvc=self.ioCard.cvv;
    strpcardParams.number=self.ioCard.cardNumber;
    strpcardParams.expMonth=self.ioCard.expiryMonth;
    strpcardParams.expYear=self.ioCard.expiryYear;
    if (![Stripe defaultPublishableKey]) {
        NSError *error = [NSError errorWithDomain:StripeDomain code:STPInvalidRequestError userInfo:@{
                                                                                                      NSLocalizedDescriptionKey: @"Please specify a Stripe Publishable Key in Constants.m"}];
        NSLog(@"Please specify a Stripe Publishable Key in Constants.m");
        [self.delegate paymentViewController:self didFinish:error];
        for(UIView *subViews in [self.topLayer subviews]){
            [subViews removeFromSuperview];
        }
        for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
            subViews.alpha=1.0;
            subViews.userInteractionEnabled=TRUE;
        }
        [self.topLayer removeFromSuperview];
        self.view.alpha=1.0;
        return;
    }
    [strpClient createTokenWithCard:strpcardParams completion:^(STPToken *token, NSError *error) {
        if (error) {
            [self.delegate paymentViewController:self didFinish:error];
            for(UIView *subViews in [self.topLayer subviews]){
                [subViews removeFromSuperview];
            }
            for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
                subViews.alpha=1.0;
                subViews.userInteractionEnabled=TRUE;
            }
            [self.topLayer removeFromSuperview];
            self.view.alpha=1.0;
        }else{
            
            @try {
                self.trxnMdl = [self.cpnDAO addPrepaidBalance:[self.wnpCont getUserId] CoupunIds:self.selectedCouponIds CustomeCouponModel:self.customeCpnMdl StoreId:[self.wnpCont getSelectedStoreId] PayWith:@"Stripe"];
                
                
                
            }
            @catch (NSException *exception) {
                
                [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
            }
            @try {
                NSString *status= [self.strpDAO doStripePayment:self.amountPayable ID:@1 CardToken:token.tokenId Currency:@"usd" Description:[NSString stringWithFormat:@"%s%@","(ios) Prepaid recharge for user  ",[self.wnpCont getUserName]] IsDealerAccount:true];
               // if ([status isEqual:@"SUCCESS"]){
                [self.cpnDAO updatePrepaidToComplete:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] OrderId:self.trxnMdl.orderId];
                    for(UIView *subViews in [self.topLayer subviews]){
                        [subViews removeFromSuperview];
                    }
                    for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
                        subViews.alpha=1.0;
                        subViews.userInteractionEnabled=TRUE;
                    }
                    [self.topLayer removeFromSuperview];
                    self.view.alpha=1.0;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPrepaidData" object:nil];
                    [self cancelPrepaid:nil];
                //}else{
                //   [self.cpnDAO reAllocatePrepaid:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] OrderId:self.trxnMdl.orderId];
               // }
            }@catch (NSException *exception) {
                 [self.cpnDAO reAllocatePrepaid:[self.wnpCont getUserId] StoreId:[self.wnpCont getSelectedStoreId] OrderId:self.trxnMdl.orderId];
                [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
            }
        }
    }];
    ;
}
-(void)  selectCoupon:(UIGestureRecognizer *)recognizer {
    UIImageView *checkBox =(UIImageView *)recognizer.view;
    checkBox.userInteractionEnabled = true;
    CouponModel *cpnMdl =[self.prepaidCpnArray objectAtIndex:checkBox.tag];

    
    NSNumber *number = [NSNumber numberWithInt:(int)checkBox.tag];
    //if(CFArrayBSearchValues((__bridge CFArrayRef)self.selectedCouponRowNos, CFRangeMake(0, self.selectedCouponRowNos.count),
    //               (CFNumberRef)number, (CFComparatorFunction)CFNumberCompare, NULL)){
    if([self.selectedCouponRowNos containsObject:number]){
        [self.selectedCouponRowNos removeObject:number];
        [checkBox setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        self.amountPayable = [NSNumber numberWithDouble:(self.amountPayable.doubleValue - cpnMdl.couponPrice.doubleValue)];
        self.amountUsable = [NSNumber numberWithDouble:(self.amountUsable.doubleValue - cpnMdl.offeredAmount.doubleValue)];
    }else{
        [self.selectedCouponRowNos addObject:number];
        self.amountPayable = [NSNumber numberWithDouble:(self.amountPayable.doubleValue + cpnMdl.couponPrice.doubleValue)];
        self.amountUsable = [NSNumber numberWithDouble:(self.amountUsable.doubleValue + cpnMdl.offeredAmount.doubleValue)];
        [checkBox setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
    }
    self.totalPayableAmt.text=[NSString stringWithFormat:@"Payable amount %@%@",[self.wnpCont getCurrencySymbol],[self.nmbrFrmtr numberFromString:self.amountPayable.stringValue]];
    self.totalUsabeleAmt.text=[NSString stringWithFormat:@"Usable amount %@%@",[self.wnpCont getCurrencySymbol],[self.nmbrFrmtr numberFromString:self.amountUsable.stringValue]];
    if(self.selectedCouponRowNos.count>0){
        self.submitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
        self.submitBtn.enabled=true;
    }else{
        self.submitBtn.backgroundColor=[UIColor grayColor];
        self.submitBtn.enabled=false;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([textView isFirstResponder]) {
    }else{
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [self.parentViewController touchesBegan:touches withEvent:event];
}
-(void) hideKeyBord{
    [self.view endEditing:YES];
}
- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    self.ioCard=info;
    self.scanCardView.userInteractionEnabled=false;
    self.scantxt.text=@"Processing...";

    self.scantxt.alpha = 0;
    [UIView animateWithDuration:0.75 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        self.scantxt.alpha = 1;
    } completion:nil];
    self.strpSubmitBtn.enabled=true;
    self.strpSubmitBtn.userInteractionEnabled=true;
    self.strpSubmitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.selCardNum.text=info.cardNumber;
    self.selectedCardExp.text=[NSString stringWithFormat:@"%d/%d", (int)info.expiryMonth,(int) (info.expiryYear % 100)];
    self.selectedCardCVV.text=info.cvv;
    NSString *cardName = [CardIOCreditCardInfo displayStringForCardType:info.cardType usingLanguageOrLocale:@"en_US"];
    [self.selCardImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"cio_ic_%@.png",cardName.lowercaseString ]]];
    [self submitStripePayment:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"User cancelled scan");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self cancelStripePayment:nil];
}

- (IBAction)scanCard:(UITapGestureRecognizer *)sender {
    self.selCardNum.text=@"";
    self.selectedCardExp.text=@"";
    self.selectedCardCVV.text=@"";
    [self.selCardImg setImage:nil];
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    scanViewController.hideCardIOLogo=YES;
    [self presentViewController:scanViewController animated:YES completion:nil];
}
@end

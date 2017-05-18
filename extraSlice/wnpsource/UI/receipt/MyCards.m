//
//  MyCards.m
//  walkNPay
//
//  Created by Administrator on 03/02/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "MyCards.h"
#import "CouponDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
#import "DealerDAO.h"
#import "DealerModel.h"
#import "StripeCardModel.h"
#import "StripeDAO.h"
#import "Utilities.h"
#import "OrganizationModel.h"
#import "MenuController.h"
#import "StoreDAO.h"
#import "StoreSelector.h"
#import "CardIO.h"
#import "ESliceConstants.h"

@interface MyCards ()<CardIOPaymentViewControllerDelegate,UITextFieldDelegate>
@property (strong,nonatomic) CouponDAO *cpnDAO;
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(strong,nonatomic) ESliceConstants *eCont;
@property(strong,nonatomic) WnPUtilities *utils;
@property(strong,nonatomic) Utilities *eUtils;
@property(strong,nonatomic) NSMutableArray *cardArray;
@property(strong,nonatomic) NSMutableArray *OtherCardArray;
@property(nonatomic) BOOL *subscriptionBySameUser;
@property(strong,nonatomic) NSString *custId;
@property(strong,nonatomic) NSString *stripeApiKey;
@property(nonatomic) BOOL *haveSubscription;
@property(nonatomic) BOOL *haveMemberSubscription;
@property(nonatomic) BOOL *havePermission;
@property (strong,nonatomic) UIView *popup;
@property(strong,nonatomic) UILabel *popupError;
@property(strong,nonatomic) UIButton *strpSubmitBtn;
@property(strong,nonatomic) UIButton *strpCancelBtn;
@property(strong,nonatomic) UILabel *cardLabel;
@property(strong,nonatomic) UITableView *selCardTable;
@property(strong,nonatomic) NSString *selectedCardId;
@property(nonatomic) BOOL *cardTableExpanded;
@property(nonatomic) BOOL *subsChecked;
@property(nonatomic) BOOL *addToSubscription;
@property(nonatomic) UIImageView *subscriptionChBox;
@property(strong,nonatomic) UILabel *headerLbl;
@property(strong,nonatomic) UIView *changeSubsView;
@property(strong,nonatomic) UIView *scanCardView;

@property(nonatomic) UIImageView *selCardImg;
@property(strong,nonatomic) UILabel *selCardNum;
@property(strong,nonatomic) UILabel *selectedCardExp;
@property(strong,nonatomic) UILabel *selectedCardCVV;
@property(strong,nonatomic) UILabel *scantxt;
@property(strong,nonatomic) StoreDAO *storeDao;
@property(strong,nonatomic) CardIOCreditCardInfo *ioCard;
@end

@implementation MyCards

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cpnDAO=[[CouponDAO alloc]init];
    self.wnpCont=[[WnPConstants alloc]init];
    self.eCont=[[ESliceConstants alloc]init];
    self.utils=[[WnPUtilities alloc]init];
    self.cardArray=[[NSMutableArray alloc]init];
    self.OtherCardArray=[[NSMutableArray alloc]init];
    self.storeDao = [[StoreDAO alloc]init];
    self.eUtils =[[Utilities alloc]init];
    self.seperator1.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.seperator2.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.seperator3.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.cardHeader.textColor=[self.wnpCont getThemeBaseColor];
    self.prepaidHeader.textColor=[self.wnpCont getThemeBaseColor];
    self.selectedCardId=nil;
    self.cardTableExpanded=false;
    self.subsChecked=FALSE;
    self.addToSubscription=FALSE;
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.rechargeLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Recharge" attributes:underlineAttribute];
    UITapGestureRecognizer *linkTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    linkTap.numberOfTapsRequired = 1;
    linkTap.numberOfTouchesRequired = 1;
    [self.rechargeLabel setUserInteractionEnabled:YES];
    [self.rechargeLabel addGestureRecognizer:linkTap];
    self.rechargeLabel.textColor=[self.wnpCont getThemeBaseColor];
    [self showStoreSelectionPopup:FALSE];
    @try{
        NSNumber *prepaidBal=[self.cpnDAO getPrepaidBalance:[self.wnpCont getUserId]];
        self.availableLabel.text = [NSString stringWithFormat:@"%s%@%@","Available balance ",[self.wnpCont getCurrencySymbol],[self.utils getNumberFormatter:prepaidBal.doubleValue]];;
    }
    @catch (NSException *exception) {
        self.availableLabel.text = [NSString stringWithFormat:@"%s%@%s","Available balance ",[self.wnpCont getCurrencySymbol],"00.00"];
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
    @try{
        StripeDAO *strpDAO =[[StripeDAO alloc]init];
        NSDictionary *cardRes = [strpDAO getStripeCardsForUser:[self.eUtils getLoggedinUser].userId];
        if([@"SUCCESS"  isEqual: [cardRes objectForKey:@"STATUS"]]){
            NSNumber* subscriptionBySameUserInt = [cardRes objectForKey:@"subscriptionBySameUser"];
            if ([subscriptionBySameUserInt boolValue] == YES){
                self.subscriptionBySameUser =YES;
            }
            NSNumber* haveMemberSubscriptionInt = [cardRes objectForKey:@"haveMemberSubscription"];
            if ([haveMemberSubscriptionInt boolValue] == YES){
                self.haveMemberSubscription =YES;
            }
            NSNumber* haveSubscriptionInt = [cardRes objectForKey:@"haveSubscription"];
            if ([haveSubscriptionInt boolValue] == YES){
                self.haveSubscription =YES;
            }
            NSNumber* havePermissionInt = [cardRes objectForKey:@"havePermission"];
            if ([havePermissionInt boolValue] == YES){
                self.havePermission =YES;
            }
            self.custId = [cardRes objectForKey:@"custId"];
            self.stripeApiKey = [self.eUtils decode:[cardRes objectForKey:@"strpPubKey"]];
           

            NSArray *userCards=[cardRes objectForKey:@"cardList"];
            for(NSDictionary *cardItem in userCards){
                StripeCardModel *trxnModel = [[StripeCardModel alloc]init];
                trxnModel=[trxnModel initWithDictionary:cardItem];
                [self.cardArray addObject:trxnModel];
                if(!trxnModel.defaultCard){
                    [self.OtherCardArray addObject:trxnModel];
                }
                
                
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    
    int expTabHeight=self.cardArray.count*38;
    if((screenRect.size.height - 260)  < expTabHeight){
        expTabHeight=(screenRect.size.height - 260);
    }
    self.cardTableHt.constant=expTabHeight;
    if([[self.eUtils getLoggedinUser].userType.uppercaseString isEqualToString:@"MEMBER"]){
        if(self.havePermission && !self.haveMemberSubscription){
            self.addSubsLabel.hidden=false;
        }else{
            self.addSubsLabel.hidden=true;
        }
        NSDictionary *attrs =@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[self.eUtils getThemeDarkBlue],NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid),NSUnderlineColorAttributeName:[self.eUtils getThemeDarkBlue] };
        NSDictionary *subAttrs =@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
        NSString *str = @"You do not have a payment set up for membership subscription. Do you want to set up now ? Set up";
        NSRange theRange = NSMakeRange(str.length-6,6);
        NSMutableAttributedString *tcurl=[[NSMutableAttributedString alloc]initWithString:str attributes:subAttrs];
        [tcurl setAttributes:attrs range:theRange];
        self.addSubsLabel.attributedText = tcurl;
        UITapGestureRecognizer *addSubTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(addNewSubscription:)];
        addSubTap.numberOfTapsRequired = 1;
        addSubTap.numberOfTouchesRequired = 1;
        [self.addSubsLabel setUserInteractionEnabled:YES];
        [self.addSubsLabel addGestureRecognizer:addSubTap];
    }else{
        self.addSubsLabel.hidden=true;
    }
    
    
    UITapGestureRecognizer *addNewCardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(addNewCard:)];
    addNewCardTap.numberOfTapsRequired = 1;
    addNewCardTap.numberOfTouchesRequired = 1;
    [self.addNewCard setUserInteractionEnabled:YES];
    [self.addNewCard addGestureRecognizer:addNewCardTap];

    self.cardTable.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    self.cardTable.delegate = self;
    self.cardTable.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) tapDetected:(UIGestureRecognizer *)recognizer{
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
       // [dashboardView setFrame:CGRectMake(self.view.bounds.origin.x-155,self.view.bounds.origin.x-180,310,360)];
       // viewController.prepaidpoupheight.constant = 300;
    
        [self.view addSubview:dashboardView];
        [self addChildViewController:viewController];
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=0.2;
            [subViews setUserInteractionEnabled:NO];
        }
        
        for(UIView *subViews in [self.parentViewController.view subviews]){
            if ([subViews isKindOfClass:[UILabel class]]) {
                subViews.alpha=0.2;
                [subViews setUserInteractionEnabled:NO];
            }
           
        }
    
        dashboardView.alpha=1;
        [dashboardView setUserInteractionEnabled:YES];
        //dashboardView.center = self.view.center;
        dashboardView.center = CGPointMake(self.view.center.x, self.view.center.y-100);
    }@catch (NSException *exception) {
        self.view.backgroundColor=[UIColor whiteColor];
        self.availableLabel.text = [NSString stringWithFormat:@"%s%@%s","Available balance ",[self.wnpCont getCurrencySymbol],"00.00"];
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
}

- (void) refreshPrepaidData{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshPrepaidData" object:nil];
    @try{
        NSNumber *prepaidBal=[self.cpnDAO getPrepaidBalance:[self.wnpCont getUserId]];
        self.availableLabel.text = [NSString stringWithFormat:@"%s%@%@","Available balance ",[self.wnpCont getCurrencySymbol],prepaidBal.stringValue];;
    }
    @catch (NSException *exception) {
        self.availableLabel.text = [NSString stringWithFormat:@"%s%@%s","Available balance ",[self.wnpCont getCurrencySymbol],"00.00"];
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.cardTable]) {
        return self.cardArray.count;
    }else{
        return self.OtherCardArray.count+1;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *celId =@"Cell";
    UITableViewCell *cell = nil;
    if ([tableView isEqual:self.cardTable]) {
        StripeCardModel *trxnModel=[self.cardArray objectAtIndex:indexPath.item];
        if(trxnModel !=nil){
            if(cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGFloat tableWidth = screenRect.size.width-10;
                UILabel *cardNo = [[UILabel alloc] initWithFrame:CGRectMake(2, 2 , (tableWidth*0.3), 34)];
                UIFont *txtFont = [cardNo.font fontWithSize:15.0];
                cardNo.font = txtFont;
                cardNo.text=[NSString stringWithFormat:@"%s%@","XXXXXXXXXXXX",trxnModel.last4];
                [cell addSubview:cardNo];
                UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(4+(tableWidth*0.3), 2 , (tableWidth*0.3), 34)];
                name.font = txtFont;
                if(trxnModel.name != (id)[NSNull null] && trxnModel.name != nil){
                    name.text=trxnModel.name ;
                }
                
                [cell addSubview:name];
                if([[self.eUtils getLoggedinUser].userType.uppercaseString isEqualToString:@"MEMBER"]){
                    if(trxnModel.defaultCard){
                        UIImageView *defimg = [[UIImageView alloc] initWithFrame:CGRectMake(10+(tableWidth*0.6), 6 , 26, 26)];
                        [defimg setImage:[UIImage imageNamed:@"about12.png"]];
                        [cell addSubview:defimg];
                        UITapGestureRecognizer *defCardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(openDefCard:)];
                        defCardTap.numberOfTapsRequired = 1;
                        defCardTap.numberOfTouchesRequired = 1;
                        defimg.tag=indexPath.item;
                        [defimg setUserInteractionEnabled:YES];
                        [defimg addGestureRecognizer:defCardTap];
                        self.changeSubsView= [[UIView alloc] initWithFrame:CGRectMake(10, (41+(38*(indexPath.item+1))) , tableWidth-10, 60)];
                        [self.view addSubview:self.changeSubsView];
                        self.changeSubsView.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
                        self.changeSubsView.layer.borderWidth = 1.0f;
                        self.changeSubsView.hidden=true;
                        UILabel *chngeTxt =[[UILabel alloc] initWithFrame:CGRectMake(5, 0 , tableWidth-90, 60)];
                        NSDictionary *attrs =@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[self.eUtils getThemeDarkBlue],NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid),NSUnderlineColorAttributeName:[self.eUtils getThemeDarkBlue] };
                        NSDictionary *subAttrs =@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
                        NSString *str = nil;
                        if(self.haveMemberSubscription){
                            str = @"Card used for all subscription. Do you want to change? Change";
                        }else{
                            str = @"Card used for conference subscription. Do you want to change? Change";
                        }
                        NSRange theRange = NSMakeRange(str.length-6,6);
                        NSMutableAttributedString *tcurl=[[NSMutableAttributedString alloc]initWithString:str attributes:subAttrs];
                        [tcurl setAttributes:attrs range:theRange];
                        chngeTxt.attributedText = tcurl;
                        chngeTxt.textAlignment=NSTextAlignmentCenter;
                        chngeTxt.numberOfLines=-1;

                        UILabel *closeChange =[[UILabel alloc] initWithFrame:CGRectMake(tableWidth-85, 0 , 70, 30)];
                        closeChange.text=@"Cancel";
                        [closeChange setFont:[UIFont boldSystemFontOfSize:16.0]];
                        closeChange.textColor=[self.wnpCont getThemeBaseColor];
                        closeChange.textAlignment=NSTextAlignmentRight;

                        [self.changeSubsView addSubview:chngeTxt];
                        [self.changeSubsView addSubview:closeChange];
                    
                        UITapGestureRecognizer *chngeTxtTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeDefCard:)];
                        chngeTxtTap.numberOfTapsRequired = 1;
                        chngeTxtTap.numberOfTouchesRequired = 1;
                        chngeTxt.tag=indexPath.item;
                        [chngeTxt setUserInteractionEnabled:YES];
                        [chngeTxt addGestureRecognizer:chngeTxtTap];
                    
                        UITapGestureRecognizer *closeChangeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(closeDefCard:)];
                        closeChangeTap.numberOfTapsRequired = 1;
                        closeChangeTap.numberOfTouchesRequired = 1;
                        closeChange.tag=indexPath.item;
                        [closeChange setUserInteractionEnabled:YES];
                        [closeChange addGestureRecognizer:closeChangeTap];
                    }
                    
                }
                
               
                if(self.cardArray.count > 1){
                    UIImageView *delImg = [[UIImageView alloc] initWithFrame:CGRectMake(10+(tableWidth*0.9)+4, 6 , 26, 26)];
                    [delImg setImage:[UIImage imageNamed:@"delete.png"]];
                    [cell addSubview:delImg];
                    UITapGestureRecognizer *delCardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(deleteCard:)];
                    delCardTap.numberOfTapsRequired = 1;
                    delCardTap.numberOfTouchesRequired = 1;
                    delImg.tag=indexPath.item;
                    [delImg setUserInteractionEnabled:YES];
                    [delImg addGestureRecognizer:delCardTap];
                }
                UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 37 , tableWidth, 1)];
                [seperator setBackgroundColor:[self.wnpCont getThemeHeaderColor]];
                [cell addSubview:seperator];
                self.cardTable.rowHeight=38;
                
            }
        }
    }else{
        if(indexPath.item ==0){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
            UILabel *cardNo = [[UILabel alloc] initWithFrame:CGRectMake(2, 2 , 196, 34)];
            UIFont *txtFont = [cardNo.font fontWithSize:15.0];
            cardNo.font = txtFont;
            cardNo.text=@"Select card";
            [cell addSubview:cardNo];
            
        }else{
            StripeCardModel *trxnModel=[self.OtherCardArray objectAtIndex:indexPath.item-1];
            if(trxnModel !=nil){
                if(cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
                    UILabel *cardNo = [[UILabel alloc] initWithFrame:CGRectMake(2, 2 , 196, 34)];
                    UIFont *txtFont = [cardNo.font fontWithSize:15.0];
                    cardNo.font = txtFont;
                    cardNo.text=[NSString stringWithFormat:@"%s%@","XXXXXXXXXXXX",trxnModel.last4];
                    [cell addSubview:cardNo];
                }
            }
        }
        self.cardTable.rowHeight=38;
        UITapGestureRecognizer *selCardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectACard:)];
        selCardTap.numberOfTapsRequired = 1;
        selCardTap.numberOfTouchesRequired = 1;
        cell.tag=indexPath.item;
        [cell setUserInteractionEnabled:YES];
        [cell addGestureRecognizer:selCardTap];
        
    }
    return cell;
}
-(void) addNewSubscription:(UIGestureRecognizer *)recognizer{
    [self showStripePopup:@"ADDNEWSUBSCRIPTION"];
}

-(void) addNewCard:(UIGestureRecognizer *)recognizer{
    [self showStripePopup:@"ADDNEWCARD"];
}
-(void) checkSubscription:(UIGestureRecognizer *)recognizer{
    if(self.subsChecked){
        self.subsChecked=false;
        [self.subscriptionChBox setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
    }else{
        self.subsChecked=true;
        [self.subscriptionChBox setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
    }
}
-(void) selectCard:(UIGestureRecognizer *)recognizer{
    if(self.cardTableExpanded){
        self.cardTableExpanded=false;
        
        for(UIView *subViews in [self.popup subviews]){
            subViews.alpha=1.0;
            subViews.userInteractionEnabled=true;
        }
        self.selCardTable.hidden=true;
    }else{
        self.cardTableExpanded=true;
        for(UIView *subViews in [self.popup subviews]){
            if ([subViews isEqual:self.selCardTable] || [subViews isEqual:self.cardLabel] ||[subViews isEqual:self.headerLbl]) {
                continue;
            }
            subViews.alpha=0.2;
            subViews.userInteractionEnabled=false;
        }
        self.selCardTable.hidden=false;
    }
}
-(void) selectACard:(UIGestureRecognizer *)recognizer{
     int index = (int)recognizer.view.tag;
    if(index==0){
         self.cardLabel.text=@"Select card";
        self.selectedCardId=nil;
        self.scanCardView.hidden=false;
        self.strpSubmitBtn.enabled=false;
        self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    }else{
        StripeCardModel *trxnModel=[self.OtherCardArray objectAtIndex:index-1];
        self.cardLabel.text=[NSString stringWithFormat:@"%s%@","XXXXXXXXXXXX",trxnModel.last4];
        self.selectedCardId=trxnModel.cardId;
        self.scanCardView.hidden=true;
        self.strpSubmitBtn.enabled=true;
        self.strpSubmitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    }
    [self selectCard:recognizer];
}

-(void) openDefCard:(UIGestureRecognizer *)recognizer{
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    self.view.backgroundColor=[UIColor grayColor];
    self.changeSubsView.alpha=1.0;
    self.changeSubsView.userInteractionEnabled=true;
    self.changeSubsView.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.changeSubsView subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
    
    self.changeSubsView.hidden=false;
}
-(void) closeDefCard:(UIGestureRecognizer *)recognizer{
    self.changeSubsView.hidden=true;
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
    self.view.backgroundColor=[UIColor whiteColor];
}
-(void) changeDefCard:(UIGestureRecognizer *)recognizer{
     [self closeDefCard:recognizer];
    [self showStripePopup:@"CHANGESUBSCRIPTION"];
   
}
-(void) deleteCard:(UIGestureRecognizer *)recognizer{
    int index = recognizer.view.tag;
    StripeCardModel *model = [self.cardArray objectAtIndex:index];
    @try{
        StripeDAO *strpDAO =[[StripeDAO alloc]init];
        NSDictionary *result =[strpDAO deleteCard:[self.eUtils getLoggedinUser].userId CustId:self.custId TokenId:model.cardId];
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
        MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
        if(viewCtrl != nil){
            viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
            viewCtrl.viewName=@"Wallet";
            [self presentViewController:viewCtrl animated:YES completion:nil];
        }

    }@catch(NSException *e){
        
    }
}


-(void) showStripePopup:(NSString *)purpose
{
    
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-20;
    self.view.backgroundColor=[UIColor grayColor];
   // float centerX = self.view.center.x;
    float centerY = (screenRect.size.height)/2;
    
    //self.view.userInteractionEnabled=false;
    self.popup=[[UIView alloc] initWithFrame:CGRectMake((tableWidth/2)-135,centerY-175-65,270,350)];
    self.popup.backgroundColor = [UIColor whiteColor];
    self.popup.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.popup.layer.borderWidth = 1.0f;
    self.popup.alpha=1.0;
    [self.view addSubview:self.popup];
    
    self.headerLbl=[[UILabel alloc] initWithFrame:CGRectMake(0,0,270,35)];
    self.headerLbl.text=@"Stripe payment gateway";
    self.headerLbl.textAlignment=NSTextAlignmentCenter;
    UIFont *txtFont = [self.headerLbl.font fontWithSize:16];
    self.headerLbl.font = txtFont;
    self.headerLbl.textColor=[UIColor whiteColor];
    self.headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.popup addSubview:self.headerLbl];
    
    self.popupError = [[UILabel alloc] initWithFrame:CGRectMake(5, 40 , 260, 60)];
    self.popupError.hidden=true;
    self.popupError.textColor=[UIColor redColor];
    [self.popup addSubview: self.popupError];
    if(![purpose isEqualToString:@"ADDNEWCARD"] && self.OtherCardArray.count > 0){
        self.cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 40 , 200, 30)];
        self.cardLabel.text=@"Select card";
        self.cardLabel.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
        self.cardLabel.layer.borderWidth = 1.0f;
        [self.popup addSubview: self.cardLabel];
        
        UITapGestureRecognizer *selCardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectCard:)];
        selCardTap.numberOfTapsRequired = 1;
        selCardTap.numberOfTouchesRequired = 1;
        self.cardLabel.tag=0;
        [self.cardLabel setUserInteractionEnabled:YES];
        [self.cardLabel addGestureRecognizer:selCardTap];
        
        self.selCardTable = [[UITableView alloc] initWithFrame:CGRectMake(35, 70 , 200, 100)];
        self.selCardTable.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
        self.selCardTable.layer.borderWidth = 1.0f;
        [self.popup addSubview: self.selCardTable];
        self.selCardTable.hidden=true;

    }else{
        [self scanCard:nil];
        
    }
    
    
    self.scanCardView = [[UIView alloc] initWithFrame:CGRectMake(25,105,220,50)];


    [self.popup addSubview:self.scanCardView];
    UITapGestureRecognizer *scanCardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(scanCard:)];
    scanCardTap.numberOfTapsRequired = 1;
    scanCardTap.numberOfTouchesRequired = 1;
    [self.scanCardView setUserInteractionEnabled:YES];
    [self.scanCardView addGestureRecognizer:scanCardTap];
    self.scanCardView.layer.borderColor= [self.wnpCont getThemeBaseColor].CGColor;
    self.scanCardView.layer.borderWidth = 1.0f;
    self.scanCardView.backgroundColor=[self.eCont getThemeColorWithTransparency:0.2];
    self.scantxt =[[UILabel alloc] initWithFrame:CGRectMake(57,5,150,40)];
    self.scantxt.text=@"Scan your card";
    self.scantxt.textAlignment=NSTextAlignmentCenter;
    [self.scantxt setFont:[UIFont boldSystemFontOfSize:17.0]];
    [self.scanCardView addSubview:self.scantxt];
    self.scanCardView.layer.cornerRadius = 5;
    self.scanCardView.layer.masksToBounds = YES;
    UIImageView *scanImage =[[UIImageView alloc] initWithFrame:CGRectMake(12,5,40,40)];
    [scanImage setImage:[UIImage imageNamed:@"camera_bl.png"]];
    [self.scanCardView addSubview:scanImage];
    
    self.selCardImg=[[UIImageView alloc] initWithFrame:CGRectMake(25,175,40,30)];
    
    [self.popup addSubview:self.selCardImg];
    
    self.selCardNum=[[UILabel alloc] initWithFrame:CGRectMake(70,175,175,30)];
    self.selCardNum.textAlignment=NSTextAlignmentRight;
    self.selCardNum.textColor = [self.wnpCont getThemeBaseColor];
    txtFont = [self.selCardNum.font fontWithSize:16];
    self.selCardNum.font = txtFont;
    [self.popup addSubview:self.selCardNum];
    
    self.selectedCardExp=[[UILabel alloc] initWithFrame:CGRectMake(30,210,80,30)];
    self.selectedCardExp.textAlignment=NSTextAlignmentCenter;
    txtFont = [self.selectedCardExp.font fontWithSize:16];
    self.selectedCardExp.font = txtFont;
    self.selectedCardExp.textColor = [self.wnpCont getThemeBaseColor];
    [self.popup addSubview:self.selectedCardExp];
    
    self.selectedCardCVV=[[UILabel alloc] initWithFrame:CGRectMake(165,210,80,30)];
    self.selectedCardCVV.textAlignment=NSTextAlignmentCenter;
    self.selectedCardCVV.textColor = [self.wnpCont getThemeBaseColor];
    txtFont = [self.selectedCardCVV.font fontWithSize:16];
    self.selectedCardCVV.font = txtFont;
    [self.popup addSubview:self.selectedCardCVV];
    
    
    
    if([purpose isEqualToString:@"ADDNEWCARD"]){
        if(self.havePermission){
            self.subscriptionChBox = [[UIImageView alloc] initWithFrame:CGRectMake(15,245,20,20)];
            [self.subscriptionChBox setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
            [self.popup addSubview:self.subscriptionChBox];
            UITapGestureRecognizer *chBoxTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(checkSubscription:)];
            chBoxTap.numberOfTapsRequired = 1;
            chBoxTap.numberOfTouchesRequired = 1;
            [self.subscriptionChBox setUserInteractionEnabled:YES];
            [self.subscriptionChBox addGestureRecognizer:chBoxTap];
            
            UILabel *descLabel =[[UILabel alloc] initWithFrame:CGRectMake(45,225,220,60)];
            if(!self.haveMemberSubscription){
                descLabel.text=@"You do not have set up membership subscription. Do you wnat to set up using this card";
            }else{
                descLabel.text=@"Do you wnat to use this card for all subscriptions";
            }
            
            descLabel.textAlignment=NSTextAlignmentLeft;
            descLabel.numberOfLines=-1;
            descLabel.font = txtFont;
            descLabel.textColor=[UIColor blackColor];
            [self.popup addSubview:descLabel];
        }
        
    }else{
        if(self.havePermission){
            self.subsChecked =true;
        }
    }
    
    

    
    self.strpSubmitBtn = [[UIButton alloc] initWithFrame:CGRectMake(15,315,100,30)];
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    [self.strpSubmitBtn setTitle: @"Submit" forState: UIControlStateNormal];
    self.strpSubmitBtn.userInteractionEnabled=TRUE;
    self.strpSubmitBtn.enabled=FALSE;
    [self.strpSubmitBtn addTarget:self action:@selector(submitStripeCard:) forControlEvents: UIControlEventTouchUpInside];
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    
    [self.popup addSubview:self.strpSubmitBtn];
    
    self.strpCancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(155,315,100,30)];
    self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.strpCancelBtn.userInteractionEnabled=TRUE;
    self.strpCancelBtn.enabled=TRUE;
    [self.strpCancelBtn setTitle: @"Cancel" forState: UIControlStateNormal];
    [self.strpCancelBtn addTarget:self action:@selector(cancelStripeCard:) forControlEvents: UIControlEventTouchUpInside];
    [self.popup addSubview:self.strpCancelBtn];
    
    
    self.selCardTable.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    self.selCardTable.delegate = self;
    self.selCardTable.dataSource = self;
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
- (IBAction)submitStripeCard:(id)sender {
    self.popupError.text= @"";
    self.popupError.hidden=true;
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    self.strpSubmitBtn.userInteractionEnabled=FALSE;
    self.strpSubmitBtn.enabled=FALSE;
    BOOL newcard =FALSE;
    self.scanCardView.userInteractionEnabled=false;
    self.scantxt.text=@"Processing...";
    
    self.scantxt.alpha = 0;
    [UIView animateWithDuration:0.75 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        self.scantxt.alpha = 1;
    } completion:nil];
    self.strpCancelBtn.backgroundColor=[UIColor grayColor];
    self.strpCancelBtn.userInteractionEnabled=FALSE;
    self.strpCancelBtn.enabled=FALSE;
    STPCardParams *strpcardParams = [[STPCardParams alloc]init];
    if(self.custId==nil || self.selectedCardId == nil){
        newcard =TRUE;
        if(self.stripeApiKey == (id)[NSNull null] || self.stripeApiKey == nil){
            self.popupError.text= @"Invalid Stripe  account";
            self.popupError.hidden=false;
            self.scanCardView.userInteractionEnabled=true;
            [self.scantxt.layer removeAllAnimations];
            self.scantxt.text=@"Scan you card";
            self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
            // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
            
            self.strpCancelBtn.userInteractionEnabled=TRUE;
            self.strpCancelBtn.enabled=TRUE;
            return;

        }
        
        
        @try{
            STPAPIClient *strpClient = [[STPAPIClient alloc] initWithPublishableKey:self.stripeApiKey];
            [Stripe setDefaultPublishableKey:self.stripeApiKey];

            strpcardParams.cvc=self.ioCard.cvv;
            strpcardParams.number=self.ioCard.cardNumber;
            strpcardParams.expMonth=self.ioCard.expiryMonth;
            strpcardParams.expYear=self.ioCard.expiryYear;
            
            if (![Stripe defaultPublishableKey]) {
                
                self.popupError.text= @"Invalid key";
                self.popupError.hidden=false;
                self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
                self.scanCardView.userInteractionEnabled=true;
                [self.scantxt.layer removeAllAnimations];
                self.scantxt.text=@"Scan you card";
                self.strpCancelBtn.userInteractionEnabled=TRUE;
                self.strpCancelBtn.enabled=TRUE;
                return;
            }
            
            [strpClient createTokenWithCard:strpcardParams completion:^(STPToken *token, NSError *error) {
                if (error) {
                    self.popupError.text= error.description;
                    self.popupError.hidden=false;
                    self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
                    self.scanCardView.userInteractionEnabled=true;
                    [self.scantxt.layer removeAllAnimations];
                    self.scantxt.text=@"Scan you card";
                    self.strpCancelBtn.userInteractionEnabled=TRUE;
                    self.strpCancelBtn.enabled=TRUE;
                    return;
                }else{
                    @try{
                      
                        StripeDAO *strpDAO =[[StripeDAO alloc]init];
                        BOOL defCard = FALSE;
                        if(self.custId != nil && self.subsChecked){
                            defCard =TRUE;
                        }
                        UserModel *uModel=[self.eUtils getLoggedinUser];
                        OrganizationModel *orgModel=[[OrganizationModel alloc]init];
                        NSNumber *orgId= [NSNumber numberWithInt:-1];
                        if(uModel.orgList != (id)[NSNull null] && uModel.orgList != nil && uModel.orgList.count>0){
                            orgModel =[orgModel initWithDictionary:[uModel.orgList objectAtIndex:0]];
                            orgId = orgModel.orgId;
                        }
                       
                        
                            NSDictionary *result =[strpDAO addCustomerAndCard:uModel.userId Email:uModel.userName CustId:self.custId TokenId:token.tokenId NewCard:newcard DefaultCard:defCard];
                            NSLog(@"%@",result);
                            if(self.subsChecked && !self.haveMemberSubscription){
                                [strpDAO updateStripeCustomerForUser:uModel.userId OrgId:orgId];
                            }
                            [self.popup removeFromSuperview];
                            for(UIView *subViews in self.view.subviews){
                                subViews.alpha=1.0;
                                subViews.userInteractionEnabled=TRUE;
                            }
                            self.view.alpha=1.0;
                            self.view.userInteractionEnabled=TRUE;
                            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
                            MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
                            if(viewCtrl != nil){
                                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                                viewCtrl.viewName=@"Wallet";
                                [self presentViewController:viewCtrl animated:YES completion:nil];
                            }
                            
            
                    }
                    @catch (NSException *exception) {
                        self.popupError.text= exception.description;
                        self.popupError.hidden=false;
                        self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
                        self.scanCardView.userInteractionEnabled=true;
                        [self.scantxt.layer removeAllAnimations];
                        self.scantxt.text=@"Scan you card";
                        self.strpCancelBtn.userInteractionEnabled=TRUE;
                        self.strpCancelBtn.enabled=TRUE;
                        
                        self.strpCancelBtn.userInteractionEnabled=TRUE;
                        self.strpCancelBtn.enabled=TRUE;
                    }
                }
            }];
        }@catch(NSException *exception) {
            self.popupError.text= exception.description;
            self.popupError.hidden=false;
            self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
            self.strpCancelBtn.userInteractionEnabled=TRUE;
            self.strpCancelBtn.enabled=TRUE;
            self.scanCardView.userInteractionEnabled=true;
            [self.scantxt.layer removeAllAnimations];
            self.scantxt.text=@"Scan you card";
            return;
            
        }

    }else{
        StripeDAO *strpDAO =[[StripeDAO alloc]init];
        BOOL defCard = FALSE;
        if(self.subsChecked){
            defCard =TRUE;
        }
        UserModel *uModel=[self.eUtils getLoggedinUser];
        OrganizationModel *orgModel=[[OrganizationModel alloc]init];
        orgModel =[orgModel initWithDictionary:[uModel.orgList objectAtIndex:0]];
        @try{
            NSDictionary *result =[strpDAO addCustomerAndCard:uModel.userId Email:uModel.userName CustId:self.custId TokenId:self.selectedCardId NewCard:newcard DefaultCard:defCard];
            NSLog(@"%@",result);
            if(self.subsChecked && !self.haveMemberSubscription){
                [strpDAO updateStripeCustomerForUser:uModel.userId OrgId:orgModel.orgId];
            }
            [self.popup removeFromSuperview];
            for(UIView *subViews in self.view.subviews){
                subViews.alpha=1.0;
                subViews.userInteractionEnabled=TRUE;
            }
            self.view.alpha=1.0;
            self.view.userInteractionEnabled=TRUE;
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
            MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
            if(viewCtrl != nil){
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                viewCtrl.viewName=@"Wallet";
                [self presentViewController:viewCtrl animated:YES completion:nil];
            }
            
        }@catch(NSException *e){
            self.popupError.text= e.description;
            self.popupError.hidden=false;
            self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
            self.strpCancelBtn.userInteractionEnabled=TRUE;
            self.strpCancelBtn.enabled=TRUE;
            self.scanCardView.userInteractionEnabled=true;
            [self.scantxt.layer removeAllAnimations];
            self.scantxt.text=@"Scan you card";
            return;
            
        }
    }
 
}

- (IBAction)cancelStripeCard:(id)sender {
    [self.popup removeFromSuperview];
    for(UIView *subViews in self.view.subviews){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=TRUE;
    }
    self.view.backgroundColor=[UIColor whiteColor];
    self.view.alpha=1.0;
    self.view.userInteractionEnabled=TRUE;
}

- (void) showStoreSelectionPopup:(BOOL ) forcePopup{
    NSArray *storeArray = [[NSArray alloc]init];
    NSString *error=nil;
    BOOL showPopup=false;
    @try {
        storeArray = [self.storeDao  getAllStoresForDealerByLocation:@1];
        [self.wnpCont setNumberOfStores:[NSNumber numberWithInt:(int)(storeArray.count)]];
        if (storeArray == nil || storeArray.count ==0) {
            error=@"No store found";
            showPopup=false;
            if(forcePopup){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No stores found" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                
                [alert show];
            }
        }else if(storeArray.count ==1){
            StoreModel *strMdl = [storeArray objectAtIndex:0];
            [self.wnpCont setSelectedStoreId:strMdl.storeId];
            [self.wnpCont setCurrencyCode:strMdl.currencyCode];
            [self.wnpCont setCurrencySymbol:strMdl.currencySymbol];
            showPopup=false;
        }else{
            if(forcePopup){
                showPopup=true;
            }
        }
    }
    @catch (NSException *exception) {
        if(forcePopup){
            showPopup=true;
            error=exception.description;
        }
        
    }
    if(showPopup){
        self.view.backgroundColor=[UIColor grayColor];
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=0.2;
        }
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"StoreSelector" bundle:nil];
        StoreSelector *viewController=[stryBrd instantiateViewControllerWithIdentifier:@"StoreSelector"];
        viewController.errorText=error;
        viewController.storeArray=storeArray;
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        [self.view bringSubviewToFront:viewController.view];
        [viewController.view setUserInteractionEnabled:YES];
        viewController.view.center = self.view.center;
        for(UIView *uisv in [viewController.view subviews]){
            [uisv setUserInteractionEnabled:YES];
        }
    }else{
        
    }
}
- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    self.ioCard=info;
    self.strpSubmitBtn.enabled=true;
    self.strpSubmitBtn.userInteractionEnabled=true;
    self.strpSubmitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.selCardNum.text=info.cardNumber;
    self.selectedCardExp.text=[NSString stringWithFormat:@"%d/%d", (int)info.expiryMonth,(int) (info.expiryYear % 100)];
    self.selectedCardCVV.text=info.cvv;
    
    

    NSString *cardName = [CardIOCreditCardInfo displayStringForCardType:info.cardType usingLanguageOrLocale:@"en_US"];
    [self.selCardImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"cio_ic_%@.png",cardName.lowercaseString ]]];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"User cancelled scan");
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

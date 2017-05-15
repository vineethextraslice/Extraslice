//
//  CouponPopup.m
//  WalkNPay
//
//  Created by Administrator on 14/01/16.
//  Copyright © 2016 Extraslice. All rights reserved.
//

#import "CouponPopup.h"
#import "CouponModel.h"
#import "PaymentGateway.h"
#import "WnPConstants.h"

@interface CouponPopup ()
@property(strong, nonatomic) PaymentGateway *pymntGtway;
@property(strong,nonatomic) NSMutableArray *selectedCoupons;
@property(strong,nonatomic) NSMutableArray *unSelectedCoupons;
@property(strong,nonatomic) NSMutableArray *allCoupons;
@property(strong,nonatomic) NSMutableArray *selectedCouponIds;
@property(strong,nonatomic) NSMutableArray *alreadySelectedCpnIds;
@property(strong,nonatomic) WnPConstants *wnpCont;


@end

@implementation CouponPopup

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wnpCont =[[WnPConstants alloc]init];
    self.pymntGtway = [[PaymentGateway alloc]init];
    self.selectedCouponIds = [[NSMutableArray alloc]init];
    self.unSelectedCoupons = [[NSMutableArray alloc]init];
    self.selectedCoupons = [[NSMutableArray alloc]init];
    self.allCoupons = [[NSMutableArray alloc]init];
    self.couponTable.dataSource=self;
    self.couponTable.delegate=self;
    self.couponTable.rowHeight=24;
    self.couponTable.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    self.applyBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.cancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    int index=0;
    
    self.view.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-10;
    [self.view setBounds:CGRectMake(0,0, tableWidth,185)];
    
    
    UILabel *checkBox = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , (tableWidth*0.2f), 22)];
    UIFont *txtFont = [checkBox.font fontWithSize:wnpFontSize];
    checkBox.text=@"Select";
    checkBox.font = txtFont;
    
    [self.headerView addSubview:checkBox];
    self.headerView.backgroundColor=[self.wnpCont getThemeBaseColor];
    UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth*0.2f), 0 , (tableWidth*0.4f), 22)];
    
    code.font = txtFont;
    code.text=@"Code";
    [self.headerView addSubview:code];
    
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth*0.6f), 0 , (tableWidth*0.25f), 22)];
    price.font = txtFont;
    price.text=[NSString stringWithFormat:@"%@%s",[self.wnpCont getCurrencySymbol]," Applies"];;
    
    [self.headerView addSubview:price];

    UILabel *more = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth*0.85f), 0 , (tableWidth*0.15f), 22)];
    more.font = txtFont;
    more.text=@"More";
    [self.headerView addSubview:more];
    self.alreadySelectedCpnIds= [[NSMutableArray alloc]init];
    
    for(CouponModel *cpn in [self.pymntGtway getSelectedCoupons]){
        //CouponModel *cpn = [[CouponModel alloc]init];
        //cpn= [cpn initWithDictionary:cpnDic];
        if(![cpn.applyBy isEqualToString:@"DEFAULT"]){
            [self.alreadySelectedCpnIds addObject:cpn.couponId];
        }
       
    }
    for(CouponModel *cpn in [self.pymntGtway getOfferCoupons]){
        
        
        if([cpn.applyBy isEqualToString:@"DEFAULT"]){
            NSNumber *number = [NSNumber numberWithInt:index];
            [self.selectedCouponIds addObject:number];
           
            if(cpn.recalculatedOfferedAmount.doubleValue>0){
                [self.selectedCoupons addObject:cpn];
            }
        }else if ([self.alreadySelectedCpnIds containsObject:cpn.couponId]){
            NSNumber *number = [NSNumber numberWithInt:index];
            
            [self.selectedCoupons addObject:cpn];
            [self.selectedCouponIds addObject:number];
        }else{
          // [cpn calcualteOfferAmount:FALSE reallocate:FALSE];
            //if(cpn.recalculatedOfferedAmount.doubleValue>0){
                [self.unSelectedCoupons addObject:cpn];
            //}
        }
        [self.allCoupons addObject:cpn];
        index++;
    }
   /* */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // NSMutableArray *productArray = [self.constFile getItemsFromArray];
    
    return [self.pymntGtway getOfferCoupons].count;
    
    //}else{
    //   return productArray.count;
    //}
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CouponModel *cpnMdl=[self.allCoupons objectAtIndex:indexPath.row];
    NSString *celId =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
    }
    for(UIView *sv in cell.subviews){
        [sv removeFromSuperview];
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-20;
    
    UIImageView *checkBox = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2 , 20, 20)];
    
    
     NSNumber *number = [NSNumber numberWithInt:(int)indexPath.item];
    [self.couponTable bringSubviewToFront:checkBox];
    if([cpnMdl.applyBy isEqualToString:@"DEFAULT"]){
        [checkBox setUserInteractionEnabled:NO];
        [checkBox setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
    }else if ([self.selectedCouponIds containsObject:number]){
        [checkBox setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
        UITapGestureRecognizer *delSelected=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCoupon:)];
        checkBox.tag=indexPath.row;
        [delSelected setNumberOfTapsRequired:1];
        [checkBox setUserInteractionEnabled:YES];
        [checkBox addGestureRecognizer:delSelected];
    }else{
         if(cpnMdl.recalculatedOfferedAmount == nil|| cpnMdl.recalculatedOfferedAmount.doubleValue <=0){
             [checkBox setUserInteractionEnabled:NO];
         }else{
             [checkBox setUserInteractionEnabled:YES];
         }
        [checkBox setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        UITapGestureRecognizer *delSelected=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCoupon:)];
        checkBox.tag=indexPath.row;
        [delSelected setNumberOfTapsRequired:1];
        [checkBox addGestureRecognizer:delSelected];
    }
    [cell addSubview:checkBox];
    
    UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(4+(tableWidth*0.2f), 2 , (tableWidth*0.4f), 22)];
    UIFont *txtFont = [code.font fontWithSize:wnpFontSize];
    code.font = txtFont;
    code.text=cpnMdl.couponCode;
    [cell addSubview:code];
    
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(6+(tableWidth*0.6f), 2 , (tableWidth*0.25f), 22)];
    price.font = txtFont;
    if(cpnMdl.recalculatedOfferedAmount == nil){
        price.text=@"0.00";
    }else{
        price.text=cpnMdl.recalculatedOfferedAmount.stringValue;
    }
    
    [cell addSubview:price];
    
    UILabel *more = [[UILabel alloc] initWithFrame:CGRectMake(8+(tableWidth*0.85f), 2 , (tableWidth*0.15f), 22)];
    more.font = txtFont;
    more.text=@"details";
    [cell addSubview:more];
    
    
    return cell;}
- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *) newIndexPath{
    //UITextField* tf = (UITextField *) [tableView viewWithTag:newIndexPath.row+1000];
    
}

-(void)  selectCoupon:(UIGestureRecognizer *)recognizer {
    UIImageView *checkBox =(UIImageView *)recognizer.view;
    checkBox.userInteractionEnabled = true;
    CouponModel *cpnMdl =[self.allCoupons objectAtIndex:checkBox.tag];
    NSLog(@"%ld",(long)checkBox.tag);
    
    NSNumber *number = [NSNumber numberWithInt:(int)checkBox.tag];
    
    if([self.selectedCouponIds containsObject:number]){
        [self.selectedCouponIds removeObject:number];
        [checkBox setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        [self.pymntGtway setTotalAmountForOffer:[NSNumber numberWithDouble:([self.pymntGtway getTotalAmountForOffer].doubleValue +  cpnMdl.recalculatedOfferedAmount.doubleValue)]];
         [cpnMdl calcualteOfferAmount:FALSE reallocate:TRUE];
        
        [self.unSelectedCoupons addObject:cpnMdl];
        [self.selectedCoupons removeObject:cpnMdl];
        
        for(CouponModel *cpn in self.selectedCoupons){
            if(![cpn.couponType isEqualToString:@"Prepaid"]){
                [cpn calcualteOfferAmount:FALSE reallocate:TRUE];
            }
        }
        [self.pymntGtway setTotalAmountForOffer:self.totalAmount];
        for(CouponModel *cpn in self.selectedCoupons){
            if(![cpn.couponType isEqualToString:@"Prepaid"]){
                [cpn calcualteOfferAmount:TRUE reallocate:FALSE];
                [self.pymntGtway setTotalAmountForOffer:[NSNumber numberWithDouble:([self.pymntGtway getTotalAmountForOffer].doubleValue -  cpnMdl.recalculatedOfferedAmount.doubleValue)]];
            }
        }
        
        for(CouponModel *cpn in self.unSelectedCoupons){
            if(![cpn.couponType isEqualToString:@"Prepaid"]){
                [cpn calcualteOfferAmount:FALSE reallocate:FALSE];
            }
         
        }
        
    }else{
        [self.selectedCouponIds addObject:number];
        [checkBox setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
        [cpnMdl calcualteOfferAmount:TRUE reallocate:FALSE];
        [self.selectedCoupons addObject:cpnMdl];
        [self.unSelectedCoupons removeObject:cpnMdl];
        //totalAmountForOffer  = [NSNumber numberWithDouble:(totalAmountForOffer.doubleValue  - recalcAmt.doubleValue)];
        [self.pymntGtway setTotalAmountForOffer:[NSNumber numberWithDouble:([self.pymntGtway getTotalAmountForOffer].doubleValue -  cpnMdl.recalculatedOfferedAmount.doubleValue)]];
        for(CouponModel *cpn in self.unSelectedCoupons){
            if(![cpn.couponType isEqualToString:@"Prepaid"]){
                [cpn calcualteOfferAmount:FALSE reallocate:FALSE] ;
            }
        }
    }
    [self.couponTable reloadData];
}

- (IBAction)cancelPopup:(id)sender {
    self.parentViewController.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.parentViewController.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    for(CouponModel *cpn in self.selectedCoupons){
        if(![cpn.couponType isEqualToString:@"Prepaid"]){
            [cpn calcualteOfferAmount:FALSE reallocate:TRUE] ;
            [self.pymntGtway setTotalAmountForOffer:[NSNumber numberWithDouble:([self.pymntGtway getTotalAmountForOffer].doubleValue +  cpn.recalculatedOfferedAmount.doubleValue)]];
        }
    }
    for(CouponModel *cpn in self.unSelectedCoupons){
        if(![cpn.couponType isEqualToString:@"Prepaid"]){
            [cpn calcualteOfferAmount:FALSE reallocate:FALSE] ;
        }
    }
   
    self.allCoupons=nil;
    self.selectedCoupons=nil;
    self.unSelectedCoupons=nil;
    self.alreadySelectedCpnIds=nil;
    self.selectedCouponIds=nil;
    // cancelCoupons
}

- (IBAction)addAppliedCoupons:(id)sender {
     [self.pymntGtway removeAllSelectedCoupon];
    [self.pymntGtway setOfferAmount:[NSNumber numberWithDouble:0]];
    for(CouponModel *cpn in self.selectedCoupons){
        NSDictionary *cpnDic = [cpn dictionaryWithAllPropertiesOfObject:cpn];
        [self.pymntGtway addSelectedCoupon:cpnDic];
        [self.pymntGtway setOfferAmount:[NSNumber numberWithDouble:([self.pymntGtway getOfferAmount].doubleValue  +  cpn.recalculatedOfferedAmount.doubleValue)]];
    }
    
    
    self.parentViewController.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.parentViewController.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applyCoupons" object:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


@end

//
//  RecieptController.m
//  WalkNPay
//
//  Created by Irshad on 11/25/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "RecieptController.h"
#import "StoreModel.h"
#import "ProductModel.h"
#import "WnPConstants.h"
#import "TransactionDAO.h"
#import "CouponModel.h"
#import "WnPUtilities.h"

@interface RecieptController ()


@property (strong, nonatomic) UITableView *itemTable;
@property (strong, nonatomic) UITableView *couponTable;
@property(strong,nonatomic) NSMutableArray *offerCpnArray;
@property(nonatomic) double prepaidAmount;
@property(nonatomic) double offerAmount;
@property(strong,nonatomic) NSNumberFormatter *formatter;
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(strong,nonatomic) NSString *currSymb;

@end

@implementation RecieptController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.wnpCont =[[WnPConstants alloc]init];
    WnPUtilities *utils = [[WnPUtilities alloc]init];
    self.formatter= [[NSNumberFormatter alloc] init];
    [self.formatter setPositiveFormat:@"0.##"];
    self.offerCpnArray = [[NSMutableArray alloc]init];
    self.recieptId.text=[NSString stringWithFormat:@"%s%@","Receipt Id: ",self.reciept.orderId.stringValue];
    self.topHeader.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.orderdate.text=[NSString stringWithFormat:@"%s%@","Date: ",[utils changeDateFormat:self.reciept.orderDate]];
    CGRect screenRect1 = [[UIScreen mainScreen] bounds];
    self.currSymb=[self.reciept.recieptStore valueForKey:@"currencySymbol"];
    if(self.currSymb ==nil){
        self.currSymb=@"$";
    }else if([self.currSymb isEqualToString:@"INR"]){
        self.currSymb=@"₹";
    }
    float viewSize = screenRect1.size.height-330;
    if(self.reciept.couponList != nil && self.reciept.couponList.count > 0){
        for(NSMutableDictionary *cpnDic in self.reciept.couponList){
            CouponModel *model = [[CouponModel alloc]init];
            model = [model initWithDictionary:cpnDic];
            if(model.couponCode == nil || ![model.couponCode isEqual:@"prepaid"]){
                [self.offerCpnArray addObject:model];
                self.offerAmount=self.offerAmount+model.applicableAmount.doubleValue;
            }else{
                self.prepaidAmount=model.applicableAmount.doubleValue;
            }
        }
    }
    if(self.offerCpnArray != nil && self.offerCpnArray.count > 0){
        self.itemTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenRect1.size.width, (viewSize/2))];
        UIView *couponHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, (viewSize/2), screenRect1.size.width, 30)];
        CGFloat tableWidth = screenRect1.size.width-30;
        
        
        UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(3, 1 , (tableWidth*0.4f), 25)];
        code.text=@"Coupon code";
        UIFont *txtFont = [code.font fontWithSize:12.0];
        code.font = txtFont;
        [couponHeaderView addSubview:code];
        
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth*0.4f)+3, 1 , (tableWidth*0.4f), 25)];
        desc.text=@"Description";
        desc.font = txtFont;
        [couponHeaderView addSubview:desc];
        
        UILabel *offered = [[UILabel alloc] initWithFrame:CGRectMake((3+(tableWidth*0.8f)), 1 , (tableWidth*0.2f), 25)];
        offered.text=[NSString stringWithFormat:@"%@%s",self.currSymb,"Applies"];
        offered.font = txtFont;
        [couponHeaderView addSubview:offered];
        [self.itemsView addSubview:couponHeaderView];
        self.couponTable = [[UITableView alloc]initWithFrame:CGRectMake(0, (30+(viewSize/2)), screenRect1.size.width, viewSize/2)];
        couponHeaderView.backgroundColor=[self.wnpCont getThemeHeaderColor];
    }else{
        self.itemTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenRect1.size.width, viewSize)];
        self.couponTable = [[UITableView alloc]initWithFrame:CGRectMake(0, viewSize, screenRect1.size.width, 0)];
    }
    [self.itemsView addSubview:self.itemTable];
    [self.itemsView addSubview:self.couponTable];
    
    
    self.storename.text=[self.reciept.recieptStore objectForKey:@"name"];
    
    NSMutableString *addr = [[NSMutableString alloc] init];
    [addr appendString:@""];
    if([self.reciept.recieptStore objectForKey:@"addressLine1"]  != (id)[NSNull null] && [self.reciept.recieptStore objectForKey:@"addressLine1"] != nil){
        
        [addr appendString:[self.reciept.recieptStore objectForKey:@"addressLine1"]];
        [addr appendString:@","];
    }
    if([self.reciept.recieptStore objectForKey:@"addressLine2"]  != (id)[NSNull null] && [self.reciept.recieptStore objectForKey:@"addressLine2"] != nil){
        
        [addr appendString:[self.reciept.recieptStore objectForKey:@"addressLine2"]];
        [addr appendString:@","];
    }
    if([self.reciept.recieptStore objectForKey:@"addressLine3"]  != (id)[NSNull null] && [self.reciept.recieptStore objectForKey:@"addressLine3"] != nil){
        
        [addr appendString:[self.reciept.recieptStore objectForKey:@"addressLine3"]];
        [addr appendString:@", "];
    }
    if([self.reciept.recieptStore objectForKey:@"state"]  != (id)[NSNull null] && [self.reciept.recieptStore objectForKey:@"state"] != nil){
        
        [addr appendString:[self.reciept.recieptStore objectForKey:@"state"]];
        [addr appendString:@","];
    }
    if([self.reciept.recieptStore objectForKey:@"zip"]  != (id)[NSNull null] && [self.reciept.recieptStore objectForKey:@"zip"] != nil){
        
        [addr appendString:[self.reciept.recieptStore objectForKey:@"zip"]];
    }
    
    
    
    
    self.storeAddress.text=addr ;//storeModel.addressLine1;
    
    self.itemTable.dataSource=self;
    self.itemTable.delegate=self;
    self.itemTable.rowHeight=54;
    self.itemTable.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    self.couponTable.dataSource=self;
    self.couponTable.delegate=self;
    self.couponTable.rowHeight=40;
    
    self.couponTable.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-20;
    
    UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(2, 1 , (tableWidth*0.35f), 25)];
    code.text=@"Code/Item";
    UIFont *txtFont = [code.font fontWithSize:12.0];
    code.font = txtFont;
    [self.headerView addSubview:code];
    
    
    UILabel *rate = [[UILabel alloc] initWithFrame:CGRectMake((4+(tableWidth*0.35f)), 1 , (tableWidth*0.15f), 25)];
    rate.text=@"Rate";
    rate.font = txtFont;
    [self.headerView addSubview:rate];
    
    UILabel *tax = [[UILabel alloc] initWithFrame:CGRectMake((6+(tableWidth*0.50f)), 1 , (tableWidth*0.15f), 25)];
    tax.text=@"Tax";
    tax.font = txtFont;
    [self.headerView addSubview:tax];
    
    UILabel *qty = [[UILabel alloc] initWithFrame:CGRectMake((8+(tableWidth*0.65f)), 1 ,((tableWidth*0.15f)), 25)];
    qty.text=@"Qty";
    qty.font = txtFont;
    [self.headerView addSubview:qty];
    
    UILabel *amt = [[UILabel alloc] initWithFrame:CGRectMake((10+(tableWidth*0.8f)), 1 ,((tableWidth*0.2f)), 25)];
    amt.text=@"Amount";
    amt.font = txtFont;
    [self.headerView addSubview:amt];
    self.headerView.backgroundColor=[self.wnpCont getThemeHeaderColor];
    self.summaryView.backgroundColor=[self.wnpCont getThemeHeaderColor];
    if(self.reciept.payMethod != (id)[NSNull null]){
        if(self.reciept.payMethod != nil && [self.reciept.payMethod  isEqual:@"Prepaid"]){
            self.payMethod1.text=@"Prepaid";
            self.pay1Hip.text=@":";
            self.payAmount1.text=[NSString stringWithFormat:@"%@%@",self.currSymb,[self.formatter stringFromNumber:[NSNumber numberWithDouble:(self.prepaidAmount)]]];
            self.payMethod2.hidden=TRUE;
            self.payHip2.hidden=TRUE;
            self.payAmount2.hidden=TRUE;
        }else{
            if(self.prepaidAmount <=0){
                self.payMethod1.text=self.reciept.payMethod;
                self.pay1Hip.text=@":";
                self.payAmount1.text=[NSString stringWithFormat:@"%@%@",self.currSymb,[self.formatter numberFromString:self.reciept.payableTotal]];
            
                self.payMethod2.hidden=TRUE;
                self.payHip2.hidden=TRUE;
                self.payAmount2.hidden=TRUE;
            }else{
                self.payMethod1.text=@"Prepaid";
                self.pay1Hip.text=@":";
                self.payAmount1.text = [NSString stringWithFormat:@"%@%@",self.currSymb,[self.formatter stringFromNumber:[NSNumber numberWithDouble:(self.prepaidAmount)]]];
            
                self.payMethod2.text=self.reciept.payMethod;
                self.payHip2.text=@":";
                self.payAmount2.text=[NSString stringWithFormat:@"%@%@",self.currSymb,[self.formatter numberFromString:self.reciept.payableTotal]];
            }
        }
    }else{
        self.payMethod1.hidden=TRUE;
        self.pay1Hip.hidden=TRUE;;
        self.payAmount1.hidden=TRUE;
        
        self.payMethod2.hidden=TRUE;
        self.payHip2.hidden=TRUE;
        self.payAmount2.hidden=TRUE;
    }
    //=[NSString stringWithFormat:("%d",self.reciept.itemList.count)];
    int totalCnt = 0;
    for(NSMutableDictionary *model in self.reciept.itemList){
        totalCnt = totalCnt + [[model objectForKey:@"purchasedQuantity"] intValue];
        //[model objectForKey:@"purchasedQuantity"];    ;//model.purchasedQuantity.intValue;
        
    }
    self.totalCounts.text = [NSString stringWithFormat:@"%d", totalCnt];
    self.totalTaxView.text=[NSString stringWithFormat:@"%@%@",self.currSymb,[self.formatter stringFromNumber:[NSNumber numberWithDouble:self.reciept.totalTax.doubleValue]]];
    self.subTotalAmt.text = [NSString stringWithFormat:@"%@%@",self.currSymb,self.reciept.subTotal];
    if(self.offerAmount > 0){
        self.discount.text = [NSString stringWithFormat:@"%s%@%@","-",self.currSymb,[self.formatter stringFromNumber:[NSNumber numberWithDouble:(self.offerAmount)]]];
    }else{
        self.discount.text = [NSString stringWithFormat:@"%@%@",self.currSymb,[self.formatter stringFromNumber:[NSNumber numberWithDouble:(self.offerAmount)]]];
    }
    self.grossTotalView.text=[NSString stringWithFormat:@"%@%@",self.currSymb,[self.formatter stringFromNumber:[NSNumber numberWithDouble:(self.reciept.grossTotal.doubleValue-self.offerAmount)]]];
    
    
    
    if(self.reciept.offerTotal.doubleValue > 0){
        self.savedMessage.hidden=FALSE;
        self.savedMessage.text=[NSString stringWithFormat:@"%s%@%@","You have saved ",self.currSymb,[self.formatter stringFromNumber:[NSNumber numberWithDouble:(self.offerAmount)]]];
    }else{
        self.savedMessage.hidden=TRUE;
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(sendReceiptByEmail:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.mailImg setUserInteractionEnabled:YES];
    [self.mailImg addGestureRecognizer:singleTap];
}
-(void)sendReceiptByEmail:(UIGestureRecognizer *)recognizer {
    
    TransactionDAO *trxnDAO = [[TransactionDAO alloc] init];
    NSString *status = [trxnDAO sendReceiptByEmail:[self.wnpCont getUserId] OrderId:self.reciept.orderId];
    UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:status preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:alert];
    [self presentViewController:controller animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.itemTable]) {
        return [self.reciept.itemList count];
    }else{
        if(self.offerCpnArray == nil){
            return 0;
        }else{
            return self.offerCpnArray.count;
        }
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *celId =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
    }
    //if(tableView.tag==0){
    if ([tableView isEqual:self.itemTable]) {
        
        NSMutableArray *productArray = self.reciept.itemList;
        
        ProductModel *model = [[ProductModel alloc]init];
        model = [model initWithDictionary:[productArray objectAtIndex:indexPath.item]];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat tableWidth = screenRect.size.width-20;
        
        UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(3, 1 , (tableWidth*0.35f), 40)];
        code.text=[NSString stringWithFormat:@"%@%s%@",model.code," / ",model.name];
        UIFont *txtFont = [code.font fontWithSize:12.0];
        code.font = txtFont;
        code.numberOfLines=2;
        [cell addSubview:code];
        
        
        
        
        UILabel *rate = [[UILabel alloc] initWithFrame:CGRectMake((2+(tableWidth*0.35f)), 1 , (tableWidth*0.15f), 40)];
        rate.text=[self.formatter stringFromNumber:[NSNumber numberWithDouble:(model.price.doubleValue)]];
        
        rate.font = txtFont;
        [cell addSubview:rate];
        
        UILabel *tax = [[UILabel alloc] initWithFrame:CGRectMake((2+(tableWidth*0.5f)), 1 , (tableWidth*0.15f), 40)];
        tax.text=[self.formatter stringFromNumber:[NSNumber numberWithDouble:(model.taxAmount.doubleValue)]];
        
        tax.font = txtFont;
        [cell addSubview:tax];
        
        UILabel *qty = [[UILabel alloc] initWithFrame:CGRectMake((2+(tableWidth*0.65f)), 1 ,((tableWidth*0.15f)), 40)];
        qty.text=[self.formatter stringFromNumber:[NSNumber numberWithDouble:(model.purchasedQuantity.doubleValue)]];
        qty.font = txtFont;
        [cell addSubview:qty];
        
        UILabel *amt = [[UILabel alloc] initWithFrame:CGRectMake((2+(tableWidth*0.8f)), 1 ,((tableWidth*0.2f)), 40)];
        double itemTotal = ((model.price.doubleValue+model.taxAmount.doubleValue)*model.purchasedQuantity.doubleValue);
        amt.text=[self.formatter stringFromNumber:[NSNumber numberWithDouble:(itemTotal)]];
        amt.font = txtFont;
        [cell.contentView addSubview:amt];
        self.itemTable.rowHeight=54;
    }else{
        if(self.offerCpnArray != nil){
            CouponModel *model = [self.offerCpnArray objectAtIndex:indexPath.item];
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat tableWidth = screenRect.size.width-30;
            
            
            UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(3, 1 , (tableWidth*0.4f), 40)];
            code.text=model.couponCode;
            UIFont *txtFont = [code.font fontWithSize:12.0];
            code.font = txtFont;
            // [code sizeToFit];
            code.numberOfLines=2;
            [cell addSubview:code];
            
            
            UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake((3+(tableWidth*0.4f)), 1 , (tableWidth*0.4f), 40)];
            desc.text=model.description;
            desc.font = txtFont;
            [cell addSubview:desc];
            
            UILabel *offered = [[UILabel alloc] initWithFrame:CGRectMake((3+(tableWidth*0.8f)), 1 , (tableWidth*0.2f), 40)];
            offered.text=[self.formatter stringFromNumber:[NSNumber numberWithDouble:(model.applicableAmount.doubleValue)]];
            offered.font = txtFont;
            [cell addSubview:offered];
            
            self.couponTable.rowHeight=42;
        }
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


@end

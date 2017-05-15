//
//  RecieptController.h
//  WalkNPay
//
//  Created by Irshad on 11/25/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionModel.h"


@interface RecieptController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *topHeader;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *summaryView;

@property (weak, nonatomic) IBOutlet UIView *totalView;
@property (weak, nonatomic) IBOutlet UIView *payPgView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *itemsView;
//@property (weak, nonatomic) IBOutlet UITableView *itemTable;
@property (weak, nonatomic) IBOutlet UILabel *storeAddress;
@property (weak, nonatomic) IBOutlet UILabel *recieptId;
@property (weak, nonatomic) IBOutlet UILabel *orderdate;
@property (weak, nonatomic) IBOutlet UILabel *storename;
@property (weak, nonatomic) IBOutlet UIImageView *mailImg;
@property (weak, nonatomic) IBOutlet UILabel *discount;
@property(strong,nonatomic) TransactionModel *reciept;
@property (weak, nonatomic) IBOutlet UILabel *totalCounts;
@property (weak, nonatomic) IBOutlet UILabel *subTotalAmt;
@property (weak, nonatomic) IBOutlet UILabel *totalTaxView;
@property (weak, nonatomic) IBOutlet UILabel *grossTotalView;
@property (weak, nonatomic) IBOutlet UILabel *payMethod1;
@property (weak, nonatomic) IBOutlet UILabel *pay1Hip;
@property (weak, nonatomic) IBOutlet UILabel *payAmount1;
@property (weak, nonatomic) IBOutlet UILabel *payMethod2;
@property (weak, nonatomic) IBOutlet UILabel *payHip2;
@property (weak, nonatomic) IBOutlet UILabel *payAmount2;
@property (weak, nonatomic) IBOutlet UILabel *savedMessage;



@end

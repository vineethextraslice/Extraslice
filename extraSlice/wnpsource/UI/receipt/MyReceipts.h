//
//  MyReceipts.h
//  walkNPay
//
//  Created by Administrator on 28/01/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
static int pageset=0;
static int pageNo=0;
static int noOfRecords=10;
static int offset=0;
@interface MyReceipts : UIViewController<UITableViewDataSource,UITableViewDelegate>
-(void) resetDefault;


@end

//
//  WalletTabController.h
//  walkNPay
//
//  Created by Administrator on 03/02/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalletTabController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *myRcpttab;
@property (weak, nonatomic) IBOutlet UILabel *myCardTab;
@property (weak, nonatomic) IBOutlet UIView *tabContentView;
@property (weak, nonatomic) IBOutlet UIView *seperator;

@end

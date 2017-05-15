//
//  PaymentStatus.h
//  WalkNPay
//
//  Created by Irshad on 11/25/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionModel.h"

@interface PaymentStatus : UIViewController
- (IBAction)showReciept:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *statusText;
@property (weak, nonatomic) IBOutlet UILabel *statsMessage;
@property (weak, nonatomic) IBOutlet UILabel *additonalMessage;
@property (weak, nonatomic) IBOutlet UIImageView *nextBtbImg;
@property (weak, nonatomic) IBOutlet UILabel *btnText;
@property(nonatomic) NSNumber *receiptId;
@property(nonatomic) BOOL status;
@property(weak,nonatomic) NSString *errorMessage;
@property(weak,nonatomic) TransactionModel *reciept;
@end

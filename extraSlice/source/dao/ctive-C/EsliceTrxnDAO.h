//
//  EsliceTrxnDAO.h
//  extraSlice
//
//  Created by Administrator on 17/04/17.
//  Copyright © 2017 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EsliceTrxnDAO:NSObject
-(NSDictionary *) getEsliceReceipts:(NSNumber *)userId StartDate:(NSString *)startDate EndDate:(NSString *)endDate ;
-(NSString *) sendReceiptByEmail:(NSNumber *)userId OrderId:(NSNumber *)orderId;
@end

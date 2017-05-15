//
//  StripeDAO.h
//  WalkNPay
//
//  Created by Administrator on 30/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StripePlanModel.h"
#import "PlanModel.h"

@interface StripeDAO : NSObject
-(NSString *) doStripePayment:(NSNumber *)amount ID:(NSNumber *)id CardToken:(NSString *) cardToken Currency:(NSString *) currency Description:(NSString *) description IsDealerAccount:(BOOL) isDealerAcct ;
-(NSString *) subscribeACustomer:(NSString *)email CardToken:(NSString *) cardToken PlanId:(NSString *) planId ;
-(StripePlanModel *) getOrCreateStripePlan:(PlanModel *)planModel AddOnList:(NSMutableArray *)addOnList;
@end

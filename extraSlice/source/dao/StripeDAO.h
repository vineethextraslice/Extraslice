//
//  StripeDAO.h
//  WalkNPay
//
//  Created by Administrator on 30/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlanModel.h"

@interface StripeDAO : NSObject
-(NSString *) doStripePayment:(NSNumber *)amount ID:(NSNumber *)id CardToken:(NSString *) cardToken Currency:(NSString *) currency Description:(NSString *) description IsDealerAccount:(BOOL) isDealerAcct ;
-(NSString *) doStripePayment:(NSNumber *)amount ID:(NSNumber *)strId CardToken:(NSString *) cardToken Currency:(NSString *) currency Description:(NSString *) description IsDealerAccount:(BOOL) isDealerAcct PlanNames:(NSString *) planNames Addonnames:(NSString *) addonNames;
-(NSDictionary *) getStripeCardsForUser:(NSNumber *)userId;
-(NSDictionary *) addCustomerAndCard:(NSNumber *)userId Email:(NSString *) email CustId:(NSString *) custId TokenId:(NSString *) tokenId NewCard:(BOOL) newcard DefaultCard:(BOOL) defaultCard;
-(NSDictionary *) updateStripeCustomerForUser:(NSNumber *)userId OrgId:(NSNumber *) orgId;
-(NSDictionary *) deleteCard:(NSNumber *)userId CustId:(NSString *) custId TokenId:(NSString *) tokenId;
@end

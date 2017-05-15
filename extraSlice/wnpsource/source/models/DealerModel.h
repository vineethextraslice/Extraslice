//
//  DealerModel.h
//  walkNPay
//
//  Created by Administrator on 02/02/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DealerModel : NSObject
@property(nonatomic) BOOL active;
@property(strong,nonatomic) NSString *addressLine1;
@property(strong,nonatomic) NSString *addressLine2 ;
@property(strong,nonatomic) NSString *addressLine3 ;
@property(strong,nonatomic) NSString *city ;
@property(strong,nonatomic) NSNumber *dealerId;
@property(strong,nonatomic) NSString *email ;
@property(strong,nonatomic) NSString *logo;
@property(strong,nonatomic) NSNumber *minRechargeAmt;
@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) NSString *paypalClientId;
@property(strong,nonatomic) NSString *paypalEnv;
@property(strong,nonatomic) NSString *phone;
@property(strong,nonatomic) NSString *state;
@property(strong,nonatomic) NSString *stripePublushKey;
@property(strong,nonatomic) NSString *stripeSecretKey;
@property(strong,nonatomic) NSString *zip;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
- (DealerModel *)initWithDictionary:(NSDictionary*)dictionary;

@end

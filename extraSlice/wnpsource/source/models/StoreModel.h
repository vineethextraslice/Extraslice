//
//  StoreModel.h
//  WalkNPay
//
//  Created by Irshad on 12/1/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreModel : NSObject
@property(nonatomic) BOOL active;
@property(strong,nonatomic) NSString *addressLine1;
@property(strong,nonatomic) NSString *addressLine2 ;
@property(strong,nonatomic) NSString *city ;
@property(strong,nonatomic) NSNumber *dealerId;
@property(strong,nonatomic) NSString *dealerName;
@property(strong,nonatomic) NSString *email ;
@property(strong,nonatomic) NSNumber *latitude;
@property(strong,nonatomic) NSString *logo;
@property(strong,nonatomic) NSNumber *longitude;
@property(strong,nonatomic) NSNumber *minRechargeAmt;
@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) NSString *paypalClientId;
@property(strong,nonatomic) NSString *paypalEnv;
@property(strong,nonatomic) NSString *phone;
@property(strong,nonatomic) NSString *state;
@property(strong,nonatomic) NSNumber *storeId;
@property(strong,nonatomic) NSString *stripePublushKey;
@property(strong,nonatomic) NSString *stripeSecretKey;
@property(strong,nonatomic) NSString *zip;
@property(strong,nonatomic) NSString *currencyCode;
@property(strong,nonatomic) NSString *countryCode;
@property(strong,nonatomic) NSString *currencySymbol;
@property(strong,nonatomic) NSString *countryName;
- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
- (StoreModel *)initWithDictionary:(NSDictionary*)dictionary;

@end

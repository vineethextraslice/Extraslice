//
//  StripeCardModel.h
//  extraSlice
//
//  Created by Administrator on 24/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StripeCardModel : NSObject
@property(strong, nonatomic) NSString *cardId;
@property(strong, nonatomic) NSNumber *expMonth;
@property(strong, nonatomic) NSNumber *expYear;
@property(strong, nonatomic) NSString *last4;
@property(strong, nonatomic) NSString *name;
@property(nonatomic) BOOL defaultCard;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (StripeCardModel *)initWithDictionary:(NSDictionary*)dictionary;
@end

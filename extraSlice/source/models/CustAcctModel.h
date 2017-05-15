//
//  CustAcctModel.h
//  extraSlice
//
//  Created by Administrator on 15/11/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustAcctModel : NSObject
    @property(strong, nonatomic) NSString *customerId;
    @property(strong, nonatomic) NSString *strpAcct;
    @property(strong, nonatomic) NSNumber *userId ;
    @property(strong, nonatomic) NSNumber *acctId ;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (CustAcctModel *)initWithDictionary:(NSDictionary*)dictionary;
@end

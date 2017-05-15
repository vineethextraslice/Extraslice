//
//  TransactionModel.m
//  WalkNPay
//
//  Created by Irshad on 12/1/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "TransactionModel.h"
#import "objc/runtime.h"

@implementation TransactionModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.orderId=@-1;
        self.userName=@"";
        self.subTotal=@"";
        self.storeId=@-1;
        self.userId=@-1;
        self.grossTotal=@"";
        self.totalTax=@"";
        self.offerTotal=@"";
        self.payableTotal=@"";
        self.orderDate=@"";
        self.storeName=@"";
        self.payMethod=@"";
        //self.couponList;
        //self.itemList;
       // self.recieptStore=@"";
        self.deviceType=@"";
        self.receiptFor=@"";
        
    }
    return self;
}
- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        [dict setObject:[obj valueForKey:key] forKey:key];
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:([self dictionaryWithPropertiesOfObject:self])
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
- (TransactionModel *)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        NSArray*keys=[dictionary allKeys];
        for (NSString* key in keys) {
            NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                                   [[key substringToIndex:1] capitalizedString],
                                   [key substringFromIndex:1]];
            
            if ([self respondsToSelector:NSSelectorFromString(setterStr)]) {
                [self setValue:[dictionary objectForKey:key] forKey:key];
            }
            
        }
    }
    return self;
}
@end

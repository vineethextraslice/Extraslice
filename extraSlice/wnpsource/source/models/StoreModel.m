//
//  StoreModel.m
//  WalkNPay
//
//  Created by Irshad on 12/1/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "StoreModel.h"
#import "objc/runtime.h"
@implementation StoreModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.active=YES;
        self.addressLine1=@"";
        self.addressLine2=@"";
        self.city=@"";
        self.dealerId=@-1;
        self.dealerName=@"";
        self.email=@"";
        self.latitude=@-1;
        self.logo=@"";
        self.longitude=@-1;
        self.minRechargeAmt=@0;
        self.name=@"";
        self.paypalClientId=@"";
        self.paypalEnv=@"";
        self.phone=@"";
        self.state=@"";
        self.storeId=@-1;
        self.stripePublushKey=@"";
        self.stripeSecretKey=@"";
        self.zip=@"";
        self.currencyCode=@"";
        self.countryCode=@"";
        self.currencySymbol=@"";
        self.countryName=@"";
        
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
- (StoreModel *)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        NSArray*keys=[dictionary allKeys];
        for (NSString* key in keys) {
            NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                                   [[key substringToIndex:1] capitalizedString],
                                   [key substringFromIndex:1]];
            
            if ([self respondsToSelector:NSSelectorFromString(setterStr)]) {
                NSString *valueString = [dictionary objectForKey:key];
                [self setValue:valueString forKey:key];
            }
            
        }
    }
    return self;
}
@end

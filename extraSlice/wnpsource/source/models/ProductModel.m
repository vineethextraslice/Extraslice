//
//  ProductModel.m
//  WalkNPay
//
//  Created by Irshad on 11/28/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "ProductModel.h"
#import "objc/runtime.h"

@implementation ProductModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.code=@"";
        self.name=@"";
        self.prodDescription=@"";
        self.id=@-1;
        self.price=@-1;
        self.taxPercentage=@0;
        self.availableQty=@0;
        self.storeItemId=@0;
        self.storeId=@-1;
        self.active=YES;
        self.onDemandItem=NO;
        self.rewardsAmount=@-1;
        self.taxAmount=@0;
        self.purchasedQuantity=@0;
        self.offerAppliedQty=@0;
        self.offerAppliedAmt=@0;
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
- (ProductModel *)initWithDictionary:(NSDictionary*)dictionary {
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

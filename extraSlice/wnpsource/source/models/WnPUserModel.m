//
//  UserModel.m
//  WalkNPay
//
//  Created by Irshad on 11/27/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "WnPUserModel.h"
#import "objc/runtime.h"


@implementation WnPUserModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userId =@-1;
        self.roleId=@-1;
        self.usingTempPwd = FALSE;
        self.autoEmail=YES;
        self.firstName = @"";
        self.lastName =  @"";
        self.roleName =  @"";
        self.tempPassword =  @"";
        self.verificationCode =  @"";
        self.addressLine1 =  @"";
        self.addressLine2 =  @"";
        self.addressLine3 =  @"";
        self.zip =  @"";
        self.state =  @"";
        self.userName=@"";
        self.password=@"";
        self.email=@"";
        self.authCode=@"";
    }
    return self;
}
//NSDictionary *dict = [NSDictionary dictionaryWithPropertiesOfObject: details];
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
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:([self dictionaryWithPropertiesOfObject:self])
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return nil;
    } else {
        return jsonData;
    }
    
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
- (WnPUserModel *)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        NSArray*keys=[dictionary allKeys];
        for (NSString* key in keys) {
            NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                                   [[key substringToIndex:1] capitalizedString],
                                   [key substringFromIndex:1]];
            
            if ([self respondsToSelector:NSSelectorFromString(setterStr)]) {
                NSObject *valueString = [dictionary objectForKey:key];
                [self setValue:valueString forKey:key];
            }
            
        }
    }
    return self;
}

@end

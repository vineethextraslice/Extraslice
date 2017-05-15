//
//  StoreDAO.h
//  WalkNPay
//
//  Created by Administrator on 18/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreModel.h"

@interface StoreDAO : NSObject
-(NSArray *) getAllStoresForDealer:(NSNumber *)dealerId ;
-(NSArray *) getAllStoresForDealerByLocation:(NSNumber *)dealerId ;
-(StoreModel *) getStoreById:(NSNumber *)storeId;

@end

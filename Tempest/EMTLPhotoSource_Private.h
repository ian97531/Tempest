//
//  EMTLPhotoSource_EMTLPhotoSource_Private_h.h
//  Tempest
//
//  Created by Ian White on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoSource.h"

@interface EMTLPhotoSource ()

- (NSDictionary *)_setupQueryArguments:(NSDictionary *)queryArguments forQuery:(EMTLPhotoQuery *)query;
- (void)cachePhotoList:(NSArray *)photos forQueryID:(NSString *)queryID;
- (NSArray *)photoListFromCacheForQueryID:(NSString *)queryID;

- (void)cacheImage:(UIImage *)image withSize:(EMTLImageSize)size forPhoto:(EMTLPhoto *)photo;
- (UIImage *)imageFromCacheWithSize:(EMTLImageSize)size forPhoto:(EMTLPhoto *)photo;

- (void)cacheUser:(EMTLUser *)user;
- (EMTLUser *)userFromCache:(NSString *)userID;

- (NSString *)_cacheKeyForPhoto:(EMTLPhoto *)photo imageSize:(EMTLImageSize)size;
- (NSString *)_cacheKeyForUserID:(NSString *)userID;

@end

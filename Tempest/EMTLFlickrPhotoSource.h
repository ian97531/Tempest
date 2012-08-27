//
//  EMTLFlickrPhotoSource.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoSource.h"
#import "EMTLPhotoSource_Private.h"
#import "EMTLFlickrConstants.h"

@class EMTLFlickrFetchPhotoQueryOperation;
@class EMTLFlickrFetchImageOperation;
@class EMTLFlickrSetFavoriteStateOperation;
@class EMTLFlickrFetchUserOperation;

@interface EMTLFlickrPhotoSource : EMTLPhotoSource
{
    @private
    OAConsumer *consumer;
    OAToken *requestToken;
    OAToken *accessToken;
    NSMutableDictionary *_imageOperations;
    NSMutableDictionary *_photoListOperations;
}

- (OAMutableURLRequest *)oaurlRequestForMethod:(NSString *)method arguments:(NSDictionary *)args;
- (NSDictionary *)dictionaryFromResponseData:(NSData *)data;
- (BOOL)isResponseOK:(NSDictionary *)responseDictionary;

// Callbacks for EMTLFlickrFetchPhotoQueryOperation
- (void)operation:(EMTLFlickrFetchPhotoQueryOperation *)operation fetchedPhotos:(NSArray *)photos totalPhotos:(int)total forQuery:(EMTLPhotoQuery *)query;
- (void)operation:(EMTLFlickrFetchPhotoQueryOperation *)operation finishedFetchingPhotos:(NSArray *)photos forQuery:(EMTLPhotoQuery *)query updatedArguments:(NSDictionary *)arguments;
- (void)operation:(EMTLFlickrFetchPhotoQueryOperation *)operation willFetchPhotosForQuery:(EMTLPhotoQuery *)query;
- (void)operation:(EMTLFlickrFetchPhotoQueryOperation *)operation isFetchingPhotosForQuery:(EMTLPhotoQuery *)query WithProgress:(float)progress;

// Callbacks for EMTLFlickrFetchImageOperation
- (void)operation:(EMTLFlickrFetchImageOperation *)operation willRequestImageForPhoto:(EMTLPhoto *)photo withSize:(EMTLImageSize)size;
- (void)operation:(EMTLFlickrFetchImageOperation *)operation didRequestImageForPhoto:(EMTLPhoto *)photo withSize:(EMTLImageSize)size progress:(float)progress;
- (void)operation:(EMTLFlickrFetchImageOperation *)operation didLoadImage:(UIImage *)image forPhoto:(EMTLPhoto *)photo withSize:(EMTLImageSize)size;

// Callbacks for EMTLFlickrSetFavoriteStateOperation
- (void)operation:(EMTLFlickrSetFavoriteStateOperation *)operation successfullySetFavoriteStateForPhoto:(EMTLPhoto *)photo;
- (void)operation:(EMTLFlickrSetFavoriteStateOperation *)operation failedToSetFavoriteStateForPhoto:(EMTLPhoto *)photo;

// Callbacks for EMTLFlickrFetchUserOperation
- (void)operation:(EMTLFlickrFetchUserOperation *)operation willRequestUser:(EMTLUser *)user;
- (void)operation:(EMTLFlickrFetchUserOperation *)operation didLoadUser:(EMTLUser *)user;

@end

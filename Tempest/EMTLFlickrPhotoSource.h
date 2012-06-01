//
//  EMTLFlickrPhotoSource.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoSource.h"
#import "EMTLPhotoSource_Private.h"


extern NSString *const kFlickrQueryTotalPages;
extern NSString *const kFlickrQueryCurrentPage;
extern NSString *const kFlickrQueryMaxYear;
extern NSString *const kFlickrQueryMaxMonth;
extern NSString *const kFlickrQueryMaxDay;
extern NSString *const kFlickrQueryMinYear;
extern NSString *const kFlickrQueryMinMonth;
extern NSString *const kFlickrQueryMinDay;
extern NSString *const kFlickrQueryMethod;
extern NSString *const kFlickrQueryIdentifier;

extern NSString *const kFlickrAPIMethodSearch;
extern NSString *const kFlickrAPIMethodPopularPhotos;
extern NSString *const kFlickrAPIMethodFavoritePhotos;
extern NSString *const kFlickrAPIMethodUserPhotos;
extern NSString *const kFlickrAPIMethodPhotoFavorites;
extern NSString *const kFlickrAPIMethodPhotoComments;

extern NSString *const kFlickrAPIArgumentUserID;
extern NSString *const kFlickrAPIArgumentPhotoID;
extern NSString *const kFlickrAPIArgumentItemsPerPage;
extern NSString *const kFlickrAPIArgumentPageNumber;
extern NSString *const kFlickrAPIArgumentAPIKey;
extern NSString *const kFlickrAPIArgumentContacts;
extern NSString *const kFlickrAPIArgumentSort;
extern NSString *const kFlickrAPIArgumentExtras;

extern NSString *const kFlickrRequestTokenURL;
extern NSString *const kFlickrAuthorizationURL;
extern NSString *const kFlickrAccessTokenURL;
extern NSString *const kFlickrAPICallURL;
extern NSString *const kFlickrDefaultsServiceProviderName;
extern NSString *const kFlickrDefaultsPrefix;
extern NSString *const kFlickrDefaultIconURLString;

@class EMTLFlickrFetchPhotoQueryOperation;
@class EMTLFlickrFetchImageOperation;

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

@end

//
//  EMTLFlickrPhotoSource.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoSource.h"

extern NSString *const kFlickrTimelinePhotoListID;
extern NSString *const kFlickrPopularPhotoListID;

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


extern NSString *const kFlickrRequestTokenURL;
extern NSString *const kFlickrAuthorizationURL;
extern NSString *const kFlickrAccessTokenURL;
extern NSString *const kFlickrAPICallURL;
extern NSString *const kFlickrDefaultsServiceProviderName;
extern NSString *const kFlickrDefaultsPrefix;
extern NSString *const kFlickrDefaultIconURLString;



@interface EMTLFlickrPhotoSource : NSObject <EMTLPhotoSource>
{
@private
    __weak id<EMTLPhotoSourceAuthorizationDelegate> _authorizationDelegate;
    NSMutableDictionary *_photoLists;
    NSString *_serviceName;
    NSString *_userID;
    NSString *_username;
    
    OAConsumer *consumer;
    OAToken *requestToken;
    OAToken *accessToken;
}

@property (nonatomic, strong, readonly) NSString *serviceName;
@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *username;

// Authorization
@property (nonatomic, weak) id <EMTLPhotoSourceAuthorizationDelegate> authorizationDelegate;
- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;

// Photo List Loading
- (EMTLPhotoList *)currentPhotos;
- (EMTLPhotoList *)popularPhotos;
- (EMTLPhotoList *)favoritePhotosForUser:(NSString *)user_id;
- (EMTLPhotoList *)photosForUser:(NSString *)user_id;
- (void)fetchPhotosForPhotoList:(EMTLPhotoList *)photoList;
- (void)operation:(NSOperation *)operation fetchedData:(NSData *)data forPhotoList:(EMTLPhotoList *)photoList withQuery:(NSDictionary *)query;
- (void)operation:(NSOperation *)operation isFetchingDataWithProgress:(float)progress forPhotoList:(EMTLPhotoList *)photoList;

// Photo Asset Loading
- (EMTLPhotoAssets *)assetsForPhoto:(EMTLPhoto *)photo;

@end

//
//  EMTLFlickr.h
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"

@class EMTLPhoto;

@interface EMTLFlickrPhotoSource : EMTLPhotoSource

{
    int currentPage;
    int totalPages;
    
    int maxYear;
    int maxMonth;
    int maxDay;
    
    int minYear;
    int minMonth;
    int minDay;
    
    OAConsumer *consumer;
    OAToken *requestToken;
    OAToken *accessToken;
    
    BOOL loading;
}


- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;

- (void)updateNewestPhotos;
- (void)retrieveOlderPhotos;

- (NSString *)serviceName;

@end

//
//  EMTLFlickr.h
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"

@interface EMTLFlickrPhotoSource : EMTLPhotoSource
{
    OAConsumer *consumer;
    OAToken *requestToken;
    OAToken *accessToken;
}

@end

//
//  EMTLUser.h
//  Tempest
//
//  Created by Ian White on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "EMTLPhotoSource.h"
#import <Foundation/Foundation.h>

@protocol EMTLUserIconDelegate <NSObject>

- (void)userWillRequestIcon:(EMTLUser *)user;
- (void)user:(EMTLUser *)user didLoadIcon:(UIImage *)image;


@end

@interface EMTLUser : NSObject <NSCoding>
{
    id <EMTLUserIconDelegate> _delegate;
}


@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *real_name;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSURL *iconURL;
@property (nonatomic, strong) UIImage *icon;

@property (nonatomic) int numberOfPhotos;

@property (nonatomic) EMTLPhotoSource *source;

- (UIImage *)loadImageWithSize:(EMTLImageSize)size delegate:(id<EMTLUserIconDelegate>)delegate;

@end

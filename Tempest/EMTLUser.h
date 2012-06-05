//
//  EMTLUser.h
//  Tempest
//
//  Created by Ian White on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

@class EMTLUser;
@class EMTLPhotoSource;

@protocol EMTLUserDelegate <NSObject>

- (void)userWillLoad:(EMTLUser *)user;
- (void)userDidLoad:(EMTLUser *)user;


@end

@interface EMTLUser : NSObject <NSCoding>
{
    id <EMTLUserDelegate> _delegate;
    NSString *_userID;
    NSString *_username;
    NSString *_real_name;
    NSString *_location;
    NSURL *_iconURL;
    UIImage *_icon;
    NSDate *_date_retrieved;
    EMTLPhotoSource *_source;
}


@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *real_name;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSURL *iconURL;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSDate *date_retrieved;

@property (nonatomic) EMTLPhotoSource *source;

- (id)initWIthUserID:(NSString *)userID source:(EMTLPhotoSource *)source;

// Loading the user
- (void)loadUserWithDelegate:(id<EMTLUserDelegate>)delegate;

// Callbacks for User loading
- (void)photoSourceWillRequestUser:(EMTLPhotoSource *)source;
- (void)photoSourceDidLoadUser:(EMTLPhotoSource *)source;

@end

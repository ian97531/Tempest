//
//  EMTLComment.h
//  Flickrgram
//
//  Created by Ian White on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"

@interface EMTLComment : NSObject

@property (nonatomic, readonly) NSString *comment_id;
@property (nonatomic, readonly) NSString *user_id;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSURL *userIconURL;
@property (nonatomic, readonly) NSString *comment;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, strong) id <PhotoSource> source;

- (id)initWithDict:(NSDictionary *) dict;
- (NSURL *)userIconURL;

@end

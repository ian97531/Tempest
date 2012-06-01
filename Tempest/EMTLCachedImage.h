//
//  EMTLCachedImage.h
//  Tempest
//
//  Created by Ian White on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMTLCachedImage : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *datePosted;
@property (nonatomic, strong) NSURL *urlToImage;
@property (nonatomic, strong, readonly) NSString *filename;
@property (nonatomic, strong, readonly) NSString *path;

- (id)initWithDate:(NSDate *)date url:(NSURL *)url;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

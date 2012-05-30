//
//  EMTLPhotoAssets.h
//  Tempest
//
//  Created by Ian White on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMTLPhotoAssets : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSArray *favorites;
@property (nonatomic) float percentComplete;

@end

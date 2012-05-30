//
//  EMTLOperationQueue.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLOperationQueue.h"

@implementation EMTLOperationQueue

+ (id)photoQueue
{
    static dispatch_once_t once;
    static id photoQueue;
    dispatch_once(&once, ^{
        photoQueue = [[self alloc] init];
        [photoQueue setMaxConcurrentOperationCount:8];
        [photoQueue setSuspended:NO];
    });
    return photoQueue;
}

@end

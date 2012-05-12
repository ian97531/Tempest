//
//  EMTLPhotoQuery.m
//  Tempest
//
//  Created by Blake Seely on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoQuery.h"

@interface EMTLPhotoQuery ()
@end

@implementation EMTLPhotoQuery

- (id)initWithQueryID:(NSString *)queryID queryType:(EMTLPhotoQueryType)queryType arguments:(NSDictionary *)arguments delegate:(id<EMTLPhotoQueryDelegate>)delegate;
{
    self = [super init];
    if (self != nil)
    {
        _photoQueryID = [queryID copy];
        _queryType = queryType;
        _queryArguments = [arguments copy];
        _delegate = delegate;
    }
    
    return self;
}

@synthesize photoQueryID = _photoQueryID;
@synthesize queryType = _queryType;
@synthesize delegate = _delegate;
@synthesize queryArguments = _queryArguments;

- (NSArray *)photoList
{
    NSArray *photoList = [_photoList copy];
    return photoList;
}

@end

//
//  EMTLFlickrPhotoQuery.h
//  Tempest
//
//  Created by Blake Seely on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoQuery.h"

@interface EMTLFlickrPhotoQuery : EMTLPhotoQuery

@property (nonatomic, strong) NSURLRequest *currentURLRequest; // This is the request that's currently pending. A non-nil value means the source is busy requesting this. A nil value means this query is idle.
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger totalPages;
@property (nonatomic) NSInteger maxYear;
@property (nonatomic) NSInteger maxMonth;
@property (nonatomic) NSInteger maxDay;
@property (nonatomic) NSInteger minYear;
@property (nonatomic) NSInteger minMonth;
@property (nonatomic) NSInteger minDay;

@end

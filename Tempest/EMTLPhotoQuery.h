//
//  EMTLPhotoQuery.h
//  Tempest
//
//  Created by Blake Seely on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLConstants.h"

@protocol EMTLPhotoQueryDelegate;

@interface EMTLPhotoQuery : NSObject
{
    @private
    NSString *_photoQueryID;
    EMTLPhotoQueryType _queryType;
    NSDictionary *_queryArguments;
    __weak id<EMTLPhotoQueryDelegate> _delegate;
    
    @protected
    NSMutableArray *_photoList; // BSEELY: Not actually sure this has to be mutable. 
}

- (id)initWithQueryID:(NSString *)queryID queryType:(EMTLPhotoQueryType)queryType arguments:(NSDictionary *)arguments delegate:(id<EMTLPhotoQueryDelegate>)delegate;

@property (nonatomic, readonly) NSString *photoQueryID;
@property (nonatomic, readonly) EMTLPhotoQueryType queryType;
@property (nonatomic, readonly) NSDictionary *queryArguments;
@property (nonatomic, readonly, weak) id<EMTLPhotoQueryDelegate> delegate;

@property (nonatomic, readonly, copy) NSArray *photoList;

@end

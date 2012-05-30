//
//  EMTLPhotoList.h
//  Tempest
//
//  Created by Ian White on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLConstants.h"

@class EMTLPhotoList;

@protocol EMTLPhotoListDelegate
- (void)photoListWillUpdate:(EMTLPhotoList *)photoList;
- (void)photoListDidUpdate:(EMTLPhotoList *)photoList;
//- (void)photoSource:(EMTLPhotoSource *)photoSource willChangePhoto:(EMTLPhoto *)photo;
//- (void)photoSource:(EMTLPhotoSource *)photoSource didChangePhoto:(EMTLPhoto *)photo;
@end


@interface EMTLPhotoList : NSObject
{
@private
    __weak id<EMTLPhotoListDelegate> _delegate;
    
@protected
    NSMutableArray *_photoList; // BSEELY: Not actually sure this has to be mutable. 
}

@property (nonatomic, readonly, weak) id<EMTLPhotoListDelegate> delegate;


@end

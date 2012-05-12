//
//  EMTLPhotoSource_Private.h
//  Tempest
//
//  Created by Blake Seely on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoSource.h"
#import "EMTLPhotoQuery.h"

@interface EMTLPhotoSource ()

// Subclasses should override
- (Class)_queryClass;
- (void)_setupQuery:(EMTLPhotoQuery *)query;
- (void)_runQuery:(EMTLPhotoQuery *)query;
- (void)_updateQuery:(EMTLPhotoQuery *)query;
- (void)_reloadQuery:(EMTLPhotoQuery *)query;
- (void)_stopQuery:(EMTLPhotoQuery *)query;
- (void)_removeQuery:(EMTLPhotoQuery *)query;

// Subclasses should NOT override, but call when necessary
- (void)_didChangeQuery:(EMTLPhotoQuery *)query;

@end

//
//  EMTLPhotoSource.m
//  Tempest
//
//  Created by Ian White on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EMTLPhotoSource.h"
#import "EMTLPhotoSource_Private.h"
#import "EMTLPhoto.h"

NSString *const kPhotoUsername = @"user_name";
NSString *const kPhotoUserID = @"user_id";
NSString *const kPhotoTitle = @"photo_title";
NSString *const kPhotoID = @"photo_id";
NSString *const kPhotoImageURL = @"image_url";
NSString *const kPhotoImageAspectRatio = @"aspect_ratio";
NSString *const kPhotoDatePosted = @"date_posted";
NSString *const kPhotoDateUpdated = @"date_updated";
NSString *const kPhotoComments = @"comments_domain";
NSString *const kPhotoFavorites = @"favorites_domain";

NSString *const kCommentText = @"comment_text";
NSString *const kCommentDate = @"comment_date";
NSString *const kCommentUsername = @"user_name";
NSString *const kCommentUserID = @"user_id";
NSString *const kCommentIconURL = @"icon_url";

NSString *const kFavoriteDate = @"favorite_date";
NSString *const kFavoriteUsername = @"user_name";
NSString *const kFavoriteUserID = @"user_id";
NSString *const kFavoriteIconURL = @"icon_url";

NSString *const kEMTLPhotoImage = @"photo_image";
NSString *const kEMTLPhotoComments = @"photo_comments";
NSString *const kEMTLPhotoFavorites = @"photo_favorites";

@interface EMTLPhotoSource ()
- (NSString *)_photoQueryIDFromQueryType:(EMTLPhotoQueryType)queryType andArguments:(NSDictionary *)arguments; // Assumes that argument keys and values are strings

- (NSSet *)_allQueries;
- (EMTLPhotoQuery *)_photoQueryForQueryID:(NSString *)photoQueryID;
- (void)_addPhotoQuery:(EMTLPhotoQuery *)query forQueryID:(NSString *)photoQueryID;
- (void)_removePhotoQueryForQueryID:(NSString *)photoQueryID;

- (void)_willChangeQuery:(EMTLPhotoQuery *)query;
@end


@implementation EMTLPhotoSource

@synthesize userID;
@synthesize username;

- (id)init
{
    self = [super init];
    if (self)
    {
        _photoQueries = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSString *)serviceName
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override EMTLPhotoSource's %@ method in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSSet *)queries
{
    NSSet *queries = [self _allQueries];
    return queries;
}

#pragma mark -
#pragma mark Authorization

@synthesize authorizationDelegate = _authorizationDelegate;

- (void)authorize
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override EMTLPhotoSource's %@ method in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


- (void)authorizedWithVerifier:(NSString *)verfier
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override EMTLPhotoSource's %@ method in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


#pragma mark -
#pragma Photo Query

- (NSString *)addPhotoQueryType:(EMTLPhotoQueryType)queryType withArguments:(NSDictionary *)queryArguments queryDelegate:(id<EMTLPhotoQueryDelegate>)queryDelegate
{
    // Generate the query ID
    NSString *queryID = [self _photoQueryIDFromQueryType:queryType andArguments:queryArguments];
    
    // See if we already have a query for this guy
    EMTLPhotoQuery *query = [self _photoQueryForQueryID:queryID];
    
    // Sanity Check - since we can only handle a single delegate per query, this method should really never get called with this query
    // already exists.
    // NOTE: If we decide to comment out this assert, then we have to fire the one below
    NSAssert(query == nil, @"We already have this query");
    
    // Sanity Check - we can only have a single delegate per query right now. If this assert fires, then we are either doing something
    // wrong or we need to update our structures to handle multiple delegates per query.
    // NOTE: If we are not going to fire the above assert, then we at least have to fire this.
//    if (query != nil)
//    {
//        NSAssert(query.delegate == queryDelegate, @"We can't add a second delegate to an existing query");
//    }
    
    // Create the query
    if (query == nil)
    {
        // Create it
        EMTLPhotoQuery *query = [[[self _queryClass] alloc] initWithQueryID:queryID queryType:queryType arguments:queryArguments delegate:queryDelegate];
        
        // Add it to our list
        [self _addPhotoQuery:query forQueryID:queryID];

        // Let subclasses do any setup they need to do
        [self _setupQuery:query];
        
        // Let subclasses actually run the query
        [self _runQuery:query];
    }
    else
    {
        // We already have this query so just update it?
        // NOTE: If we're asserting on non-nil queries above, we will never hit this.
        [self _updateQuery:query];
    }
    
    return queryID;
}

- (NSArray *)photoListForQuery:(NSString *)queryID
{
    // Sanity Check
    EMTLPhotoQuery *query = [self _photoQueryForQueryID:queryID];
    NSAssert(query != nil, @"We don't have a query for this query ID");
    
    NSArray *photoList = [query photoList];
    return photoList;
}

- (void)removeQuery:(NSString *)queryID
{
    // Sanity Check
    EMTLPhotoQuery *query = [self _photoQueryForQueryID:queryID];
    NSAssert(query != nil, @"We don't have a query for this query ID");
    
    // Let subclasses handle stopping this query
    [self _stopQuery:query];
    [self _removeQuery:query];
    
    // Stop tracking this query
    [self _removePhotoQueryForQueryID:query.photoQueryID];
}

- (void)reloadQuery:(NSString *)queryID
{
    // Sanity Check
    EMTLPhotoQuery *query = [self _photoQueryForQueryID:queryID];
    NSAssert(query != nil, @"We don't have a query for this query ID");
    
    // Notify the delegate
    [self _willChangeQuery:query];
    
    // Let the subclass do the work and call _didChangeQuery
    [self _reloadQuery:query];
}

- (void)updateQuery:(NSString *)queryID
{
    // Sanity Check
    EMTLPhotoQuery *query = [self _photoQueryForQueryID:queryID];
    NSAssert(query != nil, @"We don't have a query for this query ID");
    
    // Notify the delegate
    [self _willChangeQuery:query];
    
    // Let the subclass do the work and also call _didChangeQuery
    [self _updateQuery:query];
}

#pragma mark -
#pragma mark Image Loading

- (UIImage *)loadImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size imageDelegate:(id<EMTLImageDelegate>)imageDelegate
{
    return nil;
}

- (void)cancelAllImagesForPhoto:(EMTLPhoto *)photo
{
    
}

- (void)cancelLoadImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size
{
    
}

#pragma mark -
#pragma mark Private Subclass Overrides

- (Class)_queryClass
{
    return [EMTLPhotoQuery class];
}

- (void)_setupQuery:(EMTLPhotoQuery *)query
{
    // Subclasses override
}

- (void)_runQuery:(EMTLPhotoQuery *)query
{
    // Subclasses override
}

- (void)_updateQuery:(EMTLPhotoQuery *)query
{
    // Subclasses override
}

- (void)_reloadQuery:(EMTLPhotoQuery *)query
{
    // Subclasses override
}

- (void)_stopQuery:(EMTLPhotoQuery *)query
{
    // Subclasses override
}

- (void)_removeQuery:(EMTLPhotoQuery *)query
{
    // Subclassess override
}

#pragma mark -
#pragma mark Private

- (NSString *)_photoQueryIDFromQueryType:(EMTLPhotoQueryType)queryType andArguments:(NSDictionary *)arguments
{
    // Sanity Check
    NSAssert((queryType >= EMTLPhotoQueryTimeline) && (queryType < EMTLPhotoQueryTypeUndefined), @"Cannot create a query ID from an invalid query type");
    
    // Turn the query type into a string
    NSString *queryTypeString = [[NSNumber numberWithInt:queryType] stringValue];
    
    // Turn the arguments into a string
    NSMutableString *wholeString = [NSMutableString stringWithString:@""];
    [arguments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *keyValueString = [NSString stringWithFormat:@"%@_%@", (NSString *)key, (NSString *)obj];
        [wholeString appendString:keyValueString];
    }];
    
    // Add the query type string and the argument string
    [wholeString appendString:queryTypeString];
    
    // Hashish
    NSUInteger hash = [wholeString hash];
    
    // Get the query ID by converting the hash into a string
    NSNumber *hashNumber = [NSNumber numberWithUnsignedInteger:hash];
    NSString *queryID = [hashNumber stringValue];
    
    return queryID;
}

- (NSSet *)_allQueries
{
    NSSet *allQueries = nil;
    
    NSArray *queriesArray = [_photoQueries allValues];
    allQueries = [NSSet setWithArray:queriesArray];
    
    return allQueries;
}

- (EMTLPhotoQuery *)_photoQueryForQueryID:(NSString *)photoQueryID
{
    // Sanity Check
    NSAssert(photoQueryID != nil, @"Cannot find a query for a nil query ID");
    
    // See if we've got this guy already
    EMTLPhotoQuery *query = [_photoQueries objectForKey:photoQueryID];
    return query;
}

- (void)_addPhotoQuery:(EMTLPhotoQuery *)query forQueryID:(NSString *)photoQueryID
{
    // Sanity Check
    NSAssert(photoQueryID != nil, @"Cannot add a query for a nil query ID");
    NSAssert(query != nil, @"Cannot add a nil query");
    
    [_photoQueries setObject:query forKey:photoQueryID];
}

- (void)_removePhotoQueryForQueryID:(NSString *)photoQueryID
{
    // Sanity Check
    NSAssert(photoQueryID != nil, @"Cannot remove a query for a nil query ID");
    
    // Kill it.
    [_photoQueries removeObjectForKey:photoQueryID];
}

- (void)_willChangeQuery:(EMTLPhotoQuery *)query
{
    [query.delegate photoSource:self willUpdateQuery:query.photoQueryID];
}

- (void)_didChangeQuery:(EMTLPhotoQuery *)query
{
    [query.delegate photosource:self didUpdateQuery:query.photoQueryID];
}

@end

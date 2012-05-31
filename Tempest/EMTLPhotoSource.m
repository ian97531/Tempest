//
//  EMTLPhotoSource.m
//  Tempest
//
//  Created by Ian White on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EMTLPhotoQuery.h"
#import "EMTLPhotoSource.h"
#import "EMTLPhoto.h"
#import "EMTLPhotoSource_Private.h"

NSString *const kPhotoUsername = @"user_name";
NSString *const kPhotoUserID = @"user_id";
NSString *const kPhotoTitle = @"photo_title";
NSString *const kPhotoID = @"photo_id";
NSString *const kPhotoImageURL = @"image_url";
NSString *const kPhotoImageAspectRatio = @"aspect_ratio";
NSString *const kPhotoDatePosted = @"date_posted";
NSString *const kPhotoDateUpdated = @"date_updated";


NSString *const kCommentText = @"comment_text";
NSString *const kCommentDate = @"comment_date";
NSString *const kCommentUsername = @"user_name";
NSString *const kCommentUserID = @"user_id";
NSString *const kCommentIconURL = @"icon_url";

NSString *const kFavoriteDate = @"favorite_date";
NSString *const kFavoriteUsername = @"user_name";
NSString *const kFavoriteUserID = @"user_id";
NSString *const kFavoriteIconURL = @"icon_url";

@interface EMTLPhotoSource ()
- (NSString *)_photoQueryIDFromQueryType:(EMTLPhotoQueryType)queryType andArguments:(NSDictionary *)arguments; // Assumes that argument keys and values are strings

- (NSSet *)_allQueries;
- (EMTLPhotoQuery *)_photoQueryForQueryID:(NSString *)photoQueryID;
- (void)_addPhotoQuery:(EMTLPhotoQuery *)query forQueryID:(NSString *)photoQueryID;

@end


@implementation EMTLPhotoSource

@synthesize userID = _userID;
@synthesize username = _username;
@synthesize serviceName = _serviceName;

- (id)init
{
    self = [super init];
    if (self)
    {
        _photoQueries = [NSMutableDictionary dictionary];
        _imageCache = [NSMutableDictionary dictionary];
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

- (EMTLPhotoQuery *)currentPhotos
{
    return [self addPhotoQueryType:EMTLPhotoQueryTimeline withArguments:nil];
}

- (EMTLPhotoQuery *)popularPhotos;
{
    return [self addPhotoQueryType:EMTLPhotoQueryPopularPhotos withArguments:nil];
}

- (EMTLPhotoQuery *)favoritePhotosForUser:(NSString *)user_id
{    
    if (!user_id) {
        user_id = _userID;
    }
    NSDictionary *args = [NSDictionary dictionaryWithObject:user_id forKey:kPhotoUserID];
    
    return [self addPhotoQueryType:EMTLPhotoQueryFavorites withArguments:args];
}

- (EMTLPhotoQuery *)photosForUser:(NSString *)user_id
{
    if (!user_id) {
        user_id = _userID;
    }
    NSDictionary *args = [NSDictionary dictionaryWithObject:user_id forKey:kPhotoUserID];
    
    return [self addPhotoQueryType:EMTLPhotoQueryUserPhotos withArguments:args];
}

- (EMTLPhotoQuery *)addPhotoQueryType:(EMTLPhotoQueryType)queryType withArguments:(NSDictionary *)queryArguments
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
        query = [[EMTLPhotoQuery alloc] initWithQueryID:queryID queryType:queryType arguments:queryArguments source:self];
        
        // Add it to our list
        [self _addPhotoQuery:query forQueryID:queryID];
        
        // Let subclasses do any setup they need to do
        query.queryArguments = [self _setupQueryArguments:queryArguments forQuery:query];
        query.blankQueryArguments = [query.queryArguments copy];
        
    }
    
    return query;
}

- (NSDictionary *)_setupQueryArguments:(NSDictionary *)queryArguments forQuery:(EMTLPhotoQuery *)query
{
    // Subclasses override
}

- (void)updateQuery:(EMTLPhotoQuery *)query
{
    // Subclasses override
}

- (void)cancelQuery:(EMTLPhotoQuery *)query
{
    // Subclasses override
}



#pragma mark -
#pragma mark Image Loading



- (UIImage *)imageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size
{
    // Subclasses override
    return nil;
}


- (void)cancelImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size
{
    // Subclasses override
}


#pragma mark -
#pragma mark Private Subclass Overrides


- (void)_setupQuery:(EMTLPhotoQuery *)query
{
    // Subclasses override
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


@end
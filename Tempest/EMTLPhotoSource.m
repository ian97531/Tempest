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

NSString *const kPhotoObject = @"photo_object";

NSString *const kPhotoUsername = @"user_name";
NSString *const kPhotoUserID = @"user_id";
NSString *const kPhotoTitle = @"photo_title";
NSString *const kPhotoID = @"photo_id";
NSString *const kPhotoImageURL = @"image_url";
NSString *const kPhotoImageAspectRatio = @"aspect_ratio";
NSString *const kPhotoDatePosted = @"date_posted";
NSString *const kPhotoDateUpdated = @"date_updated";
NSString *const kPhotoComments = @"comments";
NSString *const kPhotoFavorites = @"favorites";
NSString *const kPhotoIsFavorite = @"is_favorite";

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
- (void)_initImageCache;

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
        
        
        // In-memory caching for images
        _imageCache = [[NSCache alloc] init];
        
        
        // Setup disk image caching
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                                NSUserDomainMask, YES);
        NSString *cacheDir = [dirPaths objectAtIndex:0];
        
        _imageCacheDir = [cacheDir stringByAppendingString:@"/images"];
        
        NSError *error = nil;
        [fileManager createDirectoryAtPath:_imageCacheDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        // If there's an error, disable image caching by nilling out the directory variable.
        // Otherwise, initialize the image cache.
        if (error)
        {
            NSLog(@"Error creating the _imageCacheDir. Disabling image caching.  %@", [error localizedDescription]);
            _imageCacheDir = nil;
        }
        else
        {
            [self _initImageCache];
        }
        
        
        // Setup disk photo list caching.
        _photoListCacheDir = [cacheDir stringByAppendingString:@"/photo_lists"];
        _photoListCacheDates = [NSMutableDictionary dictionary];
        
        // Create the photo list caching directory
        error = nil;
        [fileManager createDirectoryAtPath:_photoListCacheDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        // If unable to create the directory, disable photolist caching by setting the variable to nil
        if (error)
        {
            NSLog(@"Error creating the _photoListCacheDir. Disabling photolist caching.  %@", [error localizedDescription]);
            _photoListCacheDir = nil;
        }
        
    }
    return self;
}

- (void)_initImageCache
{
    NSLog(@"initializing the disk image cache");
    
    // Create our queue for background disk image cache operations.
    _imageCacheQueue = dispatch_queue_create("com.Elemental.ImageCacheQueue", DISPATCH_QUEUE_SERIAL);
        
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Grab the an enumerator to list the contents of the image cache directory.
    NSError *error = nil;
    NSURL *imageCacheURL = [NSURL fileURLWithPath:_imageCacheDir isDirectory:YES];
    NSArray *fileProperties = [NSArray arrayWithObjects:NSURLNameKey, NSURLCreationDateKey, nil];
    NSDirectoryEnumerator *imageEnumerator = [fileManager enumeratorAtURL:imageCacheURL 
                                               includingPropertiesForKeys:fileProperties 
                                                                  options:nil
                                                             errorHandler:^(NSURL *url, NSError *error) {
                                                                 NSLog(@"An error occurred while enumerating over %@.", [url absoluteString]);
                                                                 NSLog(@"Error: %@", [error localizedDescription]);
                                                                 return YES;
                                                             }];
    
    _imageCacheFiles = [NSMutableDictionary dictionary];
    
    NSLog(@"Reading the contents of the image cache directory");
    // Save the creation dates for each file in the image cache directory
    for (NSURL *fileURL in imageEnumerator) {
        
        NSDate *creationDate;
        [fileURL getResourceValue:&creationDate forKey:NSURLCreationDateKey error:nil];
        
        [_imageCacheFiles setObject:fileURL forKey:creationDate];
    }
    
    
    // If we retrieved any files, process them
    if([_imageCacheFiles count]) {
        
        NSLog(@"We have files in the disk image cache!");
        // Find the newest image in the cache, save that as the newest date in _imageCacheDate
        _imageCacheSortedDates = [[_imageCacheFiles allKeys] mutableCopy];
                                   
        [_imageCacheSortedDates sortUsingComparator:^(NSDate *date1, NSDate *date2) {
            return [date1 compare:date2];
        }];
        
        
        // Start loading the images into the in-memory cache in the background in descending date order.
        // We queue each iteration separately in a serial queue so that the imageFromCacheWithSize:forPhoto:
        // method can squeeze some blocks in to pull out photos while we're still populating the in-memory cache.
        

        for (NSDate *fileDate in _imageCacheSortedDates) {
            dispatch_async(_imageCacheQueue, ^{
                
                NSURL *fileURL = [_imageCacheFiles objectForKey:fileDate];
                
                // Force CG to draw the image so the JPEG is already decompressed by the time
                // our view controller gets its hand on this. This helps to avoid a stutter
                // when displaying the image on-screen for the first time.
                UIImage *image = [UIImage imageWithContentsOfFile:[fileURL path]];
                UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
                [image drawAtPoint:CGPointZero];
                UIGraphicsEndImageContext();
                
                // Save the image to our in-memory cache.
                [_imageCache setObject:image forKey:[[fileURL pathComponents] lastObject]];
                NSLog(@"Loaded %@ into the in-memory cache", [[fileURL pathComponents] lastObject]);
            
            });
        }
    }
    else {
        NSLog(@"Found no files in the disk image cache");
        _imageCacheSortedDates = [NSMutableArray array];
    }
    
    
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
    
    
    // See if the photo list for this query has been cached.
    NSArray *photoList = [self photoListFromCacheForQueryID:queryID];
    
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
        query = [[EMTLPhotoQuery alloc] initWithQueryID:queryID queryType:queryType arguments:queryArguments source:self cachedPhotos:photoList];
        
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
    return nil;
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
#pragma mark Caching Stuff
- (void)cachePhotoList:(NSArray *)photos forQueryID:(NSString *)queryID
{
    // If photo list caching is disabled, bail.
    if (!_photoListCacheDir) return;
    
    // Grab the date of the first photo in the list, and the date of the first photo in the cached list
    NSDate *dateOfFirstPhoto = [[photos objectAtIndex:0] datePosted];
    NSDate *dateOfCachedList = [_photoListCacheDates objectForKey:queryID];
    
    // If no date is cached, or the new photos passed in are newer than the cached photolist,
    // overwrite the existing cached photo list with the new list.
    if (!dateOfCachedList || [dateOfFirstPhoto compare:dateOfCachedList] == NSOrderedDescending)
    {
        // Serialize and write out the photo list to the cache.
        NSString *cachePath = [NSString stringWithFormat:@"%@/%@", _photoListCacheDir, queryID];
        if([NSKeyedArchiver archiveRootObject:photos toFile:cachePath])
        {
            // If successful, save the new date for this query ID
            [_photoListCacheDates setObject:dateOfFirstPhoto forKey:queryID];
            NSLog(@"successfully cached queryID: %@ to disk", queryID);
        }
        else {
            NSLog(@"Unable to write queryID %@ to disk", queryID);
        }
    }
    else
    {
        NSLog(@"photo list not newer than existing cached list, skipping cache.");
    }
    
}


- (NSArray *)photoListFromCacheForQueryID:(NSString *)queryID
{
    if (!_photoListCacheDir) return nil;
    
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@", _photoListCacheDir, queryID];
    NSArray *photoList = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    
    if (photoList) {
        NSLog(@"Found photo list in cache for queryID: %@", queryID);
        for (EMTLPhoto *photo in photoList) {
            photo.source = self;
        }
    }
    
    return photoList;
}

- (void)cacheImage:(UIImage *)image withSize:(EMTLImageSize)size forPhoto:(EMTLPhoto *)photo
{
    NSString *cacheKey = [self _cacheKeyForPhoto:photo imageSize:size];
    [_imageCache setObject:image forKey:cacheKey];
    
    // Next we want to dispatch a background block to see if we should store this image in
    // our on-disk cache. The on-disk cache is only used when starting up the app.
    dispatch_async(_imageCacheQueue, ^{
        
        // If this image is newer than the last image in our disk cache, or there are fewer
        // than 100 objects in our disk cache, then add this to the cache.
        if (_imageCacheSortedDates.count <= 100 || [photo.datePosted compare:[_imageCacheSortedDates lastObject]]) {
            
            NSLog(@"Saving image %@ into the on-disk cache", cacheKey);
            // Write the image into the correct location in the image cache.
            NSString *cachedImagePath = [NSString stringWithFormat:@"%@/%@", _imageCacheDir, cacheKey];
            NSURL *imageURL = [NSURL fileURLWithPath:cachedImagePath isDirectory:NO];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            [imageData writeToFile:cachedImagePath atomically:YES];
            
            // Save the URL into our cached files dictionary
            // Save the date into our sorted date array
            [_imageCacheFiles setObject:imageURL forKey:photo.datePosted];
            [_imageCacheSortedDates addObject:photo.datePosted];
            
            [_imageCacheSortedDates sortUsingComparator:^(NSDate *date1, NSDate *date2) {
                return [date1 compare:date2];
            }];
            
        }
        
    });
    
}

- (UIImage *)imageFromCacheWithSize:(EMTLImageSize)size forPhoto:(EMTLPhoto *)photo
{
    NSString *cacheKey = [self _cacheKeyForPhoto:photo imageSize:size];
    UIImage *image = [_imageCache objectForKey:cacheKey];
    if (image) {
        NSLog(@"got image for %@ from cache", cacheKey);
    }   
    else {
        NSLog(@"did not get image for %@ from cache", cacheKey);
    }
    
    return image;
}


- (NSString *)_cacheKeyForPhoto:(EMTLPhoto *)photo imageSize:(EMTLImageSize)size
{
    return [NSString stringWithFormat:@"%@-%i", photo.uniqueID, size];
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
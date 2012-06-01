//
//  EMTLFlickrFetchPhotoListOperation.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrFetchFavoritesAndCommentsOperation.h"
#import "EMTLFlickrFetchPhotoQueryOperation.h"
#import "EMTLFlickrPhotoSource.h"
#import "EMTLPhotoQuery.h"
#import "EMTLPhoto.h"
#import "APISecrets.h"

static double const kSecondsInThreeMonths = 7776500;
static int const kPhotosToLoad = 50;

@interface EMTLFlickrFetchPhotoQueryOperation ()

- (int)pagesOfResults:(NSDictionary *)dictionary;
- (NSArray *)_extractPhotos:(NSDictionary *)dictionary;
- (NSDictionary *)_updateQueryArguments:(NSDictionary *)queryArguments;


@end


@implementation EMTLFlickrFetchPhotoQueryOperation

@synthesize photoQuery= _photoQuery;
@synthesize photoSource = _photoSource;
@synthesize identifier = _identifier;

- (id)initWithPhotoQuery:(EMTLPhotoQuery *)photoQuery photoSource:(EMTLFlickrPhotoSource *)photoSource
{
    self = [super init];
    if (self)
    {
        _photoQuery = photoQuery;
        _photoSource = photoSource;
        _executing = NO;
        _finished = NO;
        _query = [self _updateQueryArguments:photoQuery.queryArguments];
        
        _commentsAndFavorites = [[NSOperationQueue alloc] init];
        [_commentsAndFavorites setMaxConcurrentOperationCount:5];
        [_commentsAndFavorites setSuspended:NO];
    }
    
    return self;
    
}


- (void)start
{
    
    if (_finished) {
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    
    
    NSMutableDictionary *queryArguments = [NSMutableDictionary dictionaryWithDictionary:_query];
    
    // Build the request paramets and the OAMutableURLRequest.
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithCapacity:8];
    
    [requestParameters setObject:kFlickrAPIKey forKey:kFlickrAPIArgumentAPIKey];
    [requestParameters setObject:[[NSNumber numberWithInt:kPhotosToLoad] stringValue] forKey:kFlickrAPIArgumentItemsPerPage];
    [requestParameters setObject:@"all" forKey:kFlickrAPIArgumentContacts];
    [requestParameters setObject:@"date_upload,owner_name,o_dims,last_update" forKey:kFlickrAPIArgumentExtras];
    [requestParameters setObject:@"date-posted-desc" forKey:kFlickrAPIArgumentSort];
    
    [requestParameters setObject:[NSString stringWithFormat:@"%04i-%02i-%02i", 
                                  [[queryArguments valueForKey:kFlickrQueryMinYear] intValue], 
                                  [[queryArguments valueForKey:kFlickrQueryMinMonth] intValue], 
                                  [[queryArguments valueForKey:kFlickrQueryMinDay] intValue]] 
                          forKey:@"min_upload_date"];
    
    // If a max year, month and day are set, pass them in as a parameter as well.
    int maxYear = [[queryArguments valueForKey:kFlickrQueryMaxYear] intValue];
    int maxMonth = [[queryArguments valueForKey:kFlickrQueryMaxMonth] intValue];
    int maxDay = [[queryArguments valueForKey:kFlickrQueryMaxDay] intValue];
    
    if (maxYear && maxMonth && maxDay) {
        [requestParameters setObject:[NSString stringWithFormat:@"%04d-%02d-%02d", maxYear, maxMonth, maxDay] forKey:@"max_upload_date"];
    }
    
    // If we have a page we care about, pass that as well.
    int currentPage = [[queryArguments valueForKey:kFlickrQueryCurrentPage] intValue];
    if (currentPage) {
        [requestParameters setObject:[[NSNumber numberWithInt:currentPage + 1] stringValue] forKey:@"page"];
    }
    
    // Let the photo source know that we're about to begin. We do this on the main thread in case
    // this causes a UI update.
    dispatch_sync(dispatch_get_main_queue(), ^{ 
        if (!_executing)
        {
            NSLog(@"aborting photo query operation");
            return;
        }
        [_photoSource operation:self willFetchPhotosForQuery:_photoQuery];
    });
    
    // Construct the request to Flickr
    OAMutableURLRequest *request = [_photoSource oaurlRequestForMethod:[queryArguments objectForKey:kFlickrQueryMethod] arguments:requestParameters];
    request.timeoutInterval = 10;
    
    NSLog(@"%@", [[request URL] absoluteString]);
    
    // Send the request for the photos synchronously.
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *reply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"we got an error requesting the photo list");
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    
    NSDictionary *responseDictionary = [_photoSource dictionaryFromResponseData:reply];
    
    // Make sure the query reflects the correct number of remaining results.
    [_query setValue:[NSNumber numberWithInt:[self pagesOfResults:responseDictionary]] forKey:kFlickrQueryTotalPages];
    
    // Get the photos
    NSArray *photos = [self _extractPhotos:responseDictionary];
    
    // For each photo we need to gather the comments and favorites. We do this in clumps of 5
    // photos at a time and stream the results back to the photosource.
    for (int i=0; i < photos.count; i = i + 5) {
        if (!_executing) return;
        
        for (int j=0; j < 5; j++) {
            if ( i + j < photos.count)
            {
                EMTLPhoto *photo = [photos objectAtIndex:(i + j)];
                EMTLFlickrFetchFavoritesAndCommentsOperation *favOp = [[EMTLFlickrFetchFavoritesAndCommentsOperation alloc] initWithPhoto:photo photoSource:_photoSource];
                [_commentsAndFavorites addOperation:favOp];
            }
        }
        
        [_commentsAndFavorites waitUntilAllOperationsAreFinished];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!_executing) 
            {
                NSLog(@"aborting photo query operation");
                return;
            }
            
            // Make sure the range we specifiy doesn't exceed the size of the photos array.
            // This comes into play when we're sending the last set of photos back to the photosource.
            int rangeSize = photos.count - i >= 5 ? 5 : photos.count - i;
            
            // Send this set of 5 photos back to the photosource, make sure this happens on the main thread in case this causes UI updates.
            [_photoSource operation:self fetchedPhotos:[photos subarrayWithRange:NSMakeRange(i, rangeSize)] totalPhotos:photos.count forQuery:_photoQuery];
        });
        

    }
    
    // Let the photo source know that we've sent all of our photos. Send along the updated query as well that reflects how
    // we got these photos.
    [_photoSource operation:self finishedFetchingPhotos:photos forQuery:_photoQuery updatedArguments:_query];
        
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];

    
}

- (void)cancel
{
    NSLog(@"canceling the photo query operation");
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}


- (int)pagesOfResults:(NSDictionary *)dictionary
{
    return [[[dictionary objectForKey:@"photos"] objectForKey:@"pages"] intValue];
}


- (NSArray *)_extractPhotos:(NSDictionary *)newPhotos
{
    
    if (!newPhotos) {
        NSLog(@"There was an error interpreting the json response from the request for more photos from %@", _photoSource.serviceName);
        return nil;
    }
    
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:[[[newPhotos objectForKey:@"photos"] objectForKey:@"total"] intValue]];
    
    // Clean up the photo information...
    for (NSMutableDictionary *photoDict in [[newPhotos objectForKey:@"photos"] objectForKey:@"photo"]) {
        
        // Construct the image URL
        NSString *farm = [photoDict objectForKey:@"farm"];
        NSString *server = [photoDict objectForKey:@"server"];
        NSString *secret = [photoDict objectForKey:@"secret"];
        NSString *photo_id = [photoDict objectForKey:@"id"];
        
        NSURL *image_URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", farm, server, photo_id, secret, @"z"]];
        
        [photoDict setObject:image_URL forKey:kPhotoImageURL];
        
        // Get the dates
        NSDate* lastupdate = [NSDate dateWithTimeIntervalSince1970:[[photoDict objectForKey:@"lastupdate"] doubleValue]];
        NSDate* datePosted = [NSDate dateWithTimeIntervalSince1970:[[photoDict objectForKey:@"dateupload"] doubleValue]];
        
        [photoDict setObject:lastupdate forKey:kPhotoDateUpdated];
        [photoDict setObject:datePosted forKey:kPhotoDatePosted];
        
        // Set the aspect ratio
        if([photoDict objectForKey:@"o_width"] && [photoDict objectForKey:@"o_height"]) {
            float o_width = [[photoDict objectForKey:@"o_width"] floatValue];
            float o_height = [[photoDict objectForKey:@"o_height"] floatValue];
            
            [photoDict setObject:[NSNumber numberWithFloat:(o_width/o_height)] forKey:kPhotoImageAspectRatio];
        }
        
        
        [photoDict setObject:[photoDict objectForKey:@"id"] forKey:kPhotoID];
        [photoDict setObject:[photoDict objectForKey:@"owner"] forKey:kPhotoUserID];
        [photoDict setObject:[photoDict objectForKey:@"ownername"] forKey:kPhotoUsername];
        [photoDict setObject:[photoDict objectForKey:@"title"] forKey:kPhotoTitle];
        
        EMTLPhoto *photo = [[EMTLPhoto alloc] initWithDict:photoDict];
        photo.source = _photoSource;
        [photos addObject:photo];
    }
    
    return photos;
}


- (NSDictionary *)_updateQueryArguments:(NSDictionary *)queryArguments
{
    
    NSMutableDictionary *newQuery = [NSMutableDictionary dictionaryWithDictionary:queryArguments];
    NSLog(@"in _updateQueryArguments");
    NSLog(@"Old Query: %@", [newQuery description]);
    
    int minYear = 0;
    int minMonth = 0;
    int minDay = 0;
    
    int maxYear = 0;
    int maxMonth = 0;
    int maxDay = 0;
    
    int totalPages = 0;
    int currentPage = 0;
    
    // If the query is blank, setup the default date range of today to three months ago.
    if (![newQuery objectForKey:kFlickrQueryTotalPages]) 
    {
        
        NSDate *minDate = [NSDate dateWithTimeIntervalSinceNow:-kSecondsInThreeMonths];;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *minComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:minDate];
        
        totalPages = 1;
        currentPage = 0;
        
        minYear = [minComponents year];
        minMonth = [minComponents month];
        minDay = [minComponents day];
        
    }
    
    // If it's not blank, then we need to either get the next page of results, or
    // adjust the date range.
    else {
        
        totalPages = [[newQuery objectForKey:kFlickrQueryTotalPages] intValue];
        currentPage = [[newQuery objectForKey:kFlickrQueryCurrentPage] intValue];
        
        minYear = [[newQuery objectForKey:kFlickrQueryMinYear] intValue];
        minMonth = [[newQuery objectForKey:kFlickrQueryMinMonth] intValue];
        minDay = [[newQuery objectForKey:kFlickrQueryMinDay] intValue];
        
        maxYear = [[newQuery objectForKey:kFlickrQueryMaxYear] intValue];
        maxMonth = [[newQuery objectForKey:kFlickrQueryMaxMonth] intValue];
        maxDay = [[newQuery objectForKey:kFlickrQueryMaxDay] intValue];
        
        
        // If we've run out of pages, we need to set a new date range to search and reset the page numbering.
        if (totalPages && currentPage + 1 >= totalPages) {
            
            maxYear = minYear;
            maxMonth = minMonth;
            maxDay = minDay;
            
            NSLog(@"Next search will change the date range.");            
            if ((minMonth - 3) < 1)
            {
                minMonth = 12 + (minMonth - 3);
                minYear = minYear - 1;
            }
            else
            {
                minMonth = minMonth - 3;
            }
            
            totalPages = 0;
            currentPage = 0;
            
            
        }
        
        // Otherwise, we should grab the next page of results.
        else {
            currentPage = [[newQuery objectForKey:kFlickrQueryCurrentPage] intValue] + 1;
        }
        
    }
    
    // Save the new values, so that we can refer to them them the next time we're asked for more photos.
    [newQuery setValue:[NSNumber numberWithInt:totalPages] forKey:kFlickrQueryTotalPages];
    [newQuery setValue:[NSNumber numberWithInt:currentPage] forKey:kFlickrQueryCurrentPage];
    [newQuery setValue:[NSNumber numberWithInt:maxYear] forKey:kFlickrQueryMaxYear];
    [newQuery setValue:[NSNumber numberWithInt:maxMonth] forKey:kFlickrQueryMaxMonth];
    [newQuery setValue:[NSNumber numberWithInt:maxDay] forKey:kFlickrQueryMaxDay];
    [newQuery setValue:[NSNumber numberWithInt:minYear] forKey:kFlickrQueryMinYear];
    [newQuery setValue:[NSNumber numberWithInt:minMonth] forKey:kFlickrQueryMinMonth];
    [newQuery setValue:[NSNumber numberWithInt:minDay] forKey:kFlickrQueryMinDay];
    
    return newQuery;
    
}


@end
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

@interface EMTLFlickrFetchPhotoQueryOperation ()

- (NSArray *)_processPhotos;
- (NSDictionary *)_updateQueryArguments;

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
        _incomingData = [NSMutableData data];
        _totalSize = 0;
        _commentsAndFavorites = [[NSOperationQueue alloc] init];
        [_commentsAndFavorites setMaxConcurrentOperationCount:5];
    }
    
    return self;
    
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    NSLog(@"got response");
    _totalSize = (uint)aResponse.expectedContentLength;
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
    // Figure out something good to do here.
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    _executing = NO;
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Got data");
    [_incomingData appendData:data];
    //float percent = (float)data.length/(float)_totalSize;
    //[_photoQuery photoSource:_photoSource isFetchingPhotosWithProgress:percent];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Finished loading");
    NSArray *photos = [self _processPhotos];
    
    for (EMTLPhoto *photo in photos) {
        EMTLFlickrFetchFavoritesAndCommentsOperation *favOp = [[EMTLFlickrFetchFavoritesAndCommentsOperation alloc] initWithPhoto:photo photoSource:_photoSource];
        [_commentsAndFavorites addOperation:favOp];
    }
    
    [_commentsAndFavorites waitUntilAllOperationsAreFinished];
    
    [_photoQuery photoSource:_photoSource fetchedPhotos:photos updatedQuery:_query];
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    _executing = NO;
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
    
}

- (void)start
{
    
    if (_finished) {
        return;
    }
    
    // Ensure that this operation starts on the main thread
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start)
                               withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    _query = [self _updateQueryArguments];
    
    NSMutableDictionary *queryArguments = [NSMutableDictionary dictionaryWithDictionary:_query];
    
    // Build the request paramets and the OAMutableURLRequest.
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithCapacity:8];
    
    [requestParameters setObject:kFlickrAPIKey forKey:kFlickrAPIArgumentAPIKey];
    [requestParameters setObject:@"100" forKey:kFlickrAPIArgumentItemsPerPage];
    [requestParameters setObject:@"all" forKey:@"contacts"];
    [requestParameters setObject:@"date_upload,owner_name,o_dims,last_update" forKey:@"extras"];
    [requestParameters setObject:@"date-posted-desc" forKey:@"sort"];
    
    [requestParameters setObject:[NSString stringWithFormat:@"%04d-%02d-%02d", 
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
    
    OAMutableURLRequest *request = [_photoSource oaurlRequestForMethod:[queryArguments objectForKey:kFlickrQueryMethod] arguments:requestParameters];
    
    NSLog(@"%@", [[request URL] absoluteString]);
    
    [_photoQuery photoSourceWillFetchPhotos:_photoSource];
    
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [_connection start];
    NSLog(@"Started the connection");
    NSLog([requestParameters description]);
    NSLog([queryArguments description]);
    
}

- (void)cancel
{
    [_connection cancel];
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    _executing = NO;
    
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


- (NSArray *)_processPhotos
{
    NSDictionary *newPhotos = [_photoSource dictionaryFromResponseData:_incomingData];
    NSLog([newPhotos description]);
    
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


- (NSDictionary *)_updateQueryArguments
{
    
    NSMutableDictionary *newQuery = [NSMutableDictionary dictionaryWithDictionary:_photoQuery.queryArguments];
    NSLog(@"in _updateQueryArguments");
    NSLog([newQuery description]);
    
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
        maxYear = maxYear;
        maxMonth = maxMonth;
        maxDay = maxDay;
        
        
        // If we've run out of pages, we need to set a new date range to search and reset the page numbering.
        if (currentPage >= totalPages) {
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

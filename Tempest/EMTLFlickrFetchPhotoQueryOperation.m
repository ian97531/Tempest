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
#import "EMTLLocation.h"
#import "APISecrets.h"

@interface EMTLFlickrFetchPhotoQueryOperation ()

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
    
    
    NSLog(@"Starting Photo Query: %@", _photoQuery);
    
    
    // Build the request paramets and the OAMutableURLRequest.
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithCapacity:8];
    NSDictionary *queryArguments = [self _updateQueryArguments:_photoQuery.queryArguments];
    switch (_photoQuery.queryType) {
        case EMTLPhotoQueryTimeline:
            [requestParameters setObject:EMTLFlickrAPIValuePhotoSearchContactsAll forKey:EMTLFlickrAPIArgumentContacts];
            break;
            
        case EMTLPhotoQueryUserPhotos:
            [requestParameters setObject:[queryArguments objectForKey:EMTLFlickrAPIArgumentUserID] forKey:EMTLFlickrAPIArgumentUserID];
            break;
            
        case EMTLPhotoQueryFavorites:
        case EMTLPhotoQueryPopularPhotos:
        default:
            return;
    }
    
    [requestParameters setObject:EMTLFlickrAPIKey 
                          forKey:EMTLFlickrAPIArgumentAPIKey];
    
    [requestParameters setObject:EMTLFlickrAPIValuePhotoItemsPerPage 
                          forKey:EMTLFlickrAPIArgumentItemsPerPage];
    
    [requestParameters setObject:EMTLFlickrAPIValuePhotoContentTypePhotosOnly 
                          forKey:EMTLFlickrAPIArgumentContentType];
    
    [requestParameters setObject:EMTLFlickrAPIValueSortDatePostedDescending 
                          forKey:EMTLFlickrAPIArgumentSort];
    
    [requestParameters setObject:EMTLFlickrAPIValuePhotoExtras 
                          forKey:EMTLFlickrAPIArgumentExtras];
    
    [requestParameters setObject:[NSString stringWithFormat:@"%04i-%02i-%02i", 
                                  [[queryArguments valueForKey:EMTLFlickrQueryMinYear] intValue], 
                                  [[queryArguments valueForKey:EMTLFlickrQueryMinMonth] intValue], 
                                  [[queryArguments valueForKey:EMTLFlickrQueryMinDay] intValue]] 
                          forKey:EMTLFlickrAPIArgumentMinUploadDate];
    
    // If a max year, month and day are set, pass them in as a parameter as well.
    int maxYear = [[queryArguments valueForKey:EMTLFlickrQueryMaxYear] intValue];
    int maxMonth = [[queryArguments valueForKey:EMTLFlickrQueryMaxMonth] intValue];
    int maxDay = [[queryArguments valueForKey:EMTLFlickrQueryMaxDay] intValue];
    
    if (maxYear && maxMonth && maxDay) {
        [requestParameters setObject:[NSString stringWithFormat:@"%04d-%02d-%02d", maxYear, maxMonth, maxDay] 
                              forKey:EMTLFlickrAPIArgumentMaxUploadDate];
    }
    
    // If we have a page we care about, pass that as well.
    int currentPage = [[queryArguments valueForKey:EMTLFlickrQueryCurrentPage] intValue];
    if (currentPage) {
        [requestParameters setObject:[[NSNumber numberWithInt:currentPage + 1] stringValue] 
                              forKey:EMTLFlickrAPIArgumentPageNumber];
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
    OAMutableURLRequest *request = [_photoSource oaurlRequestForMethod:[queryArguments objectForKey:EMTLFlickrQueryMethod] arguments:requestParameters];
    request.timeoutInterval = 10;
    
    //NSLog(@"%@", [[request URL] absoluteString]);
    
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
    NSString *pagesOfResults = [[responseDictionary objectForKey:EMTLFlickrAPIResponsePhotoList] objectForKey:EMTLFlickrAPIResponseListPages];
    [_query setValue:[NSNumber numberWithInt:pagesOfResults.intValue] 
              forKey:EMTLFlickrQueryTotalPages];
    
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
    
    NSLog(@"Ending Photo Query: %@", _photoQuery.photoQueryID);
    
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



- (NSArray *)_extractPhotos:(NSDictionary *)newPhotos
{
    
    if (!newPhotos) {
        NSLog(@"There was an error interpreting the json response from the request for more photos from %@", _photoSource.serviceName);
        return nil;
    }
    
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:
                              [[[newPhotos objectForKey:EMTLFlickrAPIResponsePhotoList] objectForKey:EMTLFlickrAPIResponseListTotalNumber] intValue]];
    
    // Clean up the photo information...
    for (NSMutableDictionary *photoDict in [[newPhotos objectForKey:EMTLFlickrAPIResponsePhotoList] objectForKey:EMTLFlickrAPIResponsePhotoListItems]) {
        
        NSString *photoID = [photoDict objectForKey:EMTLFlickrAPIResponsePhotoID];
        
        // Setup the user
        NSString *userID = [photoDict objectForKey:EMTLFlickrAPIResponsePhotoUserID];
        NSString *username = [photoDict objectForKey:EMTLFlickrAPIResponsePhotoUsername];
        NSString *iconFarm = [photoDict objectForKey:EMTLFlickrAPIResponseUserIconFarm];
        NSString *iconServer = [photoDict objectForKey:EMTLFlickrAPIResponseUserIconServer];
        
        EMTLUser *user = [_photoSource userForUserID:userID];
        user.username = username;
        user.iconURL = [NSURL URLWithString:[NSString stringWithFormat:EMTLFlickrUserIconURLFormat, iconFarm, iconServer, userID]];
            
        
        // Set the photo's details
        [photoDict setObject:photoID 
                      forKey:EMTLPhotoID];
        
        [photoDict setObject:user 
                      forKey:EMTLPhotoUser];
        
        [photoDict setObject:[photoDict objectForKey:EMTLFlickrAPIResponsePhotoTitle] 
                      forKey:EMTLPhotoTitle];
        
        [photoDict setObject:[[photoDict objectForKey:EMTLFlickrAPIResponsePhotoDescription] objectForKey:EMTLFlickrAPIResponseContent] 
                      forKey:EMTLPhotoDescription];
        
        [photoDict setObject:[NSNumber numberWithInt:[[photoDict objectForKey:EMTLFlickrAPIResponsePhotoLicense] intValue]]
                      forKey:EMTLPhotoLicense];
        
        [photoDict setObject:[[photoDict objectForKey:EMTLFlickrAPIResponsePhotoTags] componentsSeparatedByString:@" "] 
                      forKey:EMTLPhotoTags];

        
        // Construct the URLs
        NSString *farm = [photoDict objectForKey:EMTLFlickrAPIResponsePhotoFarm];
        NSString *server = [photoDict objectForKey:EMTLFlickrAPIResponsePhotoServer];
        NSString *secret = [photoDict objectForKey:EMTLFlickrAPIResponsePhotoSecret];
        
        
        [photoDict setObject:[NSURL URLWithString:[NSString stringWithFormat:EMTLFlickrImageURLFormat, farm, server, photoID, secret, EMTLFlickrAPIValuePhotoSizeMedium]]
                      forKey:EMTLPhotoImageURL];
        
        [photoDict setObject:[NSURL URLWithString:[NSString stringWithFormat:EMTLFlickrPhotoWebPageURLFormat, userID, photoID]]
                      forKey:EMTLPhotoWebPageURL];
         
        
        
        // Get the dates
        [photoDict setObject:[NSDate dateWithTimeIntervalSince1970:[[photoDict objectForKey:EMTLFlickrAPIResponsePhotoDateUpdated] doubleValue]]
                      forKey:EMTLPhotoDateUpdated];
        
        [photoDict setObject:[NSDate dateWithTimeIntervalSince1970:[[photoDict objectForKey:EMTLFlickrAPIResponsePhotoDatePosted] doubleValue]]
                      forKey:EMTLPhotoDatePosted];
        
        // Date Taken is given in a different format that's harder to parse (ie 2012-06-07 22:43:05)
        //[photoDict setObject:[NSDate dateWithString:[photoDict objectForKey:EMTLFlickrAPIResponsePhotoDateTaken]]
        //             forKey:EMTLPhotoDateTaken];
        
        
        
        // Set the aspect ratio
        NSString *width = [photoDict objectForKey:EMTLFlickrAPIResponsePhotoOriginalWidth];
        NSString *height = [photoDict objectForKey:EMTLFlickrAPIResponsePhotoOriginalHeight];
        
        if(width && height) {
            
            [photoDict setObject:[NSNumber numberWithFloat:(width.floatValue/height.floatValue)] 
                          forKey:EMTLPhotoImageAspectRatio];
        }
        
        
        // Create the actual photo object
        EMTLPhoto *photo = [[EMTLPhoto alloc] initWithSource:_photoSource dict:photoDict];
        
        
        // Save the location data into it.
        NSString *woe_id = [photoDict objectForKey:EMTLFlickrAPIResponsePhotoWOEID];
        if(woe_id)
        {
            photo.location = [[EMTLLocation alloc] init];
            photo.location.woe_id = woe_id;
        }
        
        // Add the photo to our internal list of photos retrieved by this operation.
        [photos addObject:photo];
    }
    
    return photos;
}


- (NSDictionary *)_updateQueryArguments:(NSDictionary *)queryArguments
{
    
    NSMutableDictionary *newQuery = [NSMutableDictionary dictionaryWithDictionary:queryArguments];
    //NSLog(@"in _updateQueryArguments:\n%@", newQuery);
    
    int minYear = 0;
    int minMonth = 0;
    int minDay = 0;
    
    int maxYear = 0;
    int maxMonth = 0;
    int maxDay = 0;
    
    int totalPages = 0;
    int currentPage = 0;
    
    // If the query is blank, setup the default date range of today to three months ago.
    if (![newQuery objectForKey:EMTLFlickrQueryTotalPages]) 
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
        
        totalPages = [[newQuery objectForKey:EMTLFlickrQueryTotalPages] intValue];
        currentPage = [[newQuery objectForKey:EMTLFlickrQueryCurrentPage] intValue];
        
        minYear = [[newQuery objectForKey:EMTLFlickrQueryMinYear] intValue];
        minMonth = [[newQuery objectForKey:EMTLFlickrQueryMinMonth] intValue];
        minDay = [[newQuery objectForKey:EMTLFlickrQueryMinDay] intValue];
        
        maxYear = [[newQuery objectForKey:EMTLFlickrQueryMaxYear] intValue];
        maxMonth = [[newQuery objectForKey:EMTLFlickrQueryMaxMonth] intValue];
        maxDay = [[newQuery objectForKey:EMTLFlickrQueryMaxDay] intValue];
        
        
        // If we've run out of pages, we need to set a new date range to search and reset the page numbering.
        if (totalPages && currentPage + 1 >= totalPages) {
            
            maxYear = minYear;
            maxMonth = minMonth;
            maxDay = minDay;
            
            //NSLog(@"Next search will change the date range.");            
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
            currentPage = [[newQuery objectForKey:EMTLFlickrQueryCurrentPage] intValue] + 1;
        }
        
    }
    
    // Save the new values, so that we can refer to them them the next time we're asked for more photos.
    [newQuery setValue:[NSNumber numberWithInt:totalPages] forKey:EMTLFlickrQueryTotalPages];
    [newQuery setValue:[NSNumber numberWithInt:currentPage] forKey:EMTLFlickrQueryCurrentPage];
    [newQuery setValue:[NSNumber numberWithInt:maxYear] forKey:EMTLFlickrQueryMaxYear];
    [newQuery setValue:[NSNumber numberWithInt:maxMonth] forKey:EMTLFlickrQueryMaxMonth];
    [newQuery setValue:[NSNumber numberWithInt:maxDay] forKey:EMTLFlickrQueryMaxDay];
    [newQuery setValue:[NSNumber numberWithInt:minYear] forKey:EMTLFlickrQueryMinYear];
    [newQuery setValue:[NSNumber numberWithInt:minMonth] forKey:EMTLFlickrQueryMinMonth];
    [newQuery setValue:[NSNumber numberWithInt:minDay] forKey:EMTLFlickrQueryMinDay];
    
    return newQuery;
    
}


@end

//
//  EMTLFlickrPhotoSource.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrPhotoSource.h"
#import "EMTLPhotoList.h"
#import "EMTLFlickrFetchPhotoListOperation.h"
#import "EMTLFlickrFetchPhotoAssetsOperation.h"
#import "EMTLOperationQueue.h"
#import "OAMutableURLRequest.h"
#import "APISecrets.h"


NSString *const kFlickrTimelinePhotoListID = @"flickr-timeline";
NSString *const kFlickrPopularPhotoListID = @"flickr-popular";

NSString *const kFlickrQueryTotalPages = @"flickr-total-pages";
NSString *const kFlickrQueryCurrentPage = @"flickr-current-page";
NSString *const kFlickrQueryMaxYear = @"flickr-max-year";
NSString *const kFlickrQueryMaxMonth = @"flickr-max-month";
NSString *const kFlickrQueryMaxDay = @"flickr-max-day";
NSString *const kFlickrQueryMinYear = @"flickr-min-year";
NSString *const kFlickrQueryMinMonth = @"flickr-min-month";
NSString *const kFlickrQueryMinDay = @"flickr-min-day";
NSString *const kFlickrQueryMethod = @"flickr-method";
NSString *const kFlickrQueryIdentifier = @"flickr-identifier";
NSString *const kFlickrQueryAPIKey = @"flickr-api-key";

NSString *const kFlickrAPIMethodSearch = @"flickr.photos.search";

NSString *const kFlickrRequestTokenURL = @"http://www.flickr.com/services/oauth/request_token";
NSString *const kFlickrAuthorizationURL = @"http://www.flickr.com/services/oauth/authorize";
NSString *const kFlickrAccessTokenURL = @"http://www.flickr.com/services/oauth/access_token";
NSString *const kFlickrAPICallURL = @"http://api.flickr.com/services/rest";
NSString *const kFlickrDefaultsServiceProviderName = @"flickr-access-token";
NSString *const kFlickrDefaultsPrefix = @"com.Elemental.Flickrgram";
NSString *const kFlickrDefaultIconURLString = @"http://www.flickr.com/images/buddyicon.gif";

static double const kSecondsInThreeMonths = 7776500;


@interface EMTLFlickrPhotoSource ()
- (OAMutableURLRequest *)_oaurlRequestForMethod:(NSString *)method arguments:(NSDictionary *)args;
- (NSDictionary *)_dictionaryFromResponseData:(NSData *)data;
- (BOOL)_isResponseOK:(NSDictionary *)responseDictionary;
- (NSMutableDictionary *)_blankQuery;

@end


@implementation EMTLFlickrPhotoSource

@synthesize serviceName = _serviceName;
@synthesize userID = _userID;
@synthesize username = _username;
@synthesize authorizationDelegate = _authorizationDelegate;


- (id)init
{
    self = [super init];
    if (self) {
        _photoLists = [[NSMutableDictionary alloc] initWithCapacity:6];
        _serviceName = @"flickr";
    }
    
    return self;
}


#pragma mark -
#pragma mark Authorization

/* 
 * authorize first tries to pull a flickr access token out of the app's
 * defaults. If successful, it attempts a test login to test the token
 * and acquire the user's user_id and username. 
 * If no access token is found, it starts the process of obtaining one
 * by first requesting a request token. On success, the request token
 * is handled by requestTokenTicket:didFinishWithData:
 * Eventually authorizationCompleteForSource: is called once a successful
 * test login has been completed.
 */
- (void)authorize 
{
    consumer = [[OAConsumer alloc] initWithKey:kFlickrAPIKey secret:kFlickrAPISecret];
    accessToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:kFlickrDefaultsServiceProviderName prefix:kFlickrDefaultsPrefix];
    if (accessToken)
    {
        OAMutableURLRequest *loginRequest = [self _oaurlRequestForMethod:@"flickr.test.login" arguments:nil];
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:loginRequest 
                             delegate:self 
                    didFinishSelector:@selector(testLoginFinished:withData:)
                      didFailSelector:@selector(testLoginFailed:withData:)];
        return;
        
    }
    
    NSLog(@"No token was found for %@ in the user defaults. Requesting a new token...", self.serviceName);
    
    NSURL *url = [NSURL URLWithString:kFlickrRequestTokenURL];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    
    [request setOAuthParameterName:@"oauth_callback" 
                         withValue:[NSString stringWithFormat:@"flickrgram://%@/verify-auth", self.serviceName]];
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request 
                         delegate:self 
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) 
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}


/*
 * authorizedWithVerifier: is called by EMTLAppDelegate when the user 
 * gives authorization in the WebView for this app to access their account. 
 * Flickr uses a URL callback ("flickrgram://verify-auth") that is 
 * registered to this app and handled application:handleOpenURL:. 
 * The AppDelegate calls this method with the verifier string provided 
 * by flickr. This method to flickr to convert our existing request token
 * to an access token that will allow the app to make API calls as the
 * user. If successful, accessTokenTicket:didFinishWithData will be
 * called to setup the access token.
 */
- (void)authorizedWithVerifier:(NSString *)verfier
{
    requestToken.verifier = verfier;
    
    NSURL *url = [NSURL URLWithString:kFlickrAccessTokenURL];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:requestToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    NSLog(@"about to fetch access token");
    [fetcher fetchDataWithRequest:request 
                         delegate:self 
                didFinishSelector:@selector(accessTokenTicket:didFinishWithData:) 
                  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
    
}




#pragma mark -
#pragma mark Photo List Loading

- (EMTLPhotoList *)currentPhotos
{
    EMTLPhotoList *list = [_photoLists objectForKey:kFlickrTimelinePhotoListID];
    if (list) {
        return list;
    }
    else {
        
                
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:20];
        
        [query setValue:kFlickrTimelinePhotoListID forKey:kFlickrQueryIdentifier];
        [query setValue:kFlickrAPIMethodSearch forKey:kFlickrQueryMethod];
        
        list = [[EMTLPhotoList alloc] initWithPhotoSource:self query:query cachedPhotos:nil];
        [_photoLists setValue:list forKey:kFlickrTimelinePhotoListID];
        return list;
    }
    
                

}

- (EMTLPhotoList *)popularPhotos
{
    return nil;
}

- (EMTLPhotoList *)favoritePhotosForUser:(NSString *)user_id
{
    return nil;
}

- (EMTLPhotoList *)photosForUser:(NSString *)user_id
{
    return nil;
}

- (void)fetchPhotosForPhotoList:(EMTLPhotoList *)photoList
{

    // Make the request for more photos here.
    
    NSMutableDictionary *newQuery = [NSMutableDictionary dictionaryWithDictionary:photoList.query];
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
    
    // Build the request paramets and the OAMutableURLRequest.
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithCapacity:8];
    
    [requestParameters setObject:kFlickrAPIKey forKey:@"api_key"];
    [requestParameters setObject:@"100" forKey:@"per_page"];
    [requestParameters setObject:@"all" forKey:@"contacts"];
    [requestParameters setObject:@"date_upload,owner_name,o_dims,last_update" forKey:@"extras"];
    [requestParameters setObject:@"date-posted-desc" forKey:@"sort"];
    [requestParameters setObject:[NSString stringWithFormat:@"%04d-%02d-%02d", minYear, minMonth, minDay] forKey:@"min_upload_date"];
    
    // If a max year, month and day are set, pass them in as a parameter as well.
    if (maxYear && maxMonth && maxDay) {
        [requestParameters setObject:[NSString stringWithFormat:@"%04d-%02d-%02d", maxYear, maxMonth, maxDay] forKey:@"max_upload_date"];
    }
    
    // If we have a page we care about, pass that as well.
    if (currentPage) {
        [requestParameters setObject:[[NSNumber numberWithInt:currentPage + 1] stringValue] forKey:@"page"];
    }
     
    OAMutableURLRequest *request = [self _oaurlRequestForMethod:[newQuery objectForKey:kFlickrQueryMethod] arguments:requestParameters];

    [photoList photoSourceWillFetchPhotos:self];
    EMTLFlickrFetchPhotoListOperation *operation = [[EMTLFlickrFetchPhotoListOperation alloc] initWithPhotoList:photoList photoSource:self request:request query:newQuery];
    [[EMTLOperationQueue photoQueue] addOperation:operation];
    
}

- (void)operation:(NSOperation *)operation fetchedData:(NSData *)data forPhotoList:(EMTLPhotoList *)photoList withQuery:(NSDictionary *)query
{
    NSDictionary *newPhotos = [self _dictionaryFromResponseData:data];
        
    if (!newPhotos) {
        NSLog(@"There was an error interpreting the json response from the request for more photos from %@", self.serviceName);
        return;
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
        photo.source = self;
        [photos addObject:photo];
    }

    [photoList photoSource:self fetchedPhotos:nil updatedQuery:query];
}

- (void)operation:(NSOperation *)operation isFetchingDataWithProgress:(float)progress forPhotoList:(EMTLPhotoList *)photoList
{
    [photoList photoSource:self isFetchingPhotosWithProgress:progress];
}




#pragma mark -
#pragma mark Photo Asset Loading

- (EMTLPhotoAssets *)assetsForPhoto:(EMTLPhoto *)photo
{
    
}

#pragma mark -
#pragma mark Private methods for Communicating with Flickr 


- (OAMutableURLRequest *)_oaurlRequestForMethod:(NSString *)method arguments:(NSDictionary *)args
{
    // Get the Flickr API URL
    NSURL *url = [NSURL URLWithString:kFlickrAPICallURL];
    
    // Create the request, with the accessToken.
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    // Start processing the paramets
    NSMutableArray *requestParameters;
    OARequestParameter *nameParam;
    
    // If arguments were supplied with the method call, iterate through them and
    // add each one to the request.
    if(args) {
        requestParameters = [[NSMutableArray alloc] initWithCapacity:args.count + 3];
        
        for (NSString *theKey in [args allKeys]) {
            nameParam = [[OARequestParameter alloc] initWithName:theKey value:[args objectForKey:theKey]];
            [requestParameters addObject:nameParam];
        }
    }
    
    // Even if no arguments were supplied, all requests have three standard arguments
    else {
        requestParameters = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    // Set the name of the method, and request a json response format.
    nameParam = [[OARequestParameter alloc] initWithName:@"method" value:method];
    [requestParameters addObject:nameParam];
    
    nameParam = [[OARequestParameter alloc] initWithName:@"nojsoncallback" value:@"1"];
    [requestParameters addObject:nameParam];
    
    nameParam = [[OARequestParameter alloc] initWithName:@"format" value:@"json"];
    [requestParameters addObject:nameParam];
    
    // Add the parameters to the request, make sure it's a GET call
    [request setParameters:requestParameters];
    [request setHTTPMethod:@"GET"];
    return request;
    
}

- (NSDictionary *)_dictionaryFromResponseData:(NSData *)data
{
    NSError *error = nil;
    NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (jsonResults == nil)
    {
        // There was an error during parse
        NSLog(@"EMTLFlickrPhotoSource: Error (%@) while converting response data to JSON", error);
    }
    
    return jsonResults;
    
}

- (BOOL)_isResponseOK:(NSDictionary *)responseDictionary;
{
    BOOL isOK = YES;
    
    NSString *statObject = [responseDictionary objectForKey:@"stat"];
    if (statObject == nil)
    {
        NSLog(@"Response dictionary didn't have a stat object: %@", responseDictionary);
        isOK = NO;
    }
    else if (![statObject isEqualToString:@"ok"])
    {
        NSLog(@"Response dictionary stat object was not \"ok\": %@", responseDictionary);
        isOK = NO;
    }
    
    return isOK;
}


#pragma mark -
#pragma mark Private Flickr OA Callback Selectors

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (ticket.didSucceed)
    {
        requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        NSString *url = [NSString stringWithFormat:@"%@?perms=write&oauth_token=%@", kFlickrAuthorizationURL, requestToken.key];
        [self.authorizationDelegate photoSource:self requiresAuthorizationAtURL:[NSURL URLWithString:url]];
    }
    else
    {
        NSLog(@"Got an error in requestTokenTicket:withData:. The ticket did not succeed for %@", self.serviceName);
        NSError *error = [NSError errorWithDomain:self.serviceName code:0 userInfo:nil];
        [self.authorizationDelegate authorizationFailedForPhotoSource:self authorizationError:error];    
    }
}


- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSError *authError = [NSError errorWithDomain:self.serviceName code:0 userInfo:error.userInfo];
    [self.authorizationDelegate authorizationFailedForPhotoSource:self authorizationError:authError];
}


- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"Got a response for the access ticket for %@", self.serviceName);
    if (ticket.didSucceed)
    {
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        [accessToken storeInUserDefaultsWithServiceProviderName:kFlickrDefaultsServiceProviderName prefix:kFlickrDefaultsPrefix];
        
        OAMutableURLRequest *loginRequest = [self _oaurlRequestForMethod:@"flickr.test.login" arguments:nil];
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:loginRequest 
                             delegate:self 
                    didFinishSelector:@selector(testLoginFinished:withData:)
                      didFailSelector:@selector(testLoginFailed:withData:)];
    }
    else
    {
        NSLog(@"Got an error in accessTicketToken:withData:. The ticket did not succeed for %@", self.serviceName);
        NSError *error = [NSError errorWithDomain:self.serviceName code:0 userInfo:nil];
        [self.authorizationDelegate authorizationFailedForPhotoSource:self authorizationError:error];
    }
}


- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"got an error while trying to get the access token for %@", self.serviceName);
    NSError *authError = [NSError errorWithDomain:self.serviceName code:0 userInfo:[error userInfo]];
    [self.authorizationDelegate authorizationFailedForPhotoSource:self authorizationError:authError];
}


- (void)testLoginFinished:(OAServiceTicket *)ticket withData:(NSData *)data
{
    if (ticket.didSucceed) {
        NSDictionary *loginInfo = [self _dictionaryFromResponseData:data];
        
        if (loginInfo)
        {
            _userID = [[loginInfo objectForKey:@"user"] objectForKey:@"id"];
            _username = [[[loginInfo objectForKey:@"user"] objectForKey:@"username"] objectForKey:@"_content"];
            [self.authorizationDelegate authorizationCompleteForPhotoSource:self];
        }
        else
        {
            NSError *error = [NSError errorWithDomain:self.serviceName code:0 userInfo:nil];
            [self.authorizationDelegate authorizationFailedForPhotoSource:self authorizationError:error];
        }
    }
    else
    {
        NSError *error = [NSError errorWithDomain:self.serviceName code:0 userInfo:nil];
        [self.authorizationDelegate authorizationFailedForPhotoSource:self authorizationError:error];
    }
}


- (void)testLoginFailed:(OAServiceTicket *)ticket withData:(NSError *)error
{
    NSLog(@"test login failed for %@", self.serviceName);
    NSError *authError = [NSError errorWithDomain:self.serviceName code:0 userInfo:[error userInfo]];
    [self.authorizationDelegate authorizationFailedForPhotoSource:self authorizationError:authError];
}



                                   

@end

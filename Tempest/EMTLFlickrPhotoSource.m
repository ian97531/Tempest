//
//  EMTLFlickr.m
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrPhotoSource.h"
#import "EMTLPhotoSource_Private.h"
#import "APISecrets.h"
#import "EMTLPhoto.h"
#import "EMTLFlickrPhotoQuery.h"

static NSString *const kFlickrRequestTokenURL = @"http://www.flickr.com/services/oauth/request_token";
static NSString *const kFlickrAuthorizationURL = @"http://www.flickr.com/services/oauth/authorize";
static NSString *const kFlickrAccessTokenURL = @"http://www.flickr.com/services/oauth/access_token";
static NSString *const kFlickrAPICallURL = @"http://api.flickr.com/services/rest";
static NSString *const kFlickrDefaultsServiceProviderName = @"flickr-access-token";
static NSString *const kFlickrDefaultsPrefix = @"com.Elemental.Flickrgram";
static NSString *const kFlickrDefaultIconURLString = @"http://www.flickr.com/images/buddyicon.gif";
static double const kSecondsInThreeMonths = 7776500;

@interface EMTLFlickrPhotoSource ()
- (OAMutableURLRequest *)_oaurlRequestForMethod:(NSString *)method arguments:(NSDictionary *)args;
- (NSDictionary *)_dictionaryFromResponseData:(NSData *)data;
- (BOOL)_isResponseOK:(NSDictionary *)responseDictionary;
- (NSArray *)_commentDictionariesFromResponseData:(NSData *)data;
- (NSArray *)_favoritesDictionariesFromResponseData:(NSData *)data;
- (NSURL *)_defaultUserIconURL;
- (NSString *)_flickrMethodForQuery:(EMTLPhotoQuery *)query;
- (NSMutableDictionary *)_flickrArgumentsForQuery:(EMTLFlickrPhotoQuery *)flickrQuery;
- (EMTLFlickrPhotoQuery *)_queryForURLRequest:(NSURLRequest *)urlRequest;
@end

@implementation EMTLFlickrPhotoSource


- (id)init
{
    self = [super init];
    if (self)
    {

    }
    
    return self;
}




#pragma mark - PhotoSource methods

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

- (NSString *)serviceName;
{
    return @"flickr";
}


#pragma mark -
#pragma mark EMTLPhotoSource Private

- (Class)_queryClass
{
    return [EMTLFlickrPhotoQuery class];
}

- (void)_setupQuery:(EMTLPhotoQuery *)query
{
    // Sanity Check
    NSAssert([query isKindOfClass:[EMTLFlickrPhotoQuery class]], @"Flickr photo source can only deal with flickr photo queries");
    EMTLFlickrPhotoQuery *flickrQuery = (EMTLFlickrPhotoQuery *)query;
    
    flickrQuery.totalPages = 1;
    flickrQuery.currentPage = 0;
    flickrQuery.maxYear = 0;
    flickrQuery.maxMonth = 0;
    flickrQuery.maxDay = 0;
    
    NSDate *minDate = [NSDate dateWithTimeIntervalSinceNow:-kSecondsInThreeMonths];;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *minComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:minDate];
    flickrQuery.minYear = [minComponents year];
    flickrQuery.minMonth = [minComponents month];
    flickrQuery.minDay = [minComponents day] + 2;
}

- (void)_runQuery:(EMTLPhotoQuery *)query
{
    // Right now, running the query initially and updating the query later are the same thing
    [self _updateQuery:query];
}

- (void)_updateQuery:(EMTLPhotoQuery *)query
{
    // Sanity Check
    NSAssert([query isKindOfClass:[EMTLFlickrPhotoQuery class]], @"Flickr photo source can only deal with flickr photo queries");
    EMTLFlickrPhotoQuery *flickrQuery = (EMTLFlickrPhotoQuery *)query;

    if (flickrQuery.currentURLRequest == nil) // Don't update if it's already updating
    {
        NSDictionary *flickrArguments = [self _flickrArgumentsForQuery:flickrQuery];
        NSString *flickrMethod = [self _flickrMethodForQuery:flickrQuery];
        OAMutableURLRequest *requestForPhotos = [self _oaurlRequestForMethod:flickrMethod arguments:flickrArguments];
        NSString *successSelectorString = [self _successCallbackForQuery:flickrQuery];
        NSString *failureSelectorString = [self _failureCallbackForQuery:flickrQuery];
        
        // Update the query so we know it's updating.
        flickrQuery.currentURLRequest = requestForPhotos;
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:requestForPhotos delegate:self didFinishSelector:NSSelectorFromString(successSelectorString) didFailSelector:NSSelectorFromString(failureSelectorString)];
    }
}

- (void)_reloadQuery:(EMTLPhotoQuery *)query
{
    // Sanity Check
    NSAssert([query isKindOfClass:[EMTLFlickrPhotoQuery class]], @"Flickr photo source can only deal with flickr photo queries");
    EMTLFlickrPhotoQuery *flickrQuery = (EMTLFlickrPhotoQuery *)query;
    
    if (flickrQuery.currentURLRequest != nil) // Don't reload if we're already in the middle of an update
    {
        // call setup to reset everything
        [self _setupQuery:flickrQuery];
        
        // Then run it
        [self _runQuery:flickrQuery];
    }
}

- (void)_stopQuery:(EMTLPhotoQuery *)query
{
    // Sanity Check
    NSAssert([query isKindOfClass:[EMTLFlickrPhotoQuery class]], @"Flickr photo source can only deal with flickr photo queries");
    EMTLFlickrPhotoQuery *flickrQuery = (EMTLFlickrPhotoQuery *)query;
    
    // TODO BSEELY: We're not really keeping track of which fetchers are active, etc so we have nothing to do here.
    // But we probably need to start doing that so we can kill things that are in progress when we need to.
    // Probably put the fetcher on the query object?
    (void)flickrQuery;
}

- (void)_removeQuery:(EMTLPhotoQuery *)query
{
    // Sanity Check
    NSAssert([query isKindOfClass:[EMTLFlickrPhotoQuery class]], @"Flickr photo source can only deal with flickr photo queries");
    EMTLFlickrPhotoQuery *flickrQuery = (EMTLFlickrPhotoQuery *)query;
    
    // we don't really have anything to do here yet that we shouldn't just be doing in _stopQuery?
    (void)flickrQuery;
}

#pragma mark -
#pragma mark OA Callback Selectors

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
            self.userID = [[loginInfo objectForKey:@"user"] objectForKey:@"id"];
            self.username = [[[loginInfo objectForKey:@"user"] objectForKey:@"username"] objectForKey:@"_content"];
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


- (void)timelineQuerySucceededWithTicket:(OAServiceTicket *)ticket data:(NSData *)data
{
    // Sanity Check
    EMTLFlickrPhotoQuery *query = [self _queryForURLRequest:ticket.request];
    NSAssert(query != nil, @"We receivd a reply back but we don't have record of a query which was fetching that URL. Either we incorrectly cleared the URL from the query object or we didn't properly set it.");
    NSAssert(query.queryType == EMTLPhotoQueryTimeline, @"We got a callback that we use for timeline updates, but the query type wasn't set to timeline...");
    
    // Clear the request from our query
    query.currentURLRequest = nil;
    
    
    if (ticket.didSucceed)
    {
        NSDictionary *newPhotos = [self _dictionaryFromResponseData:data];
        
        if (!newPhotos) {
            NSLog(@"There was an error interpreting the json response from the request for more photos from %@", self.serviceName);
            return;
        }
        
        // Grab the paging information...
        query.currentPage = [[[newPhotos objectForKey:@"photos"] objectForKey:@"page"] integerValue];
        query.totalPages = [[[newPhotos objectForKey:@"photos"] objectForKey:@"pages"] integerValue];
        
        // If we've run out of pages, we need to set a new date range to search and reset the page numbering.
        if (query.currentPage >= query.totalPages) {
            NSLog(@"Next search will change the date range.");
            query.maxYear = query.minYear;
            query.maxMonth = query.minMonth;
            query.maxDay = query.minDay;
            
            if ((query.minMonth - 3) < 1)
            {
                query.minMonth = 12 + (query.minMonth - 3);
                query.minYear = query.minYear - 1;
            }
            else
            {
                query.minMonth = query.minMonth - 3;
            }
            
            query.currentPage = 0;
            query.totalPages = 0;
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
    }
    
    [self _didChangeQuery:query];
}


- (void)timelineQueryFailedWithTicket:(OAServiceTicket *)ticket error:(NSError *)data
{
    // Sanity Check
    EMTLFlickrPhotoQuery *query = [self _queryForURLRequest:ticket.request];
    NSAssert(query != nil, @"We receivd a reply back but we don't have record of a query which was fetching that URL. Either we incorrectly cleared the URL from the query object or we didn't properly set it.");
    NSAssert(query.queryType == EMTLPhotoQueryTimeline, @"We got a callback that we use for timeline updates, but the query type wasn't set to timeline...");

    // Even though nothing has changed, make the callback so our delegate gets notified that something happened
    [self _didChangeQuery:query];
    
    
    NSLog(@"Error updating the timeline with this ticket: %@", ticket);
    
}

#pragma mark -
#pragma mark Private

- (OAMutableURLRequest *)_favoritesURLRequestForPhotoID:(NSString *)photo_id
{
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:4];
    [args setObject:kFlickrAPIKey forKey:@"api_key"];
    [args setObject:photo_id forKey:@"photo_id"];
    [args setObject:@"50" forKey:@"per_page"];
    [args setObject:@"1" forKey:@"page"];
    
    return [self _oaurlRequestForMethod:@"flickr.photos.getFavorites" arguments:args];
}


- (OAMutableURLRequest *)_commentsURLRequestForPhotoID:(NSString *)photo_id
{
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:4];
    [args setObject:kFlickrAPIKey forKey:@"api_key"];
    [args setObject:photo_id forKey:@"photo_id"];
    
    return [self _oaurlRequestForMethod:@"flickr.photos.comments.getList" arguments:args];
}


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

- (NSArray *)_favoritesDictionariesFromResponseData:(NSData *)data;
{
    NSMutableArray *favorites = nil;
    
    NSDictionary *favoritesDict = [self _dictionaryFromResponseData:data];
    if (![self _isResponseOK:favoritesDict])
    {
        NSLog(@"EMTLFlickrPhotoSource: We got no response or an error response when asking for favorites. Probably were messages above this indicating the problem");
    }
    else
    {
        favorites = [NSMutableArray arrayWithCapacity:20];
        
        // Iterate through all of the favorites. We need to put the data into a format
        // that the generic EMTLPhoto class will understand.
        for (NSDictionary *favoriteDict in [[favoritesDict objectForKey:@"photo"] objectForKey:@"person"]) {
            
            // Get the date of the favoriting
            NSDate *favorite_date = [NSDate dateWithTimeIntervalSince1970:[[favoriteDict objectForKey:@"favedate"] doubleValue]];
            [favoriteDict setValue:favorite_date forKey:kFavoriteDate];
            
            // Construct the icon URL
            int iconfarm = [[favoriteDict objectForKey:@"iconfarm"] intValue];
            int iconserver = [[favoriteDict objectForKey:@"iconserver"] intValue];
            NSString *nsid = [favoriteDict objectForKey:@"nsid"];
            
            // If the iconfarm and iconserver were supplied, then we can construct the icon URL,
            // otherwise, we'll use flickr's generic icon url.
            NSURL *userIconURL;
            if (iconfarm && iconserver) {
                userIconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%i.staticflickr.com/%i/buddyicons/%@.jpg", iconfarm, iconserver, nsid]];
            }
            else {
                userIconURL = [self _defaultUserIconURL];
            }
            
            [favoriteDict setValue:userIconURL forKey:kFavoriteIconURL];
            [favoriteDict setValue:nsid forKey:kFavoriteUserID];
            [favoriteDict setValue:[favoriteDict objectForKey:@"username"] forKey:kFavoriteUsername];
            
            // Add the modified dict to the array of favorites.
            [favorites addObject:favoriteDict];
            
        }
    }
    
    return favorites;    
}


- (NSArray *)_commentDictionariesFromResponseData:(NSData *)data
{
    NSMutableArray *comments = nil;
    
    NSDictionary *commentsDict = [self _dictionaryFromResponseData:data];
    if (![self _isResponseOK:commentsDict])
    {
        NSLog(@"EMTLFlickrPhotoSource: We got no response or an error response when asking for comments. Probably were messages above this indicating the problem");
    }
    else
    {
        comments = [NSMutableArray arrayWithCapacity:20];
        
        for (NSDictionary *commentDict in [[commentsDict objectForKey:@"comments"] objectForKey:@"comment"]) {
            
            // Get the date of the comment
            NSDate *comment_date = [NSDate dateWithTimeIntervalSince1970:[[commentDict objectForKey:@"datecreate"] doubleValue]];
            [commentDict setValue:comment_date forKey:kCommentDate];
            
            // Get the icon URL for the user who left the comment
            int iconfarm = [[commentDict objectForKey:@"iconfarm"] intValue];
            int iconserver = [[commentDict objectForKey:@"iconserver"] intValue];
            NSString *nsid = [commentDict objectForKey:@"author"];
            
            NSURL *userIconURL;
            if (iconfarm && iconserver) {
                userIconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%i.staticflickr.com/%i/buddyicons/%@.jpg", iconfarm, iconserver, nsid]];
            }
            else {
                userIconURL = [self _defaultUserIconURL];
            }
            [commentDict setValue:userIconURL forKey:kCommentIconURL];
            [commentDict setValue:[commentDict objectForKey:@"_content"] forKey:kCommentText];
            [commentDict setValue:nsid forKey:kCommentUserID];
            [commentDict setValue:[commentDict objectForKey:@"authorname"] forKey:kCommentUsername];
            
            
            [comments addObject:commentDict];
        }
    }
    
    return comments;
}

- (NSURL *)_defaultUserIconURL
{
    return [NSURL URLWithString:kFlickrDefaultIconURLString];
}

- (NSString *)_flickrMethodForQuery:(EMTLPhotoQuery *)query
{
    // TODO (BSEELY): I can easily argue for why we should just put this implementation into the EMTLFlickrPhotoQuery object - we're basically just using
    // all the data it has to build a dictionary. But for now I just figured we'd keep all logic here in the photo source. If this ends up with some weird design
    // or gets really unwieldly, then maybe we look at moving it.
    
    NSString *flickrMethodName = nil;
    
    switch (query.queryType)
    {
        case EMTLPhotoQueryTimeline:
            flickrMethodName = @"flickr.photos.search";
            break;
            
        default:
            NSAssert(NO, @"We don't handle anything besides EMTLPhotoQueryTimeLine for Flickr yet... if we're supposed to, update _flickrMethodForQuery:");
            break;
    }
    
    return flickrMethodName;
}

- (NSMutableDictionary *)_flickrArgumentsForQuery:(EMTLFlickrPhotoQuery *)flickrQuery
{
    // TODO (BSEELY): I can easily argue for why we should just put this implementation into the EMTLFlickrPhotoQuery object - we're basically just using
    // all the data it has to build a dictionary. But for now I just figured we'd keep all logic here in the photo source. If this ends up with some weird design
    // or gets really unwieldly, then maybe we look at moving it.
    
    NSMutableDictionary *flickrArguments = [NSMutableDictionary dictionary];
    
    switch (flickrQuery.queryType)
    {
        case EMTLPhotoQueryTimeline:
        {
            [flickrArguments setObject:kFlickrAPIKey forKey:@"api_key"];
            [flickrArguments setObject:@"100" forKey:@"per_page"];
            [flickrArguments setObject:@"all" forKey:@"contacts"];
            [flickrArguments setObject:@"date_upload,owner_name,o_dims,last_update" forKey:@"extras"];
            [flickrArguments setObject:@"date-posted-desc" forKey:@"sort"];
            [flickrArguments setObject:[NSString stringWithFormat:@"%04d-%02d-%02d", flickrQuery.minYear, flickrQuery.minMonth, flickrQuery.minDay] forKey:@"min_upload_date"];
            
            if (flickrQuery.maxYear && flickrQuery.maxMonth && flickrQuery.maxDay) {
                [flickrArguments setObject:[NSString stringWithFormat:@"%04d-%02d-%02d", flickrQuery.maxYear, flickrQuery.maxMonth, flickrQuery.maxDay] forKey:@"max_upload_date"];
            }
            
            if (flickrQuery.currentPage) {
                [flickrArguments setObject:[[NSNumber numberWithInt:flickrQuery.currentPage + 1] stringValue] forKey:@"page"];
            }

            break;
        }
            
        default:
            NSAssert(NO, @"We don't handle anything besides EMTLPhotoQueryTimeLine for Flickr yet... if we're supposed to, update _flickrMethodForQuery:");
            break;
    }
    
    return flickrArguments;
}

- (NSString *)_successCallbackForQuery:(EMTLPhotoQuery *)query
{
    NSString *callback = nil;
    
    switch (query.queryType)
    {
        case EMTLPhotoQueryTimeline:
            callback = @"timelineQuerySucceededWithTicket:data:";
            break;
            
        default:
            NSAssert(NO, @"No idea what the callback is since we have only implemented timeline so far");
            break;
    }
    
    return callback;
}

- (NSString *)_failureCallbackForQuery:(EMTLPhotoQuery *)query
{
    NSString *callback = nil;
    
    switch (query.queryType)
    {
        case EMTLPhotoQueryTimeline:
            callback = @"timelineQueryFailedWithTicket:error:";
            break;
            
        default:
            NSAssert(NO, @"No idea what the callback is since we have only implemented timeline so far");
            break;
    }
    
    return callback;
}

- (EMTLFlickrPhotoQuery *)_queryForURLRequest:(NSURLRequest *)urlRequest
{
    __block EMTLFlickrPhotoQuery *query = nil;
    
    NSSet *queries = [self queries];
    [queries enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([obj isKindOfClass:[EMTLFlickrPhotoQuery class]])
        {
            NSURLRequest *request = [(EMTLFlickrPhotoQuery *)obj currentURLRequest];
            if ([request isEqual:urlRequest])
            {
                query = (EMTLFlickrPhotoQuery *)obj;
                *stop = YES;
            }
        }
    }];
    
    return query;
}

@end

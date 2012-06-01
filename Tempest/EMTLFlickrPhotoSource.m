//
//  EMTLFlickrPhotoSource.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrPhotoSource.h"
#import "EMTLPhotoQuery.h"
#import "EMTLFlickrFetchPhotoQueryOperation.h"
#import "EMTLFlickrFetchImageOperation.h"
#import "EMTLOperationQueue.h"
#import "EMTLPhoto.h"
#import "OAMutableURLRequest.h"




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
NSString *const kFlickrAPIMethodPopularPhotos = @"flickr.interestingness.getList";
NSString *const kFlickrAPIMethodFavoritePhotos = @"flickr.favorites.getList";
NSString *const kFlickrAPIMethodUserPhotos = @"flickr.people.getPhotos";
NSString *const kFlickrAPIMethodPhotoFavorites = @"flickr.photos.getFavorites";
NSString *const kFlickrAPIMethodPhotoComments = @"flickr.photos.comments.getList";

NSString *const kFlickrAPIArgumentUserID = @"user_id";
NSString *const kFlickrAPIArgumentPhotoID = @"photo_id";
NSString *const kFlickrAPIArgumentItemsPerPage = @"per_page";
NSString *const kFlickrAPIArgumentPageNumber = @"page";
NSString *const kFlickrAPIArgumentAPIKey = @"api_key";
NSString *const kFlickrAPIArgumentContacts = @"contacts";
NSString *const kFlickrAPIArgumentSort = @"sort";
NSString *const kFlickrAPIArgumentExtras = @"extras";


NSString *const kFlickrRequestTokenURL = @"http://www.flickr.com/services/oauth/request_token";
NSString *const kFlickrAuthorizationURL = @"http://www.flickr.com/services/oauth/authorize";
NSString *const kFlickrAccessTokenURL = @"http://www.flickr.com/services/oauth/access_token";
NSString *const kFlickrAPICallURL = @"http://api.flickr.com/services/rest";
NSString *const kFlickrDefaultsServiceProviderName = @"flickr-access-token";
NSString *const kFlickrDefaultsPrefix = @"com.Elemental.Flickrgram";
NSString *const kFlickrDefaultIconURLString = @"http://www.flickr.com/images/buddyicon.gif";




@implementation EMTLFlickrPhotoSource


- (id)init
{
    self = [super init];
    if (self) 
    {
        _imageOperations = [NSMutableDictionary dictionary];
        _photoListOperations = [NSMutableDictionary dictionary];
        
    }
    
    return self;
}

- (NSString *)serviceName
{
    return @"flickr";
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
        OAMutableURLRequest *loginRequest = [self oaurlRequestForMethod:@"flickr.test.login" arguments:nil];
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


- (NSDictionary *)_setupQueryArguments:(NSDictionary *)queryArguments forQuery:(EMTLPhotoQuery *)query
{
    NSLog(@"in _setup query");
    NSMutableDictionary *newQuery = [NSMutableDictionary dictionaryWithDictionary:queryArguments];

    switch (query.queryType) {
        case EMTLPhotoQueryTimeline:
            NSLog(@"asking for the timeline");
            [newQuery setValue:kFlickrAPIMethodSearch forKey:kFlickrQueryMethod];
            break;
            
        case EMTLPhotoQueryPopularPhotos:
            [newQuery setValue:kFlickrAPIMethodPopularPhotos forKey:kFlickrQueryMethod];
            break;
            
        case EMTLPhotoQueryFavorites:
            [newQuery setValue:kFlickrAPIMethodFavoritePhotos forKey:kFlickrQueryMethod];
            [newQuery setValue:[query valueForKey:kPhotoUserID] forKey:kFlickrAPIArgumentUserID];
            [newQuery removeObjectForKey:kPhotoUserID];
            break;
            
        case EMTLPhotoQueryUserPhotos:
            [newQuery setValue:kFlickrAPIMethodUserPhotos forKey:kFlickrQueryMethod];
            [newQuery setValue:[query valueForKey:kPhotoUserID] forKey:kFlickrAPIArgumentUserID];
            [newQuery removeObjectForKey:kPhotoUserID];
            break;
            
        default:
            break;
    }
    
    return newQuery;

}



- (void) updateQuery:(EMTLPhotoQuery *)query    
{
    if (![_photoListOperations objectForKey:query.photoQueryID])
    {
        NSLog(@"starting a new photo list operation");
        EMTLFlickrFetchPhotoQueryOperation *operation = [[EMTLFlickrFetchPhotoQueryOperation alloc] initWithPhotoQuery:query photoSource:self];
        [_photoListOperations setObject:operation forKey:query.photoQueryID];
        [[EMTLOperationQueue photoQueue] addOperation:operation];
    }
}

- (void)cancelQuery:(EMTLPhotoQuery *)query
{
    EMTLFlickrFetchPhotoQueryOperation *operation = [_photoListOperations objectForKey:query.photoQueryID];
    if (operation)
    {
        [operation cancel];
        [_photoListOperations removeObjectForKey:query.photoQueryID];
    }
}



- (void)operation:(EMTLFlickrFetchPhotoQueryOperation *)operation fetchedPhotos:(NSArray *)photos totalPhotos:(int)total forQuery:(EMTLPhotoQuery *)query
{
    // Cache the results here.
    [query photoSource:self fetchedPhotos:photos totalPhotos:total];
}

-(void)operation:(EMTLFlickrFetchPhotoQueryOperation *)operation finishedFetchingPhotos:(NSArray *)photos forQuery:(EMTLPhotoQuery *)query updatedArguments:(NSDictionary *)arguments
{
    if ([_photoListOperations objectForKey:query.photoQueryID])
    {
        [_photoListOperations removeObjectForKey:query.photoQueryID];
    }
    
    [self cachePhotoList:photos forQueryID:query.photoQueryID];
    [query photoSource:self finishedFetchingPhotosWithUpdatedArguments:arguments];
    
    
    
}


- (void)operation:(EMTLFlickrFetchPhotoQueryOperation *)operation willFetchPhotosForQuery:(EMTLPhotoQuery *)query
{
    [query photoSourceWillFetchPhotos:self];
}


- (void)operation:(EMTLFlickrFetchPhotoQueryOperation *)operation isFetchingPhotosForQuery:(EMTLPhotoQuery *)query WithProgress:(float)progress
{
    [query photoSource:self isFetchingPhotosWithProgress:progress];
}




- (UIImage *)imageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size;
{
    
    UIImage *cachedPhoto = [self imageFromCacheWithSize:size forPhoto:photo];
    
    if (cachedPhoto) 
    {
        return cachedPhoto;
    }
    else 
    {
        NSString *cacheKey = [self _cacheKeyForPhoto:photo imageSize:size];
        if(![_imageOperations objectForKey:cacheKey]) {
            EMTLFlickrFetchImageOperation *imageOp = [[EMTLFlickrFetchImageOperation alloc] initWithPhoto:photo size:size photoSource:self];
            [_imageOperations setObject:imageOp forKey:cacheKey];
            [[EMTLOperationQueue photoQueue] addOperation:imageOp];
        }
        return nil;
    }
}

- (void)cancelImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size
{
    NSString *cacheKey = [self _cacheKeyForPhoto:photo imageSize:size];
    EMTLFlickrFetchImageOperation *operation = [_imageOperations objectForKey:cacheKey];
    if (operation) {
        [operation cancel];
        [_imageOperations removeObjectForKey:cacheKey];
    }
    
}


- (void)operation:(EMTLFlickrFetchImageOperation *)operation willRequestImageForPhoto:(EMTLPhoto *)photo withSize:(EMTLImageSize)size
{
    [photo photoSource:self willRequestImageWithSize:size];
}

- (void)operation:(EMTLFlickrFetchImageOperation *)operation didRequestImageForPhoto:(EMTLPhoto *)photo withSize:(EMTLImageSize)size progress:(float)progress
{
    [photo photoSource:self didRequestImageWithSize:size progress:progress];
}

- (void)operation:(EMTLFlickrFetchImageOperation *)operation didLoadImage:(UIImage *)image forPhoto:(EMTLPhoto *)photo withSize:(EMTLImageSize)size
{
    NSString *cacheKey = [self _cacheKeyForPhoto:photo imageSize:size];
    [self cacheImage:image withSize:size forPhoto:photo];
    [photo photoSource:self didLoadImage:image withSize:size];
    [_imageOperations removeObjectForKey:cacheKey];
}






    


#pragma mark -
#pragma mark Methods for Communicating with Flickr 


- (OAMutableURLRequest *)oaurlRequestForMethod:(NSString *)method arguments:(NSDictionary *)args
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
    
    [request prepare];
    return request;
    
}

- (NSDictionary *)dictionaryFromResponseData:(NSData *)data
{
    NSError *error = nil;
    
    if (!data)
    {
        return [NSDictionary dictionary];
    }
    
    NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (jsonResults == nil)
    {
        // There was an error during parse
        NSLog(@"EMTLFlickrPhotoSource: Error (%@) while converting response data to JSON", error);
    }
    
    return jsonResults;
    
}

- (BOOL)isResponseOK:(NSDictionary *)responseDictionary;
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
        
        OAMutableURLRequest *loginRequest = [self oaurlRequestForMethod:@"flickr.test.login" arguments:nil];
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
        NSDictionary *loginInfo = [self dictionaryFromResponseData:data];
        
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

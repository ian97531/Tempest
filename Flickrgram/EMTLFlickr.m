//
//  EMTLFlickr.m
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickr.h"
#import "APISecrets.h"
#import "EMTLPhoto.h"

static NSString *const kFlickrRequestTokenURL = @"http://www.flickr.com/services/oauth/request_token";
static NSString *const kFlickrAuthorizationURL = @"http://www.flickr.com/services/oauth/authorize";
static NSString *const kFlickrAccessTokenURL = @"http://www.flickr.com/services/oauth/access_token";
static NSString *const kFlickrAPICallURL = @"http://api.flickr.com/services/rest";
static NSString *const kFlickrDefaultsServiceProviderName = @"flickr-access-token";
static NSString *const kFlickrDefaultsPrefix = @"com.Elemental.Flickrgram";
static NSString *const kFlickrFavoritesDomain = @"flickr.favorites";
static NSString *const kFlickrCommentsDomain = @"flickr.comments";
static NSString *const kFlickrImageDomain = @"flickr.image";

static double const kSecondsInThreeMonths = 7776500;

@implementation EMTLFlickr

@synthesize delegate;
@synthesize photoDelegate;
@synthesize key;

@synthesize user_id;
@synthesize username;

- (id)init
{
    self = [super init];
    if (self) {
        key = @"flickr";
        
        totalPages = 1;
        currentPage = 0;
                
        maxYear = 0;
        maxMonth = 0;
        maxDay = 0;
        
        NSDate *minDate = [NSDate dateWithTimeIntervalSinceNow:-kSecondsInThreeMonths];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *minComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:minDate];
        
        minYear = [minComponents year];
        minMonth = [minComponents month];
        minDay = [minComponents day] + 2;
                
        loading = NO;
                
        [[EMTLCache cache] setHandler:self forDomain:kFlickrCommentsDomain];
        [[EMTLCache cache] setPostProcessor:self forDomain:kFlickrCommentsDomain];
        [[EMTLCache cache] setHandler:self forDomain:kFlickrFavoritesDomain];
        [[EMTLCache cache] setPostProcessor:self forDomain:kFlickrFavoritesDomain];
        
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
    if(accessToken) {
        
        OAMutableURLRequest *loginRequest = [self createOAURLRequestForMethod:@"flickr.test.login" withArguments:nil];
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:loginRequest 
                             delegate:self 
                    didFinishSelector:@selector(testLoginFinished:withData:)
                      didFailSelector:@selector(testLoginFailed:withData:)];
        return;
        
    }
    
    NSLog(@"No token was found for %@ in the user defaults. Requesting a new token...", key);
    
    NSURL *url = [NSURL URLWithString:kFlickrRequestTokenURL];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    
    [request setOAuthParameterName:@"oauth_callback" 
                         withValue:[NSString stringWithFormat:@"flickrgram://%@/verify-auth", key]];
    
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


/*
 * morePhotos: sends a request for 3 months worth of photos. Each request
 * is tracked, if the response has multiple pages, each subsequent request
 * will fetch the next page in order. If the last page is reached, or a
 * request only returned a single page, the subsequent request will ask
 * for the photos from the three month period prior. When photos are received
 * they are convered into EMTLPhoto objects and handed to the photoDelegate
 * object using the photoSource:retreivedMorePhotos: method.
 */
- (void)morePhotos
{
    if(!loading) {
        loading = YES;
        
        #ifdef DEBUG
        NSLog(@"Requesting more photos from %@.", key);
        #endif
        
        NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:4];
        [args setObject:kFlickrAPIKey 
                 forKey:@"api_key"];
        
        [args setObject:@"100"
                 forKey:@"per_page"];
        
        [args setObject:@"all" 
                 forKey:@"contacts"];
        
        [args setObject:@"date_upload,owner_name,o_dims,last_update" 
                 forKey:@"extras"];
        
        [args setObject:@"date-posted-desc"
                 forKey:@"sort"];
        
        [args setObject:[NSString stringWithFormat:@"%04d-%02d-%02d", minYear, minMonth, minDay]
                 forKey:@"min_upload_date"];
        
        if(maxYear && maxMonth && maxDay) {
            [args setObject:[NSString stringWithFormat:@"%04d-%02d-%02d", maxYear, maxMonth, maxDay] 
                     forKey:@"max_upload_date"];
        }
        
        if(currentPage) {
            [args setObject:[[NSNumber numberWithInt:currentPage + 1] stringValue] forKey:@"page"];
        }
        
        OAMutableURLRequest *requestForPhotos = [self createOAURLRequestForMethod:@"flickr.photos.search" withArguments:args];
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:requestForPhotos 
                             delegate:self 
                    didFinishSelector:@selector(moarPhotos:didFinishWithData:) 
                      didFailSelector:@selector(moarPhotos:didFailWithError:)];
    }
    
}




#pragma mark - EMTLCacheHander methods

/*
 * urlRequestForRequest: is called by EMTLCacheRequest when it needs
 * to download a resource from the internet. This function must return
 * an NSURLRequest* that can be used to fetch that resource.
 */
- (NSURLRequest *)urlRequestForRequest:(EMTLCacheRequest *)request
{
    if([request.domain isEqualToString:kFlickrFavoritesDomain]) {
        return [self getNSURLRequestForFavorites:request.key];
    }
    else if ([request.domain isEqualToString:kFlickrCommentsDomain]){
        return [self getNSURLRequestForComments:request.key];
    }
    return nil;
}




#pragma mark - EMTLCachePostProcessor methods

/*
 * processObject:forRequest: is called once EMTLCacheRequest has 
 * downloaded the data for an object from the internet. This method
 * is responsible for converting that data into a usable object;
 */
- (id)processData:(NSData *)data forRequest:(EMTLCacheRequest *)request
{
    if([request.domain isEqualToString:kFlickrFavoritesDomain]) {
        return [self processFavorites:data];
    }
    else if ([request.domain isEqualToString:kFlickrCommentsDomain]){
        return [self processComments:data];
    }
    return nil;
}




#pragma mark - Support methods for EMTLCacheHander
- (OAMutableURLRequest *)getNSURLRequestForFavorites:(NSString *)photo_id
{
        
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:4];
    [args setObject:kFlickrAPIKey 
             forKey:@"api_key"];
    
    [args setObject:photo_id
             forKey:@"photo_id"];
    
    [args setObject:@"50"
             forKey:@"per_page"];
    
    [args setObject:@"1"
             forKey:@"page"];
    
    return [self createOAURLRequestForMethod:@"flickr.photos.getFavorites" withArguments:args];

}


- (OAMutableURLRequest *)getNSURLRequestForComments:(NSString *)photo_id
{
    
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:4];
    [args setObject:kFlickrAPIKey 
             forKey:@"api_key"];
    
    [args setObject:photo_id
             forKey:@"photo_id"];
    
    return [self createOAURLRequestForMethod:@"flickr.photos.comments.getList" withArguments:args];

}


- (OAMutableURLRequest *)createOAURLRequestForMethod:(NSString *)method withArguments:(NSDictionary *)args
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





#pragma mark - Support methods for EMTLCachePostProcessor
- (NSArray *)processFavorites:(NSData *)data;
{
    NSDictionary *favoritesDict = [self dictionaryFromResponseData:data];
    
    if(!favoritesDict) {
        NSLog(@"There was an error interpreting the json response for favorites from %@", key);
        return nil;
    }
    else {
        NSMutableArray *favorites = [NSMutableArray arrayWithCapacity:20];
        
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
                userIconURL = [self defaultUserIconURL];
            }
            
            [favoriteDict setValue:userIconURL forKey:kFavoriteIconURL];
            [favoriteDict setValue:nsid forKey:kFavoriteUserID];
            [favoriteDict setValue:[favoriteDict objectForKey:@"username"] forKey:kFavoriteUsername];
            
            // Add the modified dict to the array of favorites.
            [favorites addObject:favoriteDict];
            
        }
        return favorites;
    }
    
}


- (NSArray *)processComments:(NSData *)data
{
    
    NSDictionary *commentsDict = [self dictionaryFromResponseData:data];
    
    if(!commentsDict) {
        NSLog(@"There was an error interpreting the json response for comments from %@", key);
        return nil;
    }
    
    else {
        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:20];
        
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
                userIconURL = [self defaultUserIconURL];
            }
            [commentDict setValue:userIconURL forKey:kCommentIconURL];
            [commentDict setValue:[commentDict objectForKey:@"_content"] forKey:kCommentText];
            [commentDict setValue:nsid forKey:kCommentUserID];
            [commentDict setValue:[commentDict objectForKey:@"authorname"] forKey:kCommentUsername];
            
            
            [comments addObject:commentDict];
        }
        return comments;
    }
    
}


- (NSURL *)defaultUserIconURL
{
    return [NSURL URLWithString:@"http://www.flickr.com/images/buddyicon.gif"];
}





#pragma mark - Support methods for PhotoSource




- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    
    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (ticket.didSucceed) {
        
        requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        NSString *url = [NSString stringWithFormat:@"%@?perms=write&oauth_token=%@", kFlickrAuthorizationURL, requestToken.key];
        
        [delegate photoSource:self requiresAuthorizationAtURL:[NSURL URLWithString:url]];
        return;
    }
    
    NSLog(@"Got an error in requestTokenTicket:withData:. The ticket did not succeed for %@", key);
    [delegate authorizationErrorForPhotoSource:self];
    
}


- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    [delegate authorizationErrorForPhotoSource:self];
}


- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"Got a response for the access ticket for %@", key);
    if (ticket.didSucceed) {
        
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        
        accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        [accessToken storeInUserDefaultsWithServiceProviderName:kFlickrDefaultsServiceProviderName prefix:kFlickrDefaultsPrefix];
        
        OAMutableURLRequest *loginRequest = [self createOAURLRequestForMethod:@"flickr.test.login" withArguments:nil];
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:loginRequest 
                             delegate:self 
                    didFinishSelector:@selector(testLoginFinished:withData:)
                      didFailSelector:@selector(testLoginFailed:withData:)];
        
        
        return;
    }
    
    NSLog(@"Got an error in accessTicketToken:withData:. The ticket did not succeed for %@", key);
    [delegate authorizationErrorForPhotoSource:self];
    
}


- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"got an error while trying to get the access token for %@", key);
    [delegate authorizationErrorForPhotoSource:self];
}


- (void)testLoginFinished:(OAServiceTicket *)ticket withData:(NSData *)data
{
    
    // If the 
    if (ticket.didSucceed) {
        NSDictionary *loginInfo = [self dictionaryFromResponseData:data];
        
        if(loginInfo) {
            user_id = [[loginInfo objectForKey:@"user"] objectForKey:@"id"];
            username = [[[loginInfo objectForKey:@"user"] objectForKey:@"username"] objectForKey:@"_content"];
            [delegate authorizationCompleteForPhotoSource:self];
        }
        else {
            [delegate authorizationErrorForPhotoSource:self];
        }
    }
    else {
        [delegate authorizationErrorForPhotoSource:self];
    }
    
    

}
    

- (void)testLoginFailed:(OAServiceTicket *)ticket withData:(NSError *)error
{
    NSLog(@"test login failed for %@", key);
    [delegate authorizationErrorForPhotoSource:self];
}


- (void)moarPhotos:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    
    if (ticket.didSucceed) {
        
        NSDictionary *newPhotos = [self dictionaryFromResponseData:data];
        
        if(!newPhotos) {
            NSLog(@"There was an error interpreting the json response from the request for more photos from %@", key);
            return;
        }
        
        // Grab the paging information...
        currentPage = [[[newPhotos objectForKey:@"photos"] objectForKey:@"page"] intValue];
        totalPages = [[[newPhotos objectForKey:@"photos"] objectForKey:@"pages"] intValue];
        
        // If we've run out of pages, we need to set a new date range to search and reset the page numbering.
        if (currentPage >= totalPages) {
            NSLog(@"Next search will change the date range.");
            maxYear = minYear;
            maxMonth = minMonth;
            maxDay = minDay;
            
            if(minMonth - 3 < 1) {
                minMonth = 12 + (minMonth - 3);
                minYear = minYear - 1;
            }
            else {
                minMonth = minMonth - 3;
            }
            
            currentPage = 0;
            totalPages = 0;
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
            
            [photoDict setObject:kFlickrCommentsDomain forKey:kCacheCommentsDomain];
            [photoDict setObject:kFlickrFavoritesDomain forKey:kCacheFavoritesDomain];
            [photoDict setObject:kFlickrImageDomain forKey:kCacheImageDomain];
            
            [photoDict setObject:[photoDict objectForKey:@"id"] forKey:kPhotoID];
            [photoDict setObject:[photoDict objectForKey:@"owner"] forKey:kPhotoUserID];
            [photoDict setObject:[photoDict objectForKey:@"ownername"] forKey:kPhotoUsername];
            [photoDict setObject:[photoDict objectForKey:@"title"] forKey:kPhotoTitle];
            
            EMTLPhoto *photo = [[EMTLPhoto alloc] initWithDict:photoDict];
            photo.source = self;
            [photos addObject:photo];
        }
        
        [photoDelegate photoSource:self retreivedMorePhotos:photos];
    }
    
    loading = NO;
}


- (void)moarPhotos:(OAServiceTicket *)ticket didFailWithError:(NSError *)data
{
    NSLog(@"There was an error loading more photos from: %@", key);
    loading = NO;
}



- (NSDictionary *)dictionaryFromResponseData:(NSData *)data
{
    
    NSError *error;
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (!error && [[dict objectForKey:@"stat"] isEqualToString:@"ok"]) {
        return dict;
    }
    else if(!error) {
        NSLog(@"The response from %@ indicated an error.", key);
        NSLog(@"%@", [dict description]);
    }
    
    NSLog(@"An error occurred while interpreting a JSON response from %@", key);
    return nil;
}


@end

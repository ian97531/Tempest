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
#import "EMTLComment.h"
#import "EMTLFavorite.h"

NSString *const kFlickrRequestTokenURL = @"http://www.flickr.com/services/oauth/request_token";
NSString *const kFlickrAuthorizationURL = @"http://www.flickr.com/services/oauth/authorize";
NSString *const kFlickrAccessTokenURL = @"http://www.flickr.com/services/oauth/access_token";
NSString *const kFlickrAPICallURL = @"http://api.flickr.com/services/rest";
NSString *const kFlickrDefaultsServiceProviderName = @"flickr-access-token";
NSString *const kFlickrDefaultsPrefix = @"com.Elemental.Flickrgram";
double const kSecondsInAYear = 7776500;

@implementation EMTLFlickr

@synthesize delegate;
@synthesize photoDelegate;
@synthesize key;
@synthesize authorizationURL;

@synthesize user_id;
@synthesize username;
@synthesize expired;

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
        
        NSDate *minDate = [NSDate dateWithTimeIntervalSinceNow:-kSecondsInAYear];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *minComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:minDate];
        
        minYear = [minComponents year];
        minMonth = [minComponents month];
        minDay = [minComponents day] + 2;
                
        expired = NO;
        loading = NO;
    }
    
    return self;
}

- (void)getPhotoFavorites:(NSString *)photo_id delegate:(id)theDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector
{
    [self getPhotoFavorites:photo_id page:1 delegate:theDelegate didFinishSelector:finishSelector didFailSelector:failSelector];
}

- (void)getPhotoFavorites:(NSString *)photo_id page:(int)page delegate:(id)theDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector
{
    //NSLog(@"Requesting page %i of favorites for photo_id %@ from %@.", page, photo_id, key);
    
    
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:4];
    [args setObject:kFlickrAPIKey 
             forKey:@"api_key"];
    
    [args setObject:photo_id
             forKey:@"photo_id"];
    
    [args setObject:@"50"
             forKey:@"per_page"];
    
    [args setObject:[NSString stringWithFormat:@"%i", page]
             forKey:@"page"];
    
    
    [self callMethod:@"flickr.photos.getFavorites" 
       withArguments:args 
            delegate:theDelegate
   didFinishSelector:finishSelector
     didFailSelector:failSelector];
}



- (void)getPhotoComments:(NSString *)photo_id delegate:(id)theDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector
{
    //NSLog(@"Requesting comments for photo_id %@ from %@.", photo_id, key);
    
    
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:4];
    [args setObject:kFlickrAPIKey 
             forKey:@"api_key"];
    
    [args setObject:photo_id
             forKey:@"photo_id"];
    
    
    [self callMethod:@"flickr.photos.comments.getList" 
         withArguments:args 
              delegate:theDelegate
     didFinishSelector:finishSelector
       didFailSelector:failSelector];
}


- (void)morePhotos
{
    [self morePhotos:100];
}


- (void)morePhotos:(int)num
{
    if(!loading) {
        loading = YES;
        
        NSLog(@"Requesting more photos from %@.", key);

        
        NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:4];
        [args setObject:kFlickrAPIKey 
                 forKey:@"api_key"];
        
        [args setObject:[[NSNumber numberWithInt:num] stringValue] 
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
        
        [self callMethod:@"flickr.photos.search" 
           withArguments:args 
       didFinishSelector:@selector(moarPhotos:didFinishWithData:) 
         didFailSelector:@selector(moarPhotos:didFailWithError:)];
    }
    
}


- (void)moarPhotos:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    
    if (ticket.didSucceed) {
        NSError *error;
        NSDictionary *newPhotos = [self extractJSONFromData:data withError:&error];
        
        if(error) {
            [photoDelegate photoSource:self encounteredAnError:error];
            NSLog(@"There was an error interpreting the json from the request for more photos from %@", key);
            return;
        }
        
        if(newPhotos) {
            NSLog(@"%@", [newPhotos description]);
            
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
                
                // Construct the URLs
                NSString *farm = [photoDict objectForKey:@"farm"];
                NSString *server = [photoDict objectForKey:@"server"];
                NSString *secret = [photoDict objectForKey:@"secret"];
                NSString *photo_id = [photoDict objectForKey:@"id"];
                
                NSURL *image_URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", farm, server, photo_id, secret, @"z"]];
                
                [photoDict setObject:image_URL forKey:@"url"];
                
                // Get the dates
                NSDate* lastupdate = [NSDate dateWithTimeIntervalSince1970:[[photoDict objectForKey:@"lastupdate"] doubleValue]];
                NSDate* datePosted = [NSDate dateWithTimeIntervalSince1970:[[photoDict objectForKey:@"dateupload"] doubleValue]];
                
                [photoDict setObject:lastupdate forKey:@"date_updated"];
                [photoDict setObject:datePosted forKey:@"date_posted"];
                
                // Set the aspect ratio
                
                if([photoDict objectForKey:@"o_width"] && [photoDict objectForKey:@"o_height"]) {
                    float o_width = [[photoDict objectForKey:@"o_width"] floatValue];
                    float o_height = [[photoDict objectForKey:@"o_height"] floatValue];
                    
                    [photoDict setObject:[NSNumber numberWithFloat:(o_width/o_height)] forKey:@"aspect_ratio"];
                }
                
                
                
                EMTLPhoto *photo = [[EMTLPhoto alloc] initWithDict:photoDict];
                photo.source = self;
                [photos addObject:photo];
            }
            
            [photoDelegate photoSource:self retreivedMorePhotos:photos];
        }
        else {
            expired = YES;
        }
       
    }
    
    
    loading = NO;


}

- (void)moarPhotos:(OAServiceTicket *)ticket didFailWithError:(NSError *)data
{
    NSLog(@"There was an error loading more photos from: %@", key);
    loading = NO;
}

- (NSURL *)defaultUserIconURL
{
    return [NSURL URLWithString:@"http://www.flickr.com/images/buddyicon.gif"];
}

- (NSArray *)extractComments:(NSData *)data
{
    NSError *error;
    NSDictionary *commentsDict = [self extractJSONFromData:data withError:&error];
    
    if(error) {
        [photoDelegate photoSource:self encounteredAnError:error];
        NSLog(@"There was an error interpreting the json from the request for comments from %@", key);
        return nil;
    }
    else {
        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:20];
        
        for (NSDictionary *commentDict in [[commentsDict objectForKey:@"comments"] objectForKey:@"comment"]) {
            // Get the date
            NSDate *comment_date = [NSDate dateWithTimeIntervalSince1970:[[commentDict objectForKey:@"datecreate"] doubleValue]];
            [commentDict setValue:comment_date forKey:@"comment_date"];
            
            // Get the icon URL
            int iconfarm = [[commentDict objectForKey:@"iconfarm"] intValue];
            int iconserver = [[commentDict objectForKey:@"iconserver"] intValue];
            NSString *nsid = [commentDict objectForKey:@"author"];
            
            if (iconfarm && iconserver) {
                NSURL *userIconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%i.staticflickr.com/%i/buddyicons/%@.jpg", iconfarm, iconserver, nsid]];
                [commentDict setValue:userIconURL forKey:@"icon_url"];
            }
            
            [commentDict setValue:[commentDict objectForKey:@"_content"] forKey:@"comment"];
            
            [comments addObject:[[EMTLComment alloc] initWithDict:commentDict]];
            
            
        }
        
        return comments;
    }
    
}

- (NSArray *)extractFavorites:(NSData *)data forPhoto:(EMTLPhoto *)photo;
{
    NSError *error;
    NSDictionary *favoritesDict = [self extractJSONFromData:data withError:&error];
    
    if(error) {
        [photoDelegate photoSource:self encounteredAnError:error];
        NSLog(@"There was an error interpreting the json from the request for favorites from %@", key);
        return nil;
    }
    else {
        //NSLog(@"%@", [favoritesDict description]);
        NSMutableArray *favorites = [NSMutableArray arrayWithCapacity:20];
        
        for (NSDictionary *favoriteDict in [[favoritesDict objectForKey:@"photo"] objectForKey:@"person"]) {
            // Get the date
            NSDate *favorite_date = [NSDate dateWithTimeIntervalSince1970:[[favoriteDict objectForKey:@"favedate"] doubleValue]];
            [favoriteDict setValue:favorite_date forKey:@"favorite_date"];
            
            // Get the icon URL
            int iconfarm = [[favoriteDict objectForKey:@"iconfarm"] intValue];
            int iconserver = [[favoriteDict objectForKey:@"iconserver"] intValue];
            NSString *nsid = [favoriteDict objectForKey:@"nsid"];
            
            if (iconfarm && iconserver) {
                NSURL *userIconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%i.staticflickr.com/%i/buddyicons/%@.jpg", iconfarm, iconserver, nsid]];
                [favoriteDict setValue:userIconURL forKey:@"icon_url"];
            }
                        
            [favorites addObject:[[EMTLFavorite alloc] initWithDict:favoriteDict]];
            
            if ([nsid isEqualToString:user_id]) {
                photo.isFavorite = YES;
            }
            
            
        }
        return favorites;
    }
    

}
    

- (NSDictionary *)extractJSONFromData:(NSData *)data withError:(NSError **) error;
{
    
        
        NSDictionary * loginInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:error];
        
        if (!*error && [[loginInfo objectForKey:@"stat"] isEqualToString:@"ok"]) {
            return loginInfo;
        }
        else if(!*error) {
            NSLog(@"an error occurred in extract JSON");
            __autoreleasing NSError *newError = [NSError errorWithDomain:[loginInfo objectForKey:@"message"] code:[[loginInfo objectForKey:@"code"] intValue] userInfo:loginInfo];
            error = &newError;
        }
        
        NSLog(@"an error occurred in extract JSON");
        return nil;
    

}



- (void)authorize {
    consumer = [[OAConsumer alloc] initWithKey:kFlickrAPIKey secret:kFlickrAPISecret];
    
    accessToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:kFlickrDefaultsServiceProviderName prefix:kFlickrDefaultsPrefix];
    if(accessToken) {
        NSLog(@"Found a token for %@ in the user defaults.", key);
        //[delegate authorizationCompleteForSource:self];
        
        [self callMethod:@"flickr.test.login" didFinishSelector:@selector(testLoginFinished:withData:) didFailSelector:@selector(testLoginFailed:withData:)];
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

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    
    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (ticket.didSucceed) {
        
        requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        NSString *url = [NSString stringWithFormat:@"%@?perms=write&oauth_token=%@", kFlickrAuthorizationURL, requestToken.key];
        authorizationURL = [NSURL URLWithString:url];
        
        [delegate photoSource:self requiresAuthorizationAtURL:authorizationURL];
        return;
    }
    
    NSLog(@"Got an error in requestTokenTicket:withData:. The ticket did not succeed for %@", key);
    [delegate photoSource:self authorizationError:[NSError errorWithDomain:ticket.body code:0 userInfo:nil]];
    
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    [delegate photoSource:self authorizationError:error];
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"Got a response for the access ticket for %@", key);
    if (ticket.didSucceed) {
        
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        
        accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        [accessToken storeInUserDefaultsWithServiceProviderName:kFlickrDefaultsServiceProviderName prefix:kFlickrDefaultsPrefix];
        [self callMethod:@"flickr.test.login" didFinishSelector:@selector(testLoginFinished:withData:) didFailSelector:@selector(testLoginFailed:withData:)];
        
        return;
    }
    
    NSLog(@"Got an error in accessTicketToken:withData:. The ticket did not succeed for %@", key);
    [delegate photoSource:self authorizationError:[NSError errorWithDomain:ticket.body code:0 userInfo:nil]];
    
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"got an error while trying to get the access token for %@", key);
    [delegate photoSource:self authorizationError:error];
}

- (void)testLoginFinished:(OAServiceTicket *)ticket withData:(NSData *)data
{
    NSLog(@"Got a response for the test login for %@", key);
    
    if (ticket.didSucceed) {
        NSError *error;
        NSDictionary *loginInfo = [self extractJSONFromData:data withError:&error];
        
        if(!error) {
            user_id = [[loginInfo objectForKey:@"user"] objectForKey:@"id"];
            username = [[[loginInfo objectForKey:@"user"] objectForKey:@"username"] objectForKey:@"_content"];
            [delegate authorizationCompleteForSource:self];
        }
        else {
            [delegate photoSource:self authorizationError:error];
        }
    }
    else {
        [delegate photoSource:self authorizationError:nil];
    }
    
    

}
    
- (void)testLoginFailed:(OAServiceTicket *)ticket withData:(NSError *)error
{
    NSLog(@"test login failed for %@", key);
    [delegate photoSource:self authorizationError:error];
}





- (void)callMethod:(NSString *)method didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector
{
    [self callMethod:method withArguments:nil delegate:self didFinishSelector:finishSelector didFailSelector:failSelector];
}

- (void)callMethod:(NSString *)method withArguments:(NSDictionary *)args didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector
{
    [self callMethod:method withArguments:args delegate:self didFinishSelector:finishSelector didFailSelector:failSelector];
}

- (void)callMethod:(NSString *)method delegate:(id)theDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector
{
    [self callMethod:method withArguments:nil delegate:theDelegate didFinishSelector:finishSelector didFailSelector:failSelector];
}

- (void)callMethod:(NSString *)method withArguments:(NSDictionary *)args delegate:(id)theDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector
{
    
    //NSLog(@"making a new method call for %@ for service: %@.", method, key);
    NSURL *url = [NSURL URLWithString:kFlickrAPICallURL];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    
    NSMutableArray *requestParameters;
    OARequestParameter *nameParam;
    
    if(args) {
        requestParameters = [[NSMutableArray alloc] initWithCapacity:args.count + 3];
        
        for (NSString *theKey in [args allKeys]) {
            
            nameParam = [[OARequestParameter alloc] initWithName:theKey
                                                                               value:[args objectForKey:theKey]];
            [requestParameters addObject:nameParam];
        }
        
    }
    else {
        requestParameters = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    
    nameParam = [[OARequestParameter alloc] initWithName:@"method"
                                                   value:method];
    [requestParameters addObject:nameParam];
    
    nameParam = [[OARequestParameter alloc] initWithName:@"nojsoncallback"
                                                   value:@"1"];
    [requestParameters addObject:nameParam];
    
    nameParam = [[OARequestParameter alloc] initWithName:@"format"
                                                   value:@"json"];
    [requestParameters addObject:nameParam];
    

    [request setParameters:requestParameters];
    
    [request setHTTPMethod:@"GET"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request 
                         delegate:theDelegate 
                didFinishSelector:finishSelector 
                  didFailSelector:failSelector];

}

@end

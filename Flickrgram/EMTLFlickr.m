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

NSString *const kFlickrRequestTokenURL = @"http://www.flickr.com/services/oauth/request_token";
NSString *const kFlickrAuthorizationURL = @"http://www.flickr.com/services/oauth/authorize";
NSString *const kFlickrAccessTokenURL = @"http://www.flickr.com/services/oauth/access_token";
NSString *const kFlickrAPICallURL = @"http://api.flickr.com/services/rest";
NSString *const kFlickrDefaultsServiceProviderName = @"flickr-access-token";
NSString *const kFlickrDefaultsPrefix = @"com.Elemental.Flickrgram";

@implementation EMTLFlickr

@synthesize delegate;
@synthesize photoDelegate;
@synthesize key;
@synthesize authorizationURL;

@synthesize user_id;
@synthesize username;
@synthesize photos;

- (id)init
{
    self = [super init];
    if (self) {
        key = @"flickr";
        photos = [[NSMutableArray alloc] initWithCapacity:100];
        currentPhoto = 0;
    }
    
    return self;
}

- (void)morePhotos
{
    [self morePhotos:10];
}


- (void)morePhotos:(int)num
{
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:4];
    [args setObject:kFlickrAPIKey forKey:@"api_key"];
    [args setObject:@"1" forKey:@"include_self"];
    [args setObject:[[NSNumber numberWithInt:num] stringValue] forKey:@"count"];
    [args setObject:@"date_taken,owner_name" forKey:@"extras"];
    
    [self callMethod:@"flickr.photos.getContactsPhotos" 
       withArguments:args 
   didFinishSelector:@selector(moarPhotos:didFinishWithData:) 
     didFailSelector:@selector(moarPhotos:didFailWithError:)];
}


- (void)moarPhotos:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSError *error;
    NSDictionary *newPhotos = [self extractJSON:data fromTicket:ticket withError:&error];
    
    if(error) {
        [photoDelegate photoSource:self encounteredAnError:error];
        return;
    }
    else if(newPhotos) {
        NSLog(@"%@", [newPhotos description]);
        
        for (NSMutableDictionary *photoDict in [[newPhotos objectForKey:@"photos"] objectForKey:@"photo"]) {
            
            NSString *farm = [photoDict objectForKey:@"farm"];
            NSString *server = [photoDict objectForKey:@"server"];
            NSString *secret = [photoDict objectForKey:@"secret"];
            NSString *photo_id = [photoDict objectForKey:@"id"];
            
            NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", farm, server, photo_id, secret, @"b"]];
            NSURL *smallURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", farm, server, photo_id, secret, @"z"]];
            
            [photoDict setObject:URL forKey:@"url"];
            [photoDict setObject:smallURL forKey:@"small_url"];
            
            EMTLPhoto *photo = [[EMTLPhoto alloc] initWithDict:photoDict];
            [photos addObject:photo];
        }
        
        [photoDelegate photoSource:self addedPhotosToArray:photos atIndex:currentPhoto];
        currentPhoto = photos.count - 1;
    }


}

- (void)moarPhotos:(OAServiceTicket *)ticket didFailWithError:(NSError *)data
{
    
}
    
- (NSDictionary *)extractJSON:(NSData *)data fromTicket:(OAServiceTicket *)ticket withError:(NSError **) error
{
    NSLog(@"Got a response for the test login for %@", key);
    
    if (ticket.didSucceed) {
        
        NSDictionary * loginInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:error];
        
        if (!*error && [[loginInfo objectForKey:@"stat"] isEqualToString:@"ok"]) {
            return loginInfo;
        }
        else if(!*error) {
            __autoreleasing NSError *newError = [NSError errorWithDomain:[loginInfo objectForKey:@"message"] code:[[loginInfo objectForKey:@"code"] intValue] userInfo:loginInfo];
            error = &newError;
        }
        
        return nil;
    }
    else {
        __autoreleasing NSError *newError = [NSError errorWithDomain:ticket.body code:0 userInfo:nil];
        error = &newError;
        return nil;
    }

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
    NSError *error;
    NSDictionary *loginInfo = [self extractJSON:data fromTicket:ticket withError:&error];
    
    if(!error) {
        user_id = [[loginInfo objectForKey:@"user"] objectForKey:@"id"];
        username = [[[loginInfo objectForKey:@"user"] objectForKey:@"username"] objectForKey:@"_content"];
        [delegate authorizationCompleteForSource:self];
    }
    else {
        [delegate photoSource:self authorizationError:error];
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
    
    NSLog(@"making a new method call for %@ for service: %@.", method, key);
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

//
//  EMTLFlickr.m
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickr.h"
#import "APISecrets.h"

NSString *const kFlickrRequestTokenURL = @"http://www.flickr.com/services/oauth/access_token";
NSString *const kFlickrAccessTokenURL = @"http://www.flickr.com/services/oauth/access_token";

@implementation EMTLFlickr

@synthesize delegate;
@synthesize key;

- (id)init
{
    self = [super init];
    if (self) {
        key = @"flickr";
    }
    
    return self;
}

- (NSArray *)getMorePhotos
{
    
    
    
    return [NSArray arrayWithObject:@"hey"];
    
    
    //    NSMutableArray *returnValue = [[NSMutableArray alloc] initWithCapacity:20];
    //    
    //    for (int i=0; i < 20; i++) {
    //        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
    //        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%i", i]];
    //        
    //        [dict setObject:image forKey:@"image"];
    //        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"isFavorite"];
    //        [dict setObject:[NSNumber numberWithInt:12] forKey:@"numFavorites"];
    //        [dict setObject:[NSNumber numberWithInt:4] forKey:@"numComments"];
    //        [dict setObject:[NSNumber numberWithInt:i] forKey:@"id"];
    //        
    //        [returnValue addObject:dict];
    //        
    //    }
    //    
    //    return returnValue;
}

- (NSArray *)getMorePhotos:(int)num
{
    return [self getMorePhotos];
}



- (void)authorize {
    consumer = [[OAConsumer alloc] initWithKey:kFlickrAPIKey secret:kFlickrAPISecret];
    
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
    NSLog(@"about to fetch");
    [fetcher fetchDataWithRequest:request 
                         delegate:self 
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) 
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    NSLog(@"did fetch");
    
}

- (void)authorizedWithVerifier:(NSString *)verfier
{
    NSLog(@"Got verifier: %@", verfier);
    token.verifier = verfier;
    
    NSURL *url = [NSURL URLWithString:kFlickrAccessTokenURL];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:nil
                                                          signatureProvider:nil];
    
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    NSLog(@"about to fetch");
    [fetcher fetchDataWithRequest:request 
                         delegate:self 
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) 
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    NSLog(@"did fetch");
    
    
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"got callback");
    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (ticket.didSucceed) {
        NSLog(@"succeeded!");
        
        token = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        NSString *url = [NSString stringWithFormat:@"http://www.flickr.com/services/oauth/authorize?perms=write&oauth_token=%@", token.key];
        
        [delegate photoSource:self requiresAuthorizationAtURL:[NSURL URLWithString:url]];
        
        NSLog(@"Done!");
    }
    else {
        NSLog(@"ticket failed");
    }
    
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"got an error");
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"got an error");
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"new URL: %@", webView.request.URL.absoluteString);
}

@end

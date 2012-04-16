//
//  EMTLPhotoSource.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoSource.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"

@implementation EMTLPhotoSource

- (NSArray *)getMorePhotos
{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"93adba71b029d79c1923ca96e063654d" secret:@"103f6affa6c80a04"];
    
    NSURL *url = [NSURL URLWithString:@"http://www.flickr.com/services/oauth/request_token"];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
                  
    [request setOAuthParameterName:@"oauth_callback" 
                         withValue:@"http://www.flickr.com/auth-72157629832409497"];
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    NSLog(@"about to fetch");
    [fetcher fetchDataWithRequest:request 
                         delegate:self 
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) 
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    NSLog(@"did fetch");
       
    
    
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

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"got callback");
    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (ticket.didSucceed) {
        NSLog(@"succeeded!");
        
        OAToken *requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
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

@end

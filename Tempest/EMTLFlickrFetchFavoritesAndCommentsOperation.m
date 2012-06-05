//
//  EMTLFetchFavoritesAndCommentsOperation.m
//  Tempest
//
//  Created by Ian White on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrFetchFavoritesAndCommentsOperation.h"
#import "EMTLPhoto.h"
#import "EMTLFlickrPhotoSource.h"
#import "EMTLLocation.h"
#import "EMTLUser.h"


@implementation EMTLFlickrFetchFavoritesAndCommentsOperation


- (id)initWithPhoto:(EMTLPhoto *)photo photoSource:(EMTLFlickrPhotoSource *)source
{
    self = [super init];
    if (self) {
        _photo = photo;
        _photoSource = source;
        _finished = NO;
        _executing = NO;

        _favoritesCurrentPage = 0;
        _favoritesPages = 1;
        
        _favorites = [NSMutableArray array];
        _comments = [NSMutableArray array];
        
    }
    
    return self;
}




- (void)start
{
    if (_finished) {
        return;
    }
    
    //NSLog(@"Requesting comments and favorites for photo: %@", _photo.photoID);
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self _startFavoritesRequest];
    [self _startCommentsRequest];
    
    _photo.comments = _comments;
    _photo.favorites = _favorites;

    if (_photo.location) {
        [self _startLocationRequest];
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    //NSLog(@"finished requesting comments and favorites for photo: %@", _photo.photoID);
    
}

- (void)cancel
{
    
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



- (void) _startFavoritesRequest
{
    
    while (_favoritesCurrentPage < _favoritesPages) {
        //NSLog(@"Getting favorites page %i of %i for %@", _favoritesCurrentPage, _favoritesPages, _photo.photoID);
        // Fetch the favorites
        NSMutableDictionary *favoriteArgs = [NSMutableDictionary dictionaryWithCapacity:4];
        [favoriteArgs setObject:kFlickrAPIKey 
                         forKey:kFlickrAPIArgumentAPIKey];
        
        [favoriteArgs setObject:_photo.photoID
                         forKey:kFlickrAPIArgumentPhotoID];
        
        [favoriteArgs setObject:@"50"
                         forKey:kFlickrAPIArgumentItemsPerPage];
        
        [favoriteArgs setObject:[[NSNumber numberWithInt:_favoritesCurrentPage + 1] stringValue]
                         forKey:kFlickrAPIArgumentPageNumber];
        
        OAMutableURLRequest *favoriteRequest = [_photoSource oaurlRequestForMethod:kFlickrAPIMethodPhotoFavorites arguments:favoriteArgs];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *favoritesData = [NSURLConnection sendSynchronousRequest:favoriteRequest returningResponse:&response error:&error];
        [_favorites addObjectsFromArray:[self _processFavorites:favoritesData]];
    }
    
    
}



-(void) _startCommentsRequest
{
    // Fetch the comments
    NSMutableDictionary *commentsArgs = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [commentsArgs setObject:kFlickrAPIKey 
                     forKey:kFlickrAPIArgumentAPIKey];
    
    [commentsArgs setObject:_photo.photoID
                     forKey:kFlickrAPIArgumentPhotoID];
    
    OAMutableURLRequest *commentRequest = [_photoSource oaurlRequestForMethod:kFlickrAPIMethodPhotoComments arguments:commentsArgs];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *commentsData = [NSURLConnection sendSynchronousRequest:commentRequest returningResponse:&response error:&error];
    [_comments addObjectsFromArray:[self _processComments:commentsData]];
    
}

- (void)_startLocationRequest
{
    // Fetch the comments
    NSMutableDictionary *locationArgs = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [locationArgs setObject:kFlickrAPIKey 
                     forKey:kFlickrAPIArgumentAPIKey];
    
    [locationArgs setObject:_photo.location.woe_id
                     forKey:kFlickrAPIArgumentLocation];
    
    OAMutableURLRequest *locationRequest = [_photoSource oaurlRequestForMethod:kFlickrAPIMethodPhotoLocation arguments:locationArgs];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *locationData = [NSURLConnection sendSynchronousRequest:locationRequest returningResponse:&response error:&error];
    
    [self _processLocation:locationData];
}


- (NSArray *)_processFavorites:(NSData *)favoritesData
{
    NSDictionary *favoritesDict = [_photoSource dictionaryFromResponseData:favoritesData];

    if (!favoritesDict) {
        NSLog(@"There was an error interpreting the json response from the request for more photos from %@", _photoSource.serviceName);
        return [NSArray array];
    }
    else {
        
        NSMutableArray *favorites = [NSMutableArray arrayWithCapacity:20];
        
        _favoritesPages = [[[favoritesDict objectForKey:@"photo"] objectForKey:@"pages"] intValue];
        _favoritesCurrentPage = [[[favoritesDict objectForKey:@"photo"] objectForKey:@"page"] intValue];
        
        // Iterate through all of the favorites. We need to put the data into a format
        // that the generic EMTLPhoto class will understand.
        for (NSDictionary *favoriteDict in [[favoritesDict objectForKey:@"photo"] objectForKey:@"person"]) {
            
            // Get the date of the favoriting
            NSDate *favorite_date = [NSDate dateWithTimeIntervalSince1970:[[favoriteDict objectForKey:@"favedate"] doubleValue]];
            [favoriteDict setValue:favorite_date forKey:kFavoriteDate];
            
            // Setup the user
            EMTLUser *user = [_photoSource userForUserID:[favoriteDict objectForKey:@"nsid"]];
            
            // If the nsid is same as the calling user, then this photo has been favorited and we should mark it as such.
            if (user == _photoSource.user)
            {
                NSLog(@"photo is favorite %@", _photo.photoID);
                _photo.isFavorite = YES;
            }
            
            if (!user.username)
            {
                user.username = [favoriteDict objectForKey:@"username"];
            }
            
            [favoriteDict setValue:user forKey:kFavoriteUser];
            
                        
            // Add the modified dict to the array of favorites.
            [favorites addObject:favoriteDict];
            
        }
        return favorites;
    }

}

- (NSArray *)_processComments:(NSData *)commentsData
{
    NSDictionary *commentsDict = [_photoSource dictionaryFromResponseData:commentsData];

    if(!commentsDict) {
        NSLog(@"There was an error interpreting the json response for comments from %@", _photoSource.serviceName);
        return [NSArray array];
    }

    else {
        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:20];
        
        for (NSDictionary *commentDict in [[commentsDict objectForKey:@"comments"] objectForKey:@"comment"]) {
            
            // Get the date of the comment
            NSDate *comment_date = [NSDate dateWithTimeIntervalSince1970:[[commentDict objectForKey:@"datecreate"] doubleValue]];
            [commentDict setValue:comment_date forKey:kCommentDate];
            
            // Setup the user
            EMTLUser *user = [_photoSource userForUserID:[commentDict objectForKey:@"author"]];
            
            if (!user.username)
            {
                user.username = [commentDict objectForKey:@"authorname"];
            }
            
            [commentDict setValue:user forKey:kCommentUser];
            [commentDict setValue:[commentDict objectForKey:@"_content"] forKey:kCommentText];
            
            [comments addObject:commentDict];
        }
        return comments;
    }
}

- (void)_processLocation:(NSData *)locationData
{
    NSDictionary *locationDict = [_photoSource dictionaryFromResponseData:locationData];
    
    if(!locationDict) 
    {
        NSLog(@"There was an error interpreting the json response for location from %@", _photoSource.serviceName);
    }
    
    else {
        
        NSDictionary *place = [locationDict objectForKey:@"place"];
        NSString *place_string = @"";
        
        // These are the place types we can process
        NSArray *process_places = [NSArray arrayWithObjects:@"nothing", @"neighbourhood", @"locality", @"country", nil];
        
        // Get the place type
        NSString *place_type = [place objectForKey:@"place_type"];
        
        // If we got the county place type, we round it up to country.
        if ([place_type isEqualToString:@"county"]) {
            place_type = @"country";
        }
        
        // We want to process the place type, and each place type that's broader than what was
        // specified.
        EMTLLocationType starting_point = [process_places indexOfObject:place_type];
        
        for (int i = starting_point; i < EMTLLocationUndefined; i++) {
            
            if (i == EMTLLocationNeighbourhood)
            {
                NSString *neighborhood = [[[[place objectForKey:@"neighbourhood"] objectForKey:@"_content"] componentsSeparatedByString:@", "] objectAtIndex:0];
                place_string = [NSString stringWithFormat:@"%@ in ", neighborhood];
            }
            
            
            if (i == EMTLLocationLocality)
            {
                NSString *country = [[place objectForKey:@"country"] objectForKey:@"_content"];
                NSArray *locality = [[[place objectForKey:@"locality"] objectForKey:@"_content"] componentsSeparatedByString:@", "];
                
                if ([country isEqualToString:@"United States"])
                {
                    NSString *town = [locality objectAtIndex:0];
                    NSString *state = [self shortState:[locality objectAtIndex:1]];
                    place_string = [NSString stringWithFormat:@"%@%@, %@, ", place_string, town, state];
                }
                else
                {
                    NSString *town = [locality objectAtIndex:0];
                    place_string = [NSString stringWithFormat:@"%@%@, ", place_string, town];
                }
            }
            
            
            if (i == EMTLLocationCountry)
            {
                NSString *country = [self shortCountry:[[place objectForKey:@"country"] objectForKey:@"_content"]];
                place_string = [NSString stringWithFormat:@"%@%@", place_string, country];
            }
            
        }
        
        _photo.location.name = place_string;
        _photo.location.type = starting_point;
    }
    
    
}

- (NSString *)shortCountry:(NSString *)longCountry
{
    NSDictionary *countryAbbreviations = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"UK", @"United Kingdom",
                                        @"US", @"United States",
                                          nil];
    
    NSString *shortCountry = [countryAbbreviations objectForKey:longCountry];
    
    return shortCountry ? shortCountry : longCountry;
    
}

- (NSString *)shortState:(NSString *)longState
{
    NSDictionary *stateAbbreviations = [NSDictionary dictionaryWithObjectsAndKeys:
										@"AL",	@"Alabama", 
                                        @"AK",	@"Alaska",
                                        @"AZ",	@"Arizona",
                                        @"AR",	@"Arkansas",
                                        @"CA",	@"California",
                                        @"CO",	@"Colorado",
                                        @"CT",	@"Connecticut",
                                        @"DE",	@"Deleware",
                                        @"DC",	@"District of Columbia",
                                        @"FL",	@"Florida",
                                        @"GA",	@"Georgia",
                                        @"HI",	@"Hawaii",
                                        @"ID",	@"Idaho",
                                        @"IL",	@"Illinois",
                                        @"IN",	@"Indiana",
                                        @"IA",	@"Iowa",
                                        @"KS",	@"Kansas",
                                        @"KS",	@"Kentucky",
                                        @"LA",	@"Louisiana",
                                        @"ME",	@"Maine",
                                        @"MD",	@"Maryland",
                                        @"MA",	@"Massachusetts",
                                        @"MI",	@"Michigan",
                                        @"MN",	@"Minnesota",
                                        @"MS",	@"Mississippi",
                                        @"MO",	@"Missouri",
                                        @"MT",	@"Montana",
                                        @"NE",	@"Nebraska",
                                        @"NV",	@"Nevada",
                                        @"NH",	@"New Hampshire",
                                        @"NJ",	@"New Jersey",
                                        @"NM",	@"New Mexico",
                                        @"NY",	@"New York",
                                        @"NC",	@"North Carolina",
                                        @"ND",	@"North Dakota",
                                        @"OH",	@"Ohio",
                                        @"OK",	@"Oklahoma",
                                        @"OR",	@"Oregon",
                                        @"PA",	@"Pennsylviania",
                                        @"RI",	@"Rhode Island",
                                        @"SC",	@"South Carolina",
                                        @"SD",	@"South Dakota",
                                        @"TN",	@"Tennessee",
                                        @"TX",	@"Texas",
                                        @"UT",	@"Utah",
                                        @"VT",	@"Vermont",
                                        @"VA",	@"Virginia",
                                        @"WA",	@"Washington",
                                        @"WV",	@"West Virginia",
                                        @"WI",	@"Wisconsin",
                                        @"WY",	@"Wyoming",
                                        nil];
    
    NSString *shortState = [stateAbbreviations objectForKey:longState];
    
    if (shortState) 
    {
        return shortState;
    }
    else 
    {
        NSLog(@"Didn't find a state match for %@", longState);
        return longState;
    }
    
}


@end

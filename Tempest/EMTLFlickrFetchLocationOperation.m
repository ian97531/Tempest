//
//  EMTLFlickrFetchLocationOperation.m
//  Tempest
//
//  Created by Ian White on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrFetchLocationOperation.h"
#import "EMTLFlickrPhotoSource.h"
#import "EMTLPhoto.h"
#import "EMTLLocation.h"

@interface EMTLPhotoSource ()

- (EMTLLocation *)_processLocationData:(NSData *)data;
- (NSString *)_shortCountry:(NSString *)longCountry;
- (NSString *)_shortState:(NSString *)longState;

@end

@implementation EMTLFlickrFetchLocationOperation

- (id)initWithPhoto:(EMTLPhoto *)photo photoSource:(EMTLFlickrPhotoSource *)photoSource
{
    self = [super init];
    if (self) 
    {
        _photo = photo;
        _photoSource = photoSource;
    }
    
    return self;
}



#pragma mark -
#pragma mark NSURLConnectionDataDelegate Methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [super connectionDidFinishLoading:connection];
    
    [self _processLocationData:_incomingData];
    
    
}

#pragma mark -
#pragma mark NSOperation Methods

- (void)start
{
    NSLog(@"getting location");
    // Fetch the comments
    NSMutableDictionary *locationArgs = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [locationArgs setObject:EMTLFlickrAPIKey 
                     forKey:EMTLFlickrAPIArgumentAPIKey];
    
    [locationArgs setObject:_photo.location.woe_id
                     forKey:EMTLFlickrAPIArgumentLocation];
    
    OAMutableURLRequest *locationRequest = [_photoSource oaurlRequestForMethod:EMTLFlickrAPIMethodPhotoLocation arguments:locationArgs];
    
    [self startRequest:locationRequest];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_photoSource operation:self willRequestLocationForPhoto:_photo];
    });
    
}



- (void)_processLocationData:(NSData *)locationData
{
    NSLog(@"processing location");
    NSDictionary *locationDict = [_photoSource dictionaryFromResponseData:locationData];
    
    if(!locationDict) 
    {
        NSLog(@"There was an error interpreting the json response for location from %@", _photoSource.serviceName);
    }
    
    else {
        
        NSDictionary *place = [locationDict objectForKey:EMTLFlickrAPIResponseLocation];
        NSString *place_string = @"";
        
        // These are the place types we can process
        NSArray *process_places = [NSArray arrayWithObjects:
                                   EMTLFlickrAPIValueLocationTypeUndefined, 
                                   EMTLFlickrAPIValueLocationTypeNeighborhood, 
                                   EMTLFlickrAPIValueLocationTypeLocality, 
                                   EMTLFlickrAPIValueLocationTypeCountry,
                                   nil];
        
        // Get the place type
        NSString *place_type = [place objectForKey:EMTLFlickrAPIResponseLocationType];
        
        // If we got the county place type, we round it up to country.
        if ([place_type isEqualToString:EMTLFlickrAPIValueLocationTypeCounty]) {
            place_type = EMTLFlickrAPIValueLocationTypeCountry;
        }
        
        // We want to process the place type, and each place type that's broader than what was
        // specified.
        EMTLLocationType starting_point = [process_places indexOfObject:place_type];
        
        for (int i = starting_point; i < EMTLLocationUndefined; i++) {
            
            if (i == EMTLLocationNeighbourhood)
            {
                NSString *neighborhood = [[[[place objectForKey:EMTLFlickrAPIValueLocationTypeNeighborhood] 
                                            objectForKey:EMTLFlickrAPIResponseContent] componentsSeparatedByString:@", "] objectAtIndex:0];
                
                // Localize string "in"
                place_string = [NSString stringWithFormat:@"%@ in ", neighborhood];
            }
            
            
            if (i == EMTLLocationLocality)
            {
                NSString *country = [[place objectForKey:EMTLFlickrAPIValueLocationTypeCountry] 
                                     objectForKey:EMTLFlickrAPIResponseContent];
                
                NSArray *locality = [[[place objectForKey:EMTLFlickrAPIValueLocationTypeLocality] 
                                      objectForKey:EMTLFlickrAPIResponseContent] componentsSeparatedByString:@", "];
                
                if ([country isEqualToString:@"United States"])
                {
                    NSString *town = [locality objectAtIndex:0];
                    NSString *state = [self _shortState:[locality objectAtIndex:1]];
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
                NSString *country = [self _shortCountry:[[place objectForKey:EMTLFlickrAPIValueLocationTypeCountry] 
                                                         objectForKey:EMTLFlickrAPIResponseContent]];
                
                place_string = [NSString stringWithFormat:@"%@%@", place_string, country];
            }
            
        }
        
        _photo.location.name = place_string;
        _photo.location.type = starting_point;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_photoSource operation:self didLoadLocationForPhoto:_photo];
        });
        
    }
    
    
    
    
}


#pragma mark -
#pragma mark Location Helper Methods

- (NSString *)_shortCountry:(NSString *)longCountry
{
    NSDictionary *countryAbbreviations = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"UK", @"United Kingdom",
                                          @"US", @"United States",
                                          nil];
    
    NSString *shortCountry = [countryAbbreviations objectForKey:longCountry];
    
    return shortCountry ? shortCountry : longCountry;
    
}

- (NSString *)_shortState:(NSString *)longState
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

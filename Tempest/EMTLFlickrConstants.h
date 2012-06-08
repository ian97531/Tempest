//
//  EMTLFlickrConstants.h
//  Tempest
//
//  Created by Ian White on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// Internal Flickr Query object's keys
extern NSString *const EMTLFlickrQueryTotalPages;
extern NSString *const EMTLFlickrQueryCurrentPage;
extern NSString *const EMTLFlickrQueryMaxYear;
extern NSString *const EMTLFlickrQueryMaxMonth;
extern NSString *const EMTLFlickrQueryMaxDay;
extern NSString *const EMTLFlickrQueryMinYear;
extern NSString *const EMTLFlickrQueryMinMonth;
extern NSString *const EMTLFlickrQueryMinDay;
extern NSString *const EMTLFlickrQueryMethod;
extern NSString *const EMTLFlickrQueryIdentifier;


// Flickr Methods for API Queries
extern NSString *const EMTLFlickrAPIMethodTestLogin;
extern NSString *const EMTLFlickrAPIMethodUserInfo;
extern NSString *const EMTLFlickrAPIMethodSearch;
extern NSString *const EMTLFlickrAPIMethodPopularPhotos;
extern NSString *const EMTLFlickrAPIMethodFavoritePhotos;
extern NSString *const EMTLFlickrAPIMethodUserPhotos;
extern NSString *const EMTLFlickrAPIMethodPhotoFavorites;
extern NSString *const EMTLFlickrAPIMethodPhotoComments;
extern NSString *const EMTLFlickrAPIMethodPhotoLocation;
extern NSString *const EMTLFlickrAPIMethodAddFavorite;
extern NSString *const EMTLFlickrAPIMethodRemoveFavorite;


// Flickr Arguments for API Queries
extern NSString *const EMTLFlickrAPIArgumentUserID;
extern NSString *const EMTLFlickrAPIArgumentPhotoID;
extern NSString *const EMTLFlickrAPIArgumentItemsPerPage;
extern NSString *const EMTLFlickrAPIArgumentPageNumber;
extern NSString *const EMTLFlickrAPIArgumentAPIKey;
extern NSString *const EMTLFlickrAPIArgumentContacts;
extern NSString *const EMTLFlickrAPIArgumentSort;
extern NSString *const EMTLFlickrAPIArgumentExtras;
extern NSString *const EMTLFlickrAPIArgumentLocation;
extern NSString *const EMTLFlickrAPIArgumentContentType;
extern NSString *const EMTLFlickrAPIArgumentMinUploadDate;
extern NSString *const EMTLFlickrAPIArgumentMaxUploadDate;


// Flickr Values for API Queries
extern NSString *const EMTLFlickrAPIValueSortDatePostedDescending;
extern NSString *const EMTLFlickrAPIValueSortDatePostedAscending;
extern NSString *const EMTLFlickrAPIValueSortDateTakenDescending;
extern NSString *const EMTLFlickrAPIValueSortDateTakenAscending;
extern NSString *const EMTLFlickrAPIValueSortInterestingnessDescending;
extern NSString *const EMTLFlickrAPIValueSortInterestingnessAscending;

extern NSString *const EMTLFlickrAPIValuePhotoItemsPerPage;
extern NSString *const EMTLFlickrAPIValuePhotoContentTypePhotosOnly;
extern NSString *const EMTLFlickrAPIValuePhotoExtras;
extern NSString *const EMTLFlickrAPIValuePhotoSearchContactsAll;
extern NSString *const EMTLFlickrAPIValuePhotoSearchContactsFriendsFamily;

extern NSString *const EMTLFlickrAPIValueFavoriteItemsPerPage;


// Flickr Response Keys
extern NSString *const EMTLFlickrAPIResponseStatus;
extern NSString *const EMTLFlickrAPIResponseListTotalNumber;
extern NSString *const EMTLFlickrAPIResponseListPages;
extern NSString *const EMTLFlickrAPIResponseListPage;
extern NSString *const EMTLFlickrAPIResponsePhotoList;
extern NSString *const EMTLFlickrAPIResponsePhotoListItems;
extern NSString *const EMTLFlickrAPIResponseFavoritesList;
extern NSString *const EMTLFlickrAPIResponseFavoritesListItems;
extern NSString *const EMTLFlickrAPIResponseCommentsList;
extern NSString *const EMTLFlickrAPIResponseCommentsListItems;
extern NSString *const EMTLFlickrAPIResponseLocation;
extern NSString *const EMTLFlickrAPIResponseUser;
extern NSString *const EMTLFlickrAPIResponseContent;

extern NSString *const EMTLFlickrAPIResponsePhotoFarm;
extern NSString *const EMTLFlickrAPIResponsePhotoServer;
extern NSString *const EMTLFlickrAPIResponsePhotoSecret;
extern NSString *const EMTLFlickrAPIResponsePhotoID;
extern NSString *const EMTLFlickrAPIResponsePhotoDateUpdated;
extern NSString *const EMTLFlickrAPIResponsePhotoDateTaken;
extern NSString *const EMTLFlickrAPIResponsePhotoDatePosted;
extern NSString *const EMTLFlickrAPIResponsePhotoOriginalHeight;
extern NSString *const EMTLFlickrAPIResponsePhotoOriginalWidth;
extern NSString *const EMTLFlickrAPIResponsePhotoUserID;
extern NSString *const EMTLFlickrAPIResponsePhotoUsername;
extern NSString *const EMTLFlickrAPIResponsePhotoTitle;
extern NSString *const EMTLFlickrAPIResponsePhotoDescription;
extern NSString *const EMTLFlickrAPIResponsePhotoWOEID;
extern NSString *const EMTLFlickrAPIResponsePhotoTags;
extern NSString *const EMTLFlickrAPIResponsePhotoLicense;

extern NSString *const EMTLFlickrAPIResponseFavoriteDate;
extern NSString *const EMTLFlickrAPIResponseFavoriteUserID;
extern NSString *const EMTLFlickrAPIResponseFavoriteUsername;
extern NSString *const EMTLFlickrAPIResponseFavoriteUserIconFarm;
extern NSString *const EMTLFlickrAPIResponseFavoriteUserIconServer;

extern NSString *const EMTLFlickrAPIResponseCommentDate;
extern NSString *const EMTLFlickrAPIResponseCommentUserID;
extern NSString *const EMTLFlickrAPIResponseCommentUsername;
extern NSString *const EMTLFlickrAPIResponseCommentContent;
extern NSString *const EMTLFlickrAPIResponseCommentUserIconFarm;
extern NSString *const EMTLFlickrAPIResponseCommentUserIconServer;

extern NSString *const EMTLFlickrAPIResponseUserUsername;
extern NSString *const EMTLFlickrAPIResponseUserRealname;
extern NSString *const EMTLFlickrAPIResponseUserLocation;
extern NSString *const EMTLFlickrAPIResponseUserIconFarm;
extern NSString *const EMTLFlickrAPIResponseUserIconServer;

extern NSString *const EMTLFlickrAPIResponseLocationType;



extern NSString *const EMTLFlickrAPIResponseValueStatusOK;



// Flickr Location Type Values
extern NSString *const EMTLFlickrAPIValueLocationTypeNeighborhood;
extern NSString *const EMTLFlickrAPIValueLocationTypeLocality;
extern NSString *const EMTLFlickrAPIValueLocationTypeCounty;
extern NSString *const EMTLFlickrAPIValueLocationTypeCountry;
extern NSString *const EMTLFlickrAPIValueLocationTypeUndefined;


// Flickr Photo Size Values
extern NSString *const EMTLFlickrAPIValuePhotoSizeSmallSquare;
extern NSString *const EMTLFlickrAPIValuePhotoSizeLargeSquare;
extern NSString *const EMTLFlickrAPIValuePhotoSizeThumbnail;
extern NSString *const EMTLFlickrAPIValuePhotoSizeSmaller;
extern NSString *const EMTLFlickrAPIValuePhotoSizeSmall;
extern NSString *const EMTLFlickrAPIValuePhotoSizeMediumSmall;
extern NSString *const EMTLFlickrAPIValuePhotoSizeMedium;
extern NSString *const EMTLFlickrAPIValuePhotoSizeMediumLarge;
extern NSString *const EMTLFlickrAPIValuePhotoSizeLarge;
extern NSString *const EMTLFlickrAPIValuePhotoSizeOriginal;


// Flickr URL Formats
extern NSString *const EMTLFlickrImageURLFormat;
extern NSString *const EMTLFlickrPhotoWebPageURLFormat;
extern NSString *const EMTLFlickrUserIconURLFormat;


// Flickr URLs
extern NSString *const EMTLFlickrRequestTokenURL;
extern NSString *const EMTLFlickrAuthorizationURL;
extern NSString *const EMTLFlickrAccessTokenURL;
extern NSString *const EMTLFlickrAPICallURL;
extern NSString *const EMTLFlickrDefaultsServiceProviderName;
extern NSString *const EMTLFlickrDefaultsPrefix;
extern NSString *const EMTLFlickrDefaultIconURLString;



@interface EMTLFlickrConstants : NSObject

@end

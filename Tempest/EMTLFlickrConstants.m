//
//  EMTLFlickrConstants.m
//  Tempest
//
//  Created by Ian White on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrConstants.h"

// Internal Flickr Query object's keys
NSString *const EMTLFlickrQueryTotalPages = @"flickr-total-pages";
NSString *const EMTLFlickrQueryCurrentPage = @"flickr-current-page";
NSString *const EMTLFlickrQueryMaxYear = @"flickr-max-year";
NSString *const EMTLFlickrQueryMaxMonth = @"flickr-max-month";
NSString *const EMTLFlickrQueryMaxDay = @"flickr-max-day";
NSString *const EMTLFlickrQueryMinYear = @"flickr-min-year";
NSString *const EMTLFlickrQueryMinMonth = @"flickr-min-month";
NSString *const EMTLFlickrQueryMinDay = @"flickr-min-day";
NSString *const EMTLFlickrQueryMethod = @"flickr-method";
NSString *const EMTLFlickrQueryIdentifier = @"flickr-identifier";
NSString *const EMTLFlickrQueryAPIKey = @"flickr-api-key";


// Flickr Methods for API Queries
NSString *const EMTLFlickrAPIMethodTestLogin = @"flickr.test.login";
NSString *const EMTLFlickrAPIMethodUserInfo = @"flickr.people.getInfo";
NSString *const EMTLFlickrAPIMethodSearch = @"flickr.photos.search";
NSString *const EMTLFlickrAPIMethodPopularPhotos = @"flickr.interestingness.getList";
NSString *const EMTLFlickrAPIMethodFavoritePhotos = @"flickr.favorites.getList";
NSString *const EMTLFlickrAPIMethodUserPhotos = @"flickr.people.getPhotos";
NSString *const EMTLFlickrAPIMethodPhotoFavorites = @"flickr.photos.getFavorites";
NSString *const EMTLFlickrAPIMethodPhotoComments = @"flickr.photos.comments.getList";
NSString *const EMTLFlickrAPIMethodPhotoLocation = @"flickr.places.getInfo";
NSString *const EMTLFlickrAPIMethodAddFavorite = @"flickr.favorites.add";
NSString *const EMTLFlickrAPIMethodRemoveFavorite = @"flickr.favorites.remove";


// Flickr Arguments for API Queries
NSString *const EMTLFlickrAPIArgumentUserID = @"user_id";
NSString *const EMTLFlickrAPIArgumentPhotoID = @"photo_id";
NSString *const EMTLFlickrAPIArgumentItemsPerPage = @"per_page";
NSString *const EMTLFlickrAPIArgumentPageNumber = @"page";
NSString *const EMTLFlickrAPIArgumentAPIKey = @"api_key";
NSString *const EMTLFlickrAPIArgumentContacts = @"contacts";
NSString *const EMTLFlickrAPIArgumentSort = @"sort";
NSString *const EMTLFlickrAPIArgumentExtras = @"extras";
NSString *const EMTLFlickrAPIArgumentLocation = @"woe_id";
NSString *const EMTLFlickrAPIArgumentContentType = @"content_type";
NSString *const EMTLFlickrAPIArgumentMinUploadDate = @"min_upload_date";
NSString *const EMTLFlickrAPIArgumentMaxUploadDate = @"max_upload_date";


// Flickr Values for API Queries
NSString *const EMTLFlickrAPIValueSortDatePostedDescending = @"date-posted-desc";
NSString *const EMTLFlickrAPIValueSortDatePostedAscending = @"date-posted-asc";
NSString *const EMTLFlickrAPIValueSortDateTakenDescending = @"date-taken-desc";
NSString *const EMTLFlickrAPIValueSortDateTakenAscending = @"date-taken-asc";
NSString *const EMTLFlickrAPIValueSortInterestingnessDescending = @"interestingness-desc";
NSString *const EMTLFlickrAPIValueSortInterestingnessAscending = @"interestingness-asc";

NSString *const EMTLFlickrAPIValuePhotoItemsPerPage = @"25";
NSString *const EMTLFlickrAPIValuePhotoContentTypePhotosOnly = @"1";
NSString *const EMTLFlickrAPIValuePhotoExtras = @"date_taken,date_upload,owner_name,o_dims,last_update,description,license,geo,tags,icon_server";
NSString *const EMTLFlickrAPIValuePhotoSearchContactsAll = @"all";
NSString *const EMTLFlickrAPIValuePhotoSearchContactsFriendsFamily = @"ff";

NSString *const EMTLFlickrAPIValueFavoriteItemsPerPage = @"50";


// Flickr Response Keys
NSString *const EMTLFlickrAPIResponseStatus = @"stat";
NSString *const EMTLFlickrAPIResponseListTotalNumber = @"total";
NSString *const EMTLFlickrAPIResponseListPages = @"pages";
NSString *const EMTLFlickrAPIResponseListPage = @"page";
NSString *const EMTLFlickrAPIResponsePhotoList = @"photos";
NSString *const EMTLFlickrAPIResponsePhotoListItems = @"photo";
NSString *const EMTLFlickrAPIResponseFavoritesList = @"photo";
NSString *const EMTLFlickrAPIResponseFavoritesListItems = @"person";
NSString *const EMTLFlickrAPIResponseCommentsList = @"comments";
NSString *const EMTLFlickrAPIResponseCommentsListItems = @"comment";
NSString *const EMTLFlickrAPIResponseLocation = @"place";
NSString *const EMTLFlickrAPIResponseUser = @"person";
NSString *const EMTLFlickrAPIResponseContent = @"_content";

NSString *const EMTLFlickrAPIResponsePhotoFarm = @"farm";
NSString *const EMTLFlickrAPIResponsePhotoServer = @"server";
NSString *const EMTLFlickrAPIResponsePhotoSecret = @"secret";
NSString *const EMTLFlickrAPIResponsePhotoID = @"id";
NSString *const EMTLFlickrAPIResponsePhotoDateUpdated = @"lastupdate";
NSString *const EMTLFlickrAPIResponsePhotoDateTaken = @"dateupload";
NSString *const EMTLFlickrAPIResponsePhotoDatePosted = @"datetaken";
NSString *const EMTLFlickrAPIResponsePhotoOriginalHeight = @"o_height";
NSString *const EMTLFlickrAPIResponsePhotoOriginalWidth = @"o_width";
NSString *const EMTLFlickrAPIResponsePhotoUserID = @"owner";
NSString *const EMTLFlickrAPIResponsePhotoUsername = @"ownername";
NSString *const EMTLFlickrAPIResponsePhotoTitle = @"title";
NSString *const EMTLFlickrAPIResponsePhotoDescription = @"description";
NSString *const EMTLFlickrAPIResponsePhotoWOEID = @"woeid";
NSString *const EMTLFlickrAPIResponsePhotoTags = @"tags";
NSString *const EMTLFlickrAPIResponsePhotoLicense = @"license";

NSString *const EMTLFlickrAPIResponseFavoriteDate = @"favedate";
NSString *const EMTLFlickrAPIResponseFavoriteUserID = @"nsid";
NSString *const EMTLFlickrAPIResponseFavoriteUsername = @"username";

NSString *const EMTLFlickrAPIResponseCommentDate = @"datecreate";
NSString *const EMTLFlickrAPIResponseCommentUserID = @"author";
NSString *const EMTLFlickrAPIResponseCommentUsername = @"authorname";
NSString *const EMTLFlickrAPIResponseCommentContent = @"_content";

NSString *const EMTLFlickrAPIResponseUserUsername = @"username";
NSString *const EMTLFlickrAPIResponseUserRealname = @"realname";
NSString *const EMTLFlickrAPIResponseUserLocation = @"location";
NSString *const EMTLFlickrAPIResponseUserIconFarm = @"iconfarm";
NSString *const EMTLFlickrAPIResponseUserIconServer = @"iconserver";

NSString *const EMTLFlickrAPIResponseLocationType = @"place_type";



NSString *const EMTLFlickrAPIResponseValueStatusOK = @"ok";


// Flickr Location Type Values
NSString *const EMTLFlickrAPIValueLocationTypeNeighborhood = @"neighbourhood";
NSString *const EMTLFlickrAPIValueLocationTypeLocality = @"locality";
NSString *const EMTLFlickrAPIValueLocationTypeCounty = @"county";
NSString *const EMTLFlickrAPIValueLocationTypeCountry = @"country";
NSString *const EMTLFlickrAPIValueLocationTypeUndefined = @"undefined";


// Flickr Photo Size Values
NSString *const EMTLFlickrAPIValuePhotoSizeSmallSquare = @"s";
NSString *const EMTLFlickrAPIValuePhotoSizeLargeSquare = @"q";
NSString *const EMTLFlickrAPIValuePhotoSizeThumbnail = @"t";
NSString *const EMTLFlickrAPIValuePhotoSizeSmaller = @"m";
NSString *const EMTLFlickrAPIValuePhotoSizeSmall = @"n";
NSString *const EMTLFlickrAPIValuePhotoSizeMediumSmall = @"";
NSString *const EMTLFlickrAPIValuePhotoSizeMedium = @"z";
NSString *const EMTLFlickrAPIValuePhotoSizeMediumLarge = @"c";
NSString *const EMTLFlickrAPIValuePhotoSizeLarge = @"b";
NSString *const EMTLFlickrAPIValuePhotoSizeOriginal = @"o";


// Flickr URL Formats
NSString *const EMTLFlickrImageURLFormat = @"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg";
NSString *const EMTLFlickrPhotoWebPageURLFormat = @"http://www.flickr.com/photos/%@/%@";
NSString *const EMTLFlickrUserIconURLFormat = @"http://farm%@.staticflickr.com/%@/buddyicons/%@.jpg";


// Flickr URLs
NSString *const EMTLFlickrRequestTokenURL = @"http://www.flickr.com/services/oauth/request_token";
NSString *const EMTLFlickrAuthorizationURL = @"http://www.flickr.com/services/oauth/authorize";
NSString *const EMTLFlickrAccessTokenURL = @"http://www.flickr.com/services/oauth/access_token";
NSString *const EMTLFlickrAPICallURL = @"http://api.flickr.com/services/rest";
NSString *const EMTLFlickrDefaultsServiceProviderName = @"flickr-access-token";
NSString *const EMTLFlickrDefaultsPrefix = @"com.Elemental.Flickrgram";
NSString *const EMTLFlickrDefaultIconURLString = @"http://www.flickr.com/images/buddyicon.gif";

@implementation EMTLFlickrConstants

@end

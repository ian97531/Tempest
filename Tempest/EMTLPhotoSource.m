//
//  EMTLPhotoSource.m
//  Tempest
//
//  Created by Ian White on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoSource.h"
#import "EMTLPhoto.h"

NSString *const kPhotoUsername = @"user_name";
NSString *const kPhotoUserID = @"user_id";
NSString *const kPhotoTitle = @"photo_title";
NSString *const kPhotoID = @"photo_id";
NSString *const kPhotoImageURL = @"image_url";
NSString *const kPhotoImageAspectRatio = @"aspect_ratio";
NSString *const kPhotoDatePosted = @"date_posted";
NSString *const kPhotoDateUpdated = @"date_updated";
NSString *const kPhotoComments = @"comments_domain";
NSString *const kPhotoFavorites = @"favorites_domain";

NSString *const kCommentText = @"comment_text";
NSString *const kCommentDate = @"comment_date";
NSString *const kCommentUsername = @"user_name";
NSString *const kCommentUserID = @"user_id";
NSString *const kCommentIconURL = @"icon_url";

NSString *const kFavoriteDate = @"favorite_date";
NSString *const kFavoriteUsername = @"user_name";
NSString *const kFavoriteUserID = @"user_id";
NSString *const kFavoriteIconURL = @"icon_url";

@implementation EMTLPhotoSource

@synthesize delegate;
@synthesize accountManager;

@synthesize userID;
@synthesize username;
@synthesize photoList;

- (id)init
{
    self = [super init];
    if (self) {
        imageCache = [[NSCache alloc] init];
        operationQueue = [[NSOperationQueue alloc] init];
        
        [self initializeDiskCache];
        
    }
    
    return self;
}



#pragma mark - Disk Caching
- (void)initializeDiskCache
{
    NSLog(@"Initializng the on-disk cache for %@", self.serviceName);
    
    // Locate the disk cache.
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                            NSUserDomainMask, YES);
    
    diskCachePath = [NSString stringWithFormat:@"%@/%@-cache", [dirPaths objectAtIndex:0], self.serviceName];
    NSLog(@"On-disk cache path for %@: %@", self.serviceName, diskCachePath);
    
    // Make sure it exists, if not, create it.
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath isDirectory:&isDirectory]) {
        NSLog(@"Creating new on-disk cache for %@", self.serviceName);
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if(error) {
            NSLog(@"There was an error setting up the on-disk cache for %@, proceeding without a disk cache.", self.serviceName);
            NSLog(@"Error: %@", [error localizedDescription]);
            diskCachePath = nil;
        }
    }
    // If we were able to find a previously existing cache, load it's contents into memory.
    [self loadFromDisk];
}


- (void)loadFromDisk
{
    NSLog(@"Loading cache from disk");
    
    // Get an enumerator for the files in the on-disk cache
    NSURL *cachePath = [[NSURL alloc] initFileURLWithPath:diskCachePath];
    NSArray *enumeratorKeys = [NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, NSURLCreationDateKey, nil];
    NSDirectoryEnumerator *cacheEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:cachePath 
                                                                  includingPropertiesForKeys:enumeratorKeys 
                                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles 
                                                                                errorHandler:^(NSURL *url, NSError *error) {
                                                                                    NSLog(@"error with url: %@", url.absoluteString);
                                                                                    return YES;
                                                                                }];
    
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:[self numberOfPhotosToCacheOnDisk]];
    NSString *currentPhotoID;
    NSURL *url;

    while (url = [cacheEnumerator nextObject]) {
        NSError *error;
        NSNumber *isDirectory;
        BOOL directoryReturned = [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error];
        
        if (!directoryReturned) {
            NSLog(@"Error while reading %@ from the on-disk cache for %@", [url absoluteString], self.serviceName);
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else if([isDirectory boolValue]) {
            currentPhotoID = [url lastPathComponent];
        }
        else if (! [isDirectory boolValue]) {
            NSString *fileName = [url lastPathComponent];
            if([fileName isEqualToString:@"image.jpg"]) {
                UIImage *image = [UIImage imageWithContentsOfFile:url.path];
                [imageCache setValue:image forKey:currentPhotoID];
            }
            else if([fileName isEqualToString:@"photo.plist"]) {
                EMTLPhoto *photo = [EMTLPhoto photoWithDict:[NSDictionary dictionaryWithContentsOfFile:url.path]];
                [photos addObject:photo];
            }
        }
        
    }
    
    // Sort the photos by date, newest photos first, oldest photos last
    [photos sortUsingComparator:^(EMTLPhoto *photo1, EMTLPhoto *photo2){
        return [photo2.datePosted compare:photo1.datePosted];
    }];
    
    
    photoList = photos;

}



- (int)numberOfPhotosToCacheOnDisk
{
    return 50;
}




- (NSString *)serviceName
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override EMTLPhotoSource's %@ method in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


#pragma mark - Service Authorization methods

- (void)authorize
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override EMTLPhotoSource's %@ method in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


- (void)authorizedWithVerifier:(NSString *)verfier
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override EMTLPhotoSource's %@ method in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];}




# pragma mark - Photo Retrieval methods

- (void)updateNewestPhotos
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override EMTLPhotoSource's %@ method in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];}


- (void)retrieveOlderPhotos
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override EMTLPhotoSource's %@ method in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}




@end

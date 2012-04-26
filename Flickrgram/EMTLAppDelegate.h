//
//  EMTLAppDelegate.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMTLPhotoSource.h"

@class EMTLPhotoListViewController;

@interface EMTLAppDelegate : UIResponder <UIApplicationDelegate, Authorizable>


@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSMutableDictionary *photoSources;
@property (strong) NSLock *queueLock;
@property (nonatomic, strong) NSMutableArray *authorizationQueue;
@property (nonatomic, strong) NSMutableArray *authorizedSources;
@property (nonatomic, strong) NSMutableArray *disabledSources;

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) EMTLPhotoListViewController *feed;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)initializePhotoSources;

// Authorizable Methods
- (void)photoSource:(id <PhotoSource>)photoSource requiresAuthorizationAtURL:(NSURL *)url;
- (void)authorizationCompleteForPhotoSource:(id <PhotoSource>)photoSource;
- (void)authorizationErrorForPhotoSource:(id <PhotoSource>)photoSource;

@end

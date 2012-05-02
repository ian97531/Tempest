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

@interface EMTLAppDelegate : UIResponder <UIApplicationDelegate, EMTLAccountManager>


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSMutableDictionary *photoSources;
@property (strong) NSLock *queueLock;
@property (nonatomic, strong) NSMutableArray *authorizationQueue;
@property (nonatomic, strong) NSMutableArray *authorizedSources;
@property (nonatomic, strong) NSMutableArray *disabledSources;

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) EMTLPhotoListViewController *feed;

- (NSURL *)applicationDocumentsDirectory;

- (void)initializePhotoSources;

// Authorizable Methods
- (void)photoSource:(EMTLPhotoSource *)photoSource requiresAuthorizationAtURL:(NSURL *)url;
- (void)authorizationCompleteForPhotoSource:(EMTLPhotoSource *)photoSource;
- (void)authorizationErrorForPhotoSource:(EMTLPhotoSource *)photoSource;

@end

//
//  EMTLAppDelegate.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLAppDelegate.h"
#import "EMTLPhotoListViewController.h"
#import "EMTLFlickr.h"

@implementation EMTLAppDelegate

@synthesize navController;
@synthesize feed;

@synthesize photoSources;
@synthesize authorizedSources;
@synthesize authorizationQueue;
@synthesize queueLock;
@synthesize disabledSources;

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    
    feed = [[EMTLPhotoListViewController alloc] init];
    navController = [[UINavigationController alloc] initWithRootViewController:feed];
    navController.navigationBar.hidden = YES;
    
    
    self.window.rootViewController = navController;    
    [self.window makeKeyAndVisible];
    
    self.photoSources = [[NSMutableDictionary alloc] initWithCapacity:4];
    self.authorizationQueue = [[NSMutableArray alloc] initWithCapacity:4];
    self.queueLock = [[NSLock alloc] init];
    self.authorizedSources = [[NSMutableArray alloc] initWithCapacity:4];
    self.disabledSources = [[NSMutableArray alloc] initWithCapacity:1];
    
    [self initializePhotoSources];
    
//    for (NSString *name in [UIFont familyNames]) {
//        NSLog(@"Family name : %@", name);
//        for (NSString *font in [UIFont fontNamesForFamilyName:name]) {
//            NSLog(@"Font name : %@", font);             
//        }
//    }
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"the app caught the URL");
    
	if ([[url scheme] isEqualToString:@"flickrgram"]) {
        NSLog(@"we got the callback");
        if ([[url path] isEqualToString:@"/verify-auth"]) {
            NSLog(@"It's a verify auth URL");
            
            NSDictionary *queryParts = [self convertQueryToDict:[url query]];
            EMTLPhotoSource *source = [self.photoSources objectForKey:[url host]];
            
            [source authorizedWithVerifier:[queryParts objectForKey:@"oauth_verifier"]];
            
            [navController dismissModalViewControllerAnimated:YES];
            
            if (authorizationQueue.count) {
                [self showAuthorizationPanelForURL:[authorizationQueue objectAtIndex:0]];
                [authorizationQueue removeObjectAtIndex:0];
            }
            else {
                [queueLock unlock];
            }
            
        }
        
        
        
        
		//in here you do whatever you need the app to do
		// e.g decode JSON string from base64 to plain text & parse JSON string
	}
    return YES; //if everything went well
}

- (NSDictionary *)convertQueryToDict:(NSString *)query {
    
    NSArray *parts = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *returnValue = [[NSMutableDictionary alloc] initWithCapacity:parts.count];
    
    for (NSString *part in parts) {
        NSArray *keyValue = [part componentsSeparatedByString:@"="];
        [returnValue setObject:[keyValue lastObject] forKey:[keyValue objectAtIndex:0]];
    }
    
    return [NSDictionary dictionaryWithDictionary:returnValue];
}

- (void)initializePhotoSources
{
    
    // Grab the enabled sources from defaults, and ask each to authorize.
    
    EMTLFlickr *flickr = [[EMTLFlickr alloc] init];
    [self.photoSources setObject:flickr forKey:flickr.serviceName];
    
    flickr.accountManager = self;
    //[flickr authorize];
    
}

- (void)authorizationErrorForPhotoSource:(EMTLPhotoSource *)photoSource;
{
    NSLog(@"authorization error for %@", photoSource.serviceName);
}

- (void)photoSource:(EMTLPhotoSource *)photoSource requiresAuthorizationAtURL:(NSURL *)url
{
    if ([queueLock tryLock]) {
        NSLog(@"authorization requred for %@", photoSource.serviceName);
        [self showAuthorizationPanelForURL:url];
        
    }
    else {
        [authorizationQueue addObject:url];
    }
   
}

- (void)showAuthorizationPanelForURL:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIWebView *authorizationPanel = [[UIWebView alloc] init];
    [authorizationPanel loadRequest:request];
    
    UIViewController *webController = [[UIViewController alloc] init];
    webController.view = authorizationPanel;
    
    [navController presentModalViewController:webController animated:YES];
}

- (void)authorizationCompleteForPhotoSource:(EMTLPhotoSource *)photoSource;
{
    NSLog(@"authorization complete for %@. user:%@, id: %@", photoSource.serviceName, photoSource.username, photoSource.userID);
    //[feed addSource:photoSource];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}




#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

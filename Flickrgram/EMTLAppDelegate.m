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
@synthesize disabledSources;

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    feed = [[EMTLPhotoListViewController alloc] init];
    navController = [[UINavigationController alloc] initWithRootViewController:feed];
    self.window.rootViewController = navController;    
    [self.window makeKeyAndVisible];
    
    authorizationWebViewOpened = NO;
    
    self.photoSources = [[NSMutableDictionary alloc] initWithCapacity:4];
    self.authorizationQueue = [[NSMutableArray alloc] initWithCapacity:4];
    self.authorizedSources = [[NSMutableArray alloc] initWithCapacity:4];
    self.disabledSources = [[NSMutableArray alloc] initWithCapacity:1];
    
    [self initializePhotoSources];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"the app caught the URL");
    
	if ([[url scheme] isEqualToString:@"flickrgram"]) {
        NSLog(@"we got the callback");
        if ([[url path] isEqualToString:@"/verify-auth"]) {
            NSLog(@"It's a verify auth URL");
            
            NSDictionary *queryParts = [self convertQueryToDict:[url query]];
            id <PhotoSource> source = [self.photoSources objectForKey:[url host]];
            
            [source authorizedWithVerifier:[queryParts objectForKey:@"oauth_verifier"]];
            
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
    [self.photoSources setObject:flickr forKey:[flickr key]];
    
    flickr.delegate = self;
    [flickr authorize];
    
}

- (void)photoSource:(id <PhotoSource>)photoSource authorizationError:(NSError *)error
{
    NSLog(@"authorization error for %@", photoSource.key);
}

- (void)photoSource:(id <PhotoSource>)photoSource requiresAuthorizationAtURL:(NSURL *)url
{
    NSLog(@"authorization requred for %@", photoSource.key);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIWebView *authorizationPanel = [[UIWebView alloc] init];
    [authorizationPanel loadRequest:request];
    
    UIViewController *webController = [[UIViewController alloc] init];
    webController.view = authorizationPanel;
    
    [navController presentModalViewController:webController animated:YES];
}

- (void)authorizationCompleteForSource:(id <PhotoSource>)photoSource
{
    NSLog(@"authorization complete for %@", photoSource.key);
    [feed addSource:photoSource];
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

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Flickrgram" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Flickrgram.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

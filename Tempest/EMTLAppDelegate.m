//
//  EMTLAppDelegate.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLAppDelegate.h"
#import "EMTLTimelineViewController.h"
#import "EMTLFlickrPhotoSource.h"

@interface EMTLAppDelegate ()
@property (nonatomic, strong) NSMutableDictionary *photoSources;
@property (strong) NSLock *queueLock;
@property (nonatomic, strong) NSMutableArray *authorizationQueue;
@property (nonatomic, strong) NSMutableArray *authorizedSources;
@property (nonatomic, strong) NSMutableArray *disabledSources;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) EMTLPhotoListViewController *timelineViewController;

- (NSDictionary *)_convertQueryToDict:(NSString *)query;
@end

@implementation EMTLAppDelegate

@synthesize navController;
@synthesize timelineViewController;

@synthesize photoSources;
@synthesize authorizedSources;
@synthesize authorizationQueue;
@synthesize queueLock;
@synthesize disabledSources;

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    for (NSString *name in [UIFont familyNames]) {
//        NSLog(@"Family name : %@", name);
//        for (NSString *font in [UIFont fontNamesForFamilyName:name]) {
//            NSLog(@"Font name : %@", font);             
//        }
//    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]];
    self.navController.navigationBar.hidden = YES;

    self.window.rootViewController = self.navController;    
    [self.window makeKeyAndVisible];
    
    self.photoSources = [[NSMutableDictionary alloc] initWithCapacity:4];
    self.authorizationQueue = [[NSMutableArray alloc] initWithCapacity:4];
    self.queueLock = [[NSLock alloc] init];
    self.authorizedSources = [[NSMutableArray alloc] initWithCapacity:4];
    self.disabledSources = [[NSMutableArray alloc] initWithCapacity:1];
    
    [self _initializePhotoSources];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"the app caught the URL");
    
	if ([[url scheme] isEqualToString:@"flickrgram"])
    {
        NSLog(@"we got the callback");
        if ([[url path] isEqualToString:@"/verify-auth"])
        {
            NSLog(@"It's a verify auth URL");
            
            NSDictionary *queryParts = [self _convertQueryToDict:[url query]];
            EMTLPhotoSource *source = [self.photoSources objectForKey:[url host]];
            
            [source authorizedWithVerifier:[queryParts objectForKey:@"oauth_verifier"]];
            
            [self.navController dismissModalViewControllerAnimated:YES];
            
            if (authorizationQueue.count)
            {
                [self _showAuthorizationPanelForURL:[authorizationQueue objectAtIndex:0]];
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

}

#pragma mark -
#pragma mark EMTLPhotoSourceAuthorizationDelegate

- (void)_showAuthorizationPanelForURL:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIWebView *authorizationPanel = [[UIWebView alloc] init];
    [authorizationPanel loadRequest:request];
    
    UIViewController *webController = [[UIViewController alloc] init];
    webController.view = authorizationPanel;
    
    [self.navController presentModalViewController:webController animated:YES];
}

- (void)photoSource:(EMTLPhotoSource *)photoSource requiresAuthorizationAtURL:(NSURL *)url
{
    if ([queueLock tryLock])
    {
        NSLog(@"authorization requred for %@", photoSource.serviceName);
        [self _showAuthorizationPanelForURL:url];
        
    }
    else
    {
        [authorizationQueue addObject:url];
    }
}

- (void)authorizationCompleteForPhotoSource:(EMTLPhotoSource *)photoSource
{
    NSLog(@"authorization complete for %@.", photoSource.serviceName);

    self.timelineViewController = [[EMTLTimelineViewController alloc] initWithPhotoQuery:[photoSource currentPhotos]];
    [self.navController pushViewController:self.timelineViewController animated:NO];
}

- (void)authorizationFailedForPhotoSource:(EMTLPhotoSource *)photoSource authorizationError:(NSError *)error
{
    // TODO (BSEELY): We need to decide what's the sensible thing to do here. What are the possible failure cases and how to handle each one.
    NSLog(@"authorization error for %@", photoSource.serviceName);
}


#pragma mark -
#pragma mark Private

- (NSDictionary *)_convertQueryToDict:(NSString *)query
{
    NSArray *parts = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *returnValue = [[NSMutableDictionary alloc] initWithCapacity:parts.count];
    
    for (NSString *part in parts)
    {
        NSArray *keyValue = [part componentsSeparatedByString:@"="];
        [returnValue setObject:[keyValue lastObject] forKey:[keyValue objectAtIndex:0]];
    }
    
    return [NSDictionary dictionaryWithDictionary:returnValue];
}


- (void)_initializePhotoSources
{
    // Grab the enabled sources from defaults, and ask each to authorize.    
    EMTLFlickrPhotoSource *flickr = [[EMTLFlickrPhotoSource alloc] init];
    [self.photoSources setObject:flickr forKey:flickr.serviceName];
    
    flickr.authorizationDelegate = self;
    
    // TODO (BSEELY): Ideally this goes somewhere else - since we only use Flickr at this point, it's fine here for now.
    [flickr authorize];
}


@end

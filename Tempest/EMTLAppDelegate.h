//
//  EMTLAppDelegate.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMTLPhotoSource.h"

@interface EMTLAppDelegate : UIResponder <UIApplicationDelegate, EMTLPhotoSourceAuthorizationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

//
//  EMTLPhotoListViewController.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMTLPhotoListViewController.h"

@interface EMTLTimelineViewController : EMTLPhotoListViewController
{
    UIScrollView *_titleView;
    UIView *_tableHeaderView;
    
    UITextField *_instructions;
    UITextField *_loadingText;
    UIActivityIndicatorView *_loadingIndicator;

    BOOL resizeHeader;
}





@end

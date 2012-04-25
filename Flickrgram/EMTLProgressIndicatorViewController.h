//
//  EMTLProgressIndicatorViewController.h
//  Flickrgram
//
//  Created by Ian White on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSmallProgressIndicator,
    kLargeProgressIndicator,
} EMTLProgressIndicatorSize;

@interface EMTLProgressIndicatorViewController : UIViewController
{
    NSArray *frames;
    EMTLProgressIndicatorSize size;
    BOOL spinner;
    UIImageView *indicator;
    UILabel *percentage;
    int currentFrame;
    NSTimer *spinTimer;
    
    
}

@property (nonatomic) float value;
//@property (nonatomic, strong) UILabel *title;

+ (id)indicatorWithSize:(EMTLProgressIndicatorSize)size;

- (id)initWithSize:(EMTLProgressIndicatorSize)size;
- (void)spin;
- (void)spinAtRate:(int)rate;
- (void)stop;
- (void)nextSpinState;
- (void)resetValue;
- (void)availableForReuse;

//- (void)showPercentage;

@end

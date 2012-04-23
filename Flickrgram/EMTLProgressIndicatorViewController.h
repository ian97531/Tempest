//
//  EMTLProgressIndicatorViewController.h
//  Flickrgram
//
//  Created by Ian White on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EMTLProgressIndicatorViewController : UIViewController
{
    NSArray *frames;
    BOOL size;
    BOOL spinner;
    UIImageView *indicator;
    UILabel *percentage;
    int currentFrame;
    NSTimer *spinTimer;
    
    
}

@property (nonatomic) float value;
//@property (nonatomic, strong) UILabel *title;

- (id)initWithSmallSize:(BOOL)smallSize;
- (void)spin;
- (void)spinAtRate:(int)rate;
- (void)stop;
- (void)nextSpinState;
- (void)resetValue;

//- (void)showPercentage;

@end

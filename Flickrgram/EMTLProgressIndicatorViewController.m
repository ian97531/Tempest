//
//  EMTLProgressIndicatorViewController.m
//  Flickrgram
//
//  Created by Ian White on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLProgressIndicatorViewController.h"



@interface EMTLProgressIndicatorViewController ()

@end

@implementation EMTLProgressIndicatorViewController

@synthesize value;
//@synthesize title;


static NSMutableArray *availableSmallIndicators;
static NSMutableArray *usedSmallIndicators;
static NSArray *smallFrames;
static NSArray *largeFrames;

+ (id)indicatorWithSize:(EMTLProgressIndicatorSize)size
{
    
    EMTLProgressIndicatorViewController *indicator;
    
    if (!availableSmallIndicators) {
        availableSmallIndicators = [NSMutableArray arrayWithCapacity:4];
        usedSmallIndicators = [NSMutableArray arrayWithCapacity:4];
    }
    
    if (!smallFrames) {
        NSMutableArray *theFrames = [NSMutableArray arrayWithCapacity:16];
        
        for (int i = 0; i < 16; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%i.png", @"Small", i]];
            [theFrames addObject:image];
        }
        
        smallFrames = [NSArray arrayWithArray:theFrames];
        
    }
    
    if (!largeFrames) {
        NSMutableArray *theFrames = [NSMutableArray arrayWithCapacity:16];
        
        for (int i = 0; i < 16; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%i.png", @"Large", i]];
            [theFrames addObject:image];
        }
        
        largeFrames = [NSArray arrayWithArray:theFrames];
        
    }
    
    if (size == kSmallProgressIndicator) {
        
        @synchronized(availableSmallIndicators) {
            if(availableSmallIndicators.count) {
                indicator = [availableSmallIndicators lastObject];
                [availableSmallIndicators removeLastObject];
            }
            else {
                indicator = [[EMTLProgressIndicatorViewController alloc] initWithSize:kSmallProgressIndicator];
            }
            
        }
        
        return indicator;
        
    }
    else {
        
        return [[EMTLProgressIndicatorViewController alloc] initWithSize:kLargeProgressIndicator];
    }
    
}


- (id)initWithSize:(EMTLProgressIndicatorSize)theSize
{
    self = [super init];
    if (self) {
                
        value = 0;
        currentFrame = 0;
        size = theSize;
        frames = (theSize == kSmallProgressIndicator) ? smallFrames : largeFrames;
    }
    return self;
}

- (void)spin
{
    [self spinAtRate:4];
}

- (void)spinAtRate:(int)rate
{
    if(!spinTimer) {
        spinTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/(float)rate) 
                                                     target:self 
                                                   selector:@selector(nextSpinState) 
                                                   userInfo:nil 
                                                    repeats:YES];
        
    }
    
}

- (void)stop
{
    [spinTimer invalidate];
    spinTimer = nil;
    self.value = 0;
}

- (void)nextSpinState
{
    currentFrame++;
    indicator.image = [frames objectAtIndex:(currentFrame % 15)];
}

- (void)loadView
{
    
    CGRect theFrame = (size == kSmallProgressIndicator) ? CGRectMake(0, 0, 100, 100) : CGRectMake(0, 0, 150, 150);
    UIView *parentView = [[UIView alloc] initWithFrame:theFrame];
    
    indicator = [[UIImageView alloc] initWithImage:[frames objectAtIndex:0]];
    
    [parentView addSubview:indicator];

    self.view = parentView;
    
}

- (void)setValue:(float)theValue
{
    
    if (theValue > 100) {
        value = 100;
    }
    else if (theValue > value) {
        value = theValue;
    }
    else {
        return;
    }
    int nextImage = (value) ? (int)floor((value/100.0) * 8.0) : 0;
    if (nextImage != currentFrame) {
        indicator.image = [frames objectAtIndex:nextImage];
        currentFrame = nextImage;
    }
    
}

- (void)resetValue
{
    value = 0;
    indicator.image = [frames objectAtIndex:0];
    currentFrame = 0;
}

- (void)availableForReuse
{
    [self.view removeFromSuperview];
    [self resetValue];
    
    if (size == kSmallProgressIndicator) {
        [availableSmallIndicators insertObject:self atIndex:0];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

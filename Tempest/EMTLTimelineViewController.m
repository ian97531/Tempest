//
//  EMTLPhotoListViewController.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLTimelineViewController.h"
#import "EMTLPhotoCell.h"
#import "EMTLPhoto.h"
#import "EMTLLocation.h"
#import "EMTLUser.h"
#import "EMTLMagicUserList.h"

#import "Math.h"

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@implementation EMTLTimelineViewController


- (id)initWithPhotoQuery:(EMTLPhotoQuery *)query;
{
    self = [super initWithPhotoQuery:query];
    if (self != nil)
    {
        resizeHeader = YES;

    }
    
    return self;
}


// Load our special header.
- (void)loadView
{
    
    [super loadView];
    
    _titleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    _titleView.contentSize = CGSizeMake(320, 165);
    _titleView.bounces = NO;
    _titleView.scrollEnabled = NO;
    _titleView.showsHorizontalScrollIndicator = NO;
    _titleView.showsVerticalScrollIndicator = NO;
    _titleView.userInteractionEnabled = NO;
    
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LabelTempest5.png"]];
    headerImage.frame = CGRectMake(0, 0, 320, 82.5);
    [_titleView addSubview:headerImage];
    
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    _instructions = [[UITextField alloc] initWithFrame:CGRectMake(0, 50, 320, 40)];
    _instructions.text = @"Pull to Refresh...";
    _instructions.textAlignment = UITextAlignmentCenter;
    _instructions.font = [UIFont fontWithName:@"MarkerSD" size:18];
    _instructions.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    
    _loadingText = [[UITextField alloc] initWithFrame:CGRectMake(30, 50, 290, 40)];
    _loadingText.text = @"Loading new Photos...";
    _loadingText.textAlignment = UITextAlignmentCenter;
    _loadingText.font = [UIFont fontWithName:@"MarkerSD" size:18];
    _loadingText.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingIndicator.hidesWhenStopped = YES;
    _loadingIndicator.frame = CGRectMake(60, 45, _loadingIndicator.frame.size.width, _loadingIndicator.frame.size.height);
    [_tableHeaderView addSubview:_loadingIndicator];

    
    [_tableHeaderView addSubview:_instructions];
    
    
//    _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_reloadButton setImage:[UIImage imageNamed:@"Reload.png"] forState:UIControlStateNormal];
//    _reloadButton.frame = CGRectMake(238, 72, 35, 35);
//    _reloadButton.alpha = 0.8;
//    [_reloadButton addTarget:self action:@selector(reloadQuery) forControlEvents:UIControlEventTouchUpInside];
    
    _tableView.tableHeaderView = _tableHeaderView;
    
    [_parent addSubview:_titleView];
    
}

- (void)photoQueryFinishedUpdating:(EMTLPhotoQuery *)query
{
    
    [self hideReloading];
    [super photoQueryFinishedUpdating:query];
}

- (void)photoQueryWillUpdate:(EMTLPhotoQuery *)query
{
    [self displayReloading];
    [super photoQueryWillUpdate:query];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"offset %f", scrollView.contentOffset.y);
    
    if (scrollView == _tableView) {
        if (_tableView.contentOffset.y > 0 && _tableView.contentOffset.y < _titleView.frame.size.height) {
            if (!_titleView.superview) {
                [_parent addSubview:_titleView];
            }
            _titleView.contentOffset = _tableView.contentOffset;
        }
        
        else if (_tableView.contentOffset.y <= 0) {
            if (!_titleView.superview) {
                [_parent addSubview:_titleView];
            }
            
            _titleView.contentOffset = CGPointMake(0, 0);
            
        }
        else if (_titleView.superview && _tableView.contentOffset.y >= _titleView.frame.size.height) {
            _titleView.contentOffset = CGPointMake(0, 100);
            [_titleView removeFromSuperview];
        }
    }
    
    if (_tableView.contentOffset.y <= -70 && !_isReloading && _tableView.tracking) {
        NSLog(@"reloading");
        [self reloadQuery];
        
    }


    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
	if (_tableView.contentOffset.y <= - 70.0f && resizeHeader) {
        //[self displayReloading];
		
	}
}


- (void)displayReloading
{
    NSLog(@"displayReloading");
    if (resizeHeader) {
        NSLog(@"showing header");
        resizeHeader = NO;
        [UIView beginAnimations:@"loading-indication-animation" context:NULL];
        [UIView setAnimationDuration:0.2];
        _tableView.contentInset = UIEdgeInsetsMake(50.0f, 0.0f, 0.0f, 0.0f);
        if (_tableView.contentOffset.y < 50 && _tableView.contentOffset.y >= 0) {
            _tableView.contentOffset = CGPointMake(0, _tableView.contentOffset.y - 50);
        }
        [UIView commitAnimations];
    }

    [_instructions removeFromSuperview];
    [_tableHeaderView addSubview:_loadingText];
    [_loadingIndicator startAnimating];
}

- (void)hideReloading
{
    NSLog(@"hideReloading");
    if (!resizeHeader) {
        NSLog(@"hiding header");
        resizeHeader = YES;
        [UIView beginAnimations:@"loading-indication-animation" context:NULL];
        [UIView setAnimationDuration:0.2];
        _tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }
    
    [_loadingText removeFromSuperview];
    [_tableHeaderView addSubview:_instructions];
    [_loadingIndicator stopAnimating];
    
    
}









@end

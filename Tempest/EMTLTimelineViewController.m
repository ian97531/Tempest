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
        

    }
    
    return self;
}


// Load our special header.
- (void)loadView
{
    
    [super loadView];
    
    _tableHeaderView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    _tableHeaderView.contentSize = CGSizeMake(320, 165);
    _tableHeaderView.bounces = NO;
    _tableHeaderView.scrollEnabled = NO;
    _tableHeaderView.showsHorizontalScrollIndicator = NO;
    _tableHeaderView.showsVerticalScrollIndicator = NO;
    
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LabelTempest5.png"]];
    headerImage.frame = CGRectMake(0, 0, 320, 82.5);
    [_tableHeaderView addSubview:headerImage];
    
//    _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_reloadButton setImage:[UIImage imageNamed:@"Reload.png"] forState:UIControlStateNormal];
//    _reloadButton.frame = CGRectMake(238, 72, 35, 35);
//    _reloadButton.alpha = 0.8;
//    [_reloadButton addTarget:self action:@selector(reloadQuery) forControlEvents:UIControlEventTouchUpInside];
    
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    
    [_parent addSubview:_tableHeaderView];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView == _tableView) {
        if (_tableView.contentOffset.y > 0 && _tableView.contentOffset.y < _tableHeaderView.frame.size.height) {
            if (!_tableHeaderView.superview) {
                [_parent addSubview:_tableHeaderView];
            }
            _tableHeaderView.contentOffset = _tableView.contentOffset;
        }
        
        else if (_tableView.contentOffset.y <= 0) {
            if (!_tableHeaderView.superview) {
                [_parent addSubview:_tableHeaderView];
            }
            
            _tableHeaderView.contentOffset = CGPointMake(0, 0);
        }
        else if (_tableHeaderView.superview && _tableView.contentOffset.y >= _tableHeaderView.frame.size.height) {
            _tableHeaderView.contentOffset = CGPointMake(0, 100);
            [_tableHeaderView removeFromSuperview];
        }
    }

    
    
}












@end

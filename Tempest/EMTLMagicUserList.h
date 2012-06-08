//
//  EMTLMagicUserList.h
//  Tempest
//
//  Created by Ian White on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@class EMTLUser;
@class EMTLMagicUserList;

@protocol EMTLMagicUserListDelegate <NSObject>

- (void) userList:(EMTLMagicUserList *)list didTapUser:(EMTLUser *)user;
- (void) userListDidTapRemainderItem:(EMTLMagicUserList *)list;
- (void) userList:(EMTLMagicUserList *)list didLongPressUser:(EMTLUser *)user;

@end

@interface EMTLMagicUserList : UIView
{
    NSArray *_users;
    EMTLUser *_signedInUser;;
    
    UIFont *_font;
    UIColor *_color;
    
    CTFontRef _ct_font;
    CGColorRef _cg_color;
    
    NSString *_prefixString;
    NSString *_emptyString;
    NSString *_numericSuffix;
    NSString *_singularNumericSuffix;
    
    BOOL _regenerateStringNeeded;
    
    NSMutableAttributedString *_attributedString;
    NSMutableDictionary *_tappableAreas;
    NSValue *_allUsersTappableArea;
    NSMutableArray *_underlinedRanges;

    id<EMTLMagicUserListDelegate> _delegate;
    
    NSString *_photoID;
}

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) EMTLUser *signedInUser;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *empty;
@property (nonatomic, strong) NSString *numericSuffix;
@property (nonatomic, strong) NSString *singularNumericSuffix;
@property (nonatomic, strong) UIColor *highlightSelectableRangesWithColor;
@property (nonatomic) BOOL underlineSelectableRanges;
@property (nonatomic) BOOL boldSelectableRanges;

@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, assign) id<EMTLMagicUserListDelegate> delegate;

- (id)initWithFrame:(CGRect)frame emtpyString:(NSString *)emptyString;

@end

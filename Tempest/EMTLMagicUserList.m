//
//  EMTLMagicUserList.m
//  Tempest
//
//  Created by Ian White on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLMagicUserList.h"
#import "EMTLUser.h"

#import <CoreText/CoreText.h>

@interface EMTLMagicUserList ()

- (void)_regenerateString;
- (NSValue *)_areaForNewString:(NSString *)new onString:(NSString *)old;

@end


@implementation EMTLMagicUserList

@synthesize users = _users;
@synthesize signedInUser = _signedInUser;
@synthesize font = _font;
@synthesize textColor = _color;
@synthesize prefix = _prefixString;
@synthesize empty = _emptyString;
@synthesize numericSuffix = _numericSuffix;
@synthesize singularNumericSuffix = _singularNumericSuffix;
@synthesize photoID = _photoID;

- (id)initWithFrame:(CGRect)frame emtpyString:(NSString *)emptyString
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _users = [NSArray array];
        self.font = [UIFont systemFontOfSize:12];
        self.textColor = [UIColor blackColor];
        _emptyString = emptyString;
        _prefixString = @"";
        _tappableAreas = [NSMutableDictionary dictionary];
        _allUsersTappableArea = nil;
        _underlinedRanges = [NSMutableArray array];
        
        [self _regenerateString];
        self.backgroundColor = [UIColor clearColor];
    
    }
    return self;
}




- (void)drawRect:(CGRect)rect
{
    if (_regenerateStringNeeded) [self _regenerateString];
    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    // Set the attributes
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)_ct_font, kCTFontAttributeName,
                                (__bridge id)_cg_color, kCTForegroundColorAttributeName,
                                nil];
    
    [_attributedString setAttributes:attributes range:NSMakeRange(0, [_attributedString length])];
    
    // Draw the string
    CFAttributedStringRef cf_attributedString = (__bridge CFAttributedStringRef)_attributedString;
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(cf_attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [_attributedString length]), path, NULL);
    
    CTFrameDraw(frame, context);
    
    // Cleanup
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
}


- (void)setUsers:(NSArray *)users
{
    if (_users == users) return;
    
    _users = users;
    _regenerateStringNeeded = YES;
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    
    CFStringRef _fontNameRef = (__bridge CFStringRef)_font.fontName;
    _ct_font =  CTFontCreateWithName(_fontNameRef, font.pointSize, NULL);
    _regenerateStringNeeded = YES;
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    _color = textColor;
    _cg_color = _color.CGColor;
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _regenerateStringNeeded = YES;
    [self setNeedsDisplay];
}


- (void)_regenerateString
{
    
    NSLog(@"regenerating the string");
    if (!_users.count) {
        
        _attributedString = [[NSMutableAttributedString alloc] initWithString:_emptyString];
        
        _regenerateStringNeeded = NO;
        return;
    }
    
    if([_photoID isEqualToString:@"7160024905"])
    {
        NSLog(@"stop here");
    }
    
    
    if(_users.count == 1) {
        EMTLUser *user = [_users objectAtIndex:0];
        NSString *name = (user == _signedInUser) ? @"you" : user.username;
        NSString *likeString = [NSString stringWithFormat:@"%@ %@",_prefixString, name];
        [_tappableAreas setObject:user forKey:[self _areaForNewString:name onString:_prefixString]];
        
        _attributedString = [[NSMutableAttributedString alloc] initWithString:likeString];
        
        _regenerateStringNeeded = NO;
        return;
        
    }
    else if (_users.count > 1){
        
        int availableWidth = self.frame.size.width - [_prefixString sizeWithFont:_font].width;
        
        // The width cost of creating the comma delimited list
        int commaSize = [@", " sizeWithFont:_font].width;
        
        NSMutableArray * usedUsers = [NSMutableArray array];
        for (int i = 0; i < _users.count; i++) {
            // Get the width for the user
            EMTLUser *user = [_users objectAtIndex:i];
            NSString *name = (user == _signedInUser) ? @"you" : user.username;
            
            int userSize = [name sizeWithFont:_font].width;
            availableWidth = availableWidth - userSize;
            
            // Unless this is the last user, we need to tack on the comma width.
            if (i < _users.count - 1) 
            {
                availableWidth = availableWidth - commaSize;
            }
            
            // If we've busted the avaialableWidth bank, stop
            if (availableWidth <= 0) {
                availableWidth = availableWidth + userSize;
                if (i < _users.count - 1) {
                    availableWidth = availableWidth + commaSize;
                }
                break;
            }
            
            // If not, include this user in the list of users
            [usedUsers addObject:user];
            
        }
                
        // If we couldn't include all users we need to back off and make room for the
        // " and x others" string.
        if (usedUsers.count < _users.count)
        {
            NSString *remainingUsersFormat = @"and %i others";
            
            while (usedUsers.count) {
                int usersLeft = (_users.count - usedUsers.count) + 1;
                
                // The width needed to accomodate the trailer given the number of users left.
                int neededWidth = [[NSString stringWithFormat:remainingUsersFormat, usersLeft] sizeWithFont:_font].width;
                
                // Find the width of the last object in the array and remove it.
                NSString *name = ([usedUsers lastObject] == _signedInUser) ? @"you" : [[usedUsers lastObject] username];
                int sizeOfLastItem = [name sizeWithFont:_font].width;
                [usedUsers removeLastObject];
                
                // If the leftover available width, plus the width of the last item, plus the 
                // width of a comma is enough to meet our need, then we're done. Otherwise, we
                // need to go around again.
                if (availableWidth + sizeOfLastItem + commaSize >= neededWidth) {
                    break;
                }
                
            }
            
        }
        
        
        // If we couldn't fit any on the line, we just display the number of users.
        if (usedUsers.count == 0)
        {
            // If we have one user, and a singular numeric suffix has been set, use it.
            // Otherwise we use the normal numeric suffix.
            NSString *suffix = (_users.count == 1 && _singularNumericSuffix) ? _singularNumericSuffix : _numericSuffix;
            
            NSString *likeString = [NSString stringWithFormat:@"%i %@", _users.count, suffix];
            
            // Set the string
            _attributedString = [[NSMutableAttributedString alloc] initWithString:likeString];
            
            // Set the tappable area
            _allUsersTappableArea = [self _areaForNewString:likeString onString:@""];
            
            _regenerateStringNeeded = NO;
            return;
        }
        
        
        // Now we know what will fit, so let's construct the line.
        NSString *likeString = _prefixString;
        
        // Pull together the usedUsers and generate the correct tappable areas.
        for (int i = 0; i < usedUsers.count; i++) {
            EMTLUser *user = [usedUsers objectAtIndex:i];
            NSString *name = (user == _signedInUser) ? @"you" : user.username;
            [_tappableAreas setObject:user forKey:[self _areaForNewString:name onString:likeString]];
            likeString = [likeString stringByAppendingFormat:@" %@", name];
            if (i < usedUsers.count - 1)
            {
                likeString = [likeString stringByAppendingString:@","];
            }
        }
        
        // Generate the remainder string and tappable area
        int numRemaining = (_users.count - usedUsers.count);
        
        // If there is a remainder, add the remainder string.
        if (numRemaining) 
        {
            NSString *pluralRemainder = (numRemaining != 1) ? @"s" : @"";
            
            NSString *remainder = [NSString stringWithFormat:@" and %i other%@", numRemaining, pluralRemainder];
            _allUsersTappableArea = [self _areaForNewString:remainder onString:likeString];
            
            likeString = [likeString stringByAppendingString:remainder];
            
        }
        
        
        // Create the attributed string
        _attributedString = [[NSMutableAttributedString alloc] initWithString:likeString];
        
        _regenerateStringNeeded = NO;
        return;
    }
}
                               
- (NSValue *)_areaForNewString:(NSString *)new onString:(NSString *)old
{
    CGSize oldSize = [old sizeWithFont:_font];
    CGSize newSize = [new sizeWithFont:_font];
    
    return [NSValue valueWithCGRect:CGRectMake(oldSize.width, 0, newSize.width, self.frame.size.height)];
                       
}


@end

//
//  NSDate+IW_ISO8601.m
//  Berzerk
//
//  Created by Ian White on 6/21/12.
//  Copyright (c) 2012 Apple Inc. All rights reserved.
//

#import "NSDate+IW_ISO8601.h"

@implementation NSDate (IW_ISO8601)


- (NSString *)humanString
{
    //    
    //    if (datePostedString) {
    //        return datePostedString;
    //    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nowComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    
    long nowYear = [nowComponents year];
    long nowMonth = [nowComponents month];
    long nowDay = [nowComponents day];
    
    long dateYear = [dateComponents year];
    long dateMonth = [dateComponents month];
    long dateDay = [dateComponents day];
    
    if (nowYear == dateYear)
    {
        
        if (nowMonth == dateMonth) {
            
            if (nowDay == dateDay) {
                return NSLocalizedString(@"Today", @"");
            }
            else if (nowDay == dateDay + 1) {
                return NSLocalizedString(@"Yesterday", @"");;
            }
            else if (nowDay == dateDay - 1) {
                return NSLocalizedString(@"Tomorrow", @"");;
            }
            else if (dateDay - nowDay < 6) {
                [dateFormat setDateFormat:@"EEEE"];
            }
            else {
                [dateFormat setDateFormat:@"MMMM d"];
            }
            
        }
        else {
            [dateFormat setDateFormat:@"MMMM d"];
        }
        
    }
    else {
        [dateFormat setDateFormat:@"MMM d, y"];
    }
    
    //datePostedString = ;
    
    return [dateFormat stringFromDate:self];
    
}

@end

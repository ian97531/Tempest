//
//  EMTLLocation.h
//  Tempest
//
//  Created by Ian White on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLConstants.h"

@interface EMTLLocation : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic) EMTLLocationType type;

@property (nonatomic, strong) NSString *woe_id;

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

@end

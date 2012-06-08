//
//  UIImage+UIImage_IWDecompressJPEG.h
//  Tempest
//
//  Created by Ian White on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (IWDecompressJPEG)

+ (UIImage *)decompressImageWithContentsOfFile:(NSString *)path;
+ (UIImage *)decompressImageWithData:(NSData *)data;
+ (UIImage *)decompressedImageWithImage:(UIImage *)image;

@end

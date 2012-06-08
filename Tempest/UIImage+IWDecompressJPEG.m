//
//  UIImage+UIImage_IWDecompressJPEG.m
//  Tempest
//
//  Created by Ian White on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+IWDecompressJPEG.h"


@implementation UIImage (IWDecompressJPEG)

+ (UIImage *)decompressImageWithContentsOfFile:(NSString *)path
{
    return [UIImage decompressedImageWithImage:[UIImage imageWithContentsOfFile:path]];
}

+ (UIImage *)decompressImageWithData:(NSData *)data
{
    return [UIImage decompressedImageWithImage:[UIImage imageWithData:data]];
}


+ (UIImage *)decompressedImageWithImage:(UIImage *)image
{
    CGImageRef cgImageRef = image.CGImage;
    // System only supports RGB, set explicitly and prevent context error
    // if the downloaded image is not the supported format
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGImageGetWidth(cgImageRef),
                                                 CGImageGetHeight(cgImageRef),
                                                 8,
                                                 // width * 4 will be enough because are in ARGB format, don't read from the image
                                                 CGImageGetWidth(cgImageRef) * 4,
                                                 colorSpace,
                                                 // kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little 
                                                 // makes system don't need to do extra conversion when displayed.
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little); 
    CGColorSpaceRelease(colorSpace);

    if (context) {
        CGRect rect = (CGRect){CGPointZero, CGImageGetWidth(cgImageRef), CGImageGetHeight(cgImageRef)};
        CGContextDrawImage(context, rect, cgImageRef);
        CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        
        UIImage *decompressedImage = [[UIImage alloc] initWithCGImage:decompressedImageRef];
        CGImageRelease(decompressedImageRef);
        
        return decompressedImage;
    }

    return image;
}


@end

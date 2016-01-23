//
//  UIImage+BXOperation.m
//  Baixing
//
//  Created by phoebus on 11/11/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import "UIImage+Crop.h"

@implementation UIImage (Crop)

- (UIImage *)imageCroppedToSize:(CGSize)size
{
    CGFloat factor = MAX(size.width/self.size.width, size.height/self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(size,
                                           YES,                     // Opaque
                                           self.scale);             // Use image scale
    
    CGRect rect = CGRectMake((size.width - nearbyintf(self.size.width * factor)) / 2.0,
                             (size.height - nearbyintf(self.size.height * factor)) / 2.0,
                             nearbyintf(self.size.width * factor),
                             nearbyintf(self.size.height * factor));
    
    [self drawInRect:rect];
    UIImage * croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

- (UIImage *)thumbnailWithSize:(CGSize)size
{
    // Manually set to double size for retina?
    CGFloat screenScale = [UIScreen mainScreen].scale;
    if (self.scale < screenScale) {
        size = CGSizeMake(size.width * screenScale, size.height * screenScale);
    }
    
    return [self imageCroppedToSize:size];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

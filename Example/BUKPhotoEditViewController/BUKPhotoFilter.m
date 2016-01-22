//
//  BUKPhotoFilter.m
//  BUKPhotoEditViewController
//
//  Created by Lazy on 1/22/16.
//  Copyright © 2016 lazy. All rights reserved.
//

#import "BUKPhotoFilter.h"

@implementation BUKPhotoFilter

+ (UIImage *)filterImageWithImage:(UIImage *)image filter:(CIFilter *)filter
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIContext *context = [CIContext contextWithOptions:kNilOptions];
    
    [filter setDefaults];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    
    return [UIImage imageWithCGImage:[context createCGImage:filter.outputImage fromRect:[ciImage extent]]];
}

@end

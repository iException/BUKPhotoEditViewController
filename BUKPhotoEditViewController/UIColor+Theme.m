//
//  UIColor+Theme.m
//  BUKPhotoEditViewController
//
//  Created by Lazy on 1/22/16.
//  Copyright © 2016 lazy. All rights reserved.
//

#import "UIColor+Theme.h"
#import "UIColor+hex.h"

@implementation UIColor (Theme)

+ (UIColor *)themeColor
{
    return [UIColor colorWithHex:@"45CCFF"];
}

+ (UIColor *)pev_darkGrayColor
{
    return [UIColor colorWithHex:@"252729"];
}

@end

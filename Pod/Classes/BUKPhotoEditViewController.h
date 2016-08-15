//
//  ViewController.h
//  BUKPhotoEditViewController
//
//  Created by lazy on 15/10/27.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BUKPhotoEditViewController;

@protocol BUKPhotoEditViewControllerDelegate <NSObject>

@required
- (void)buk_photoEditViewController:(BUKPhotoEditViewController *)controller didFinishEditingPhoto:(UIImage *)photo;
- (void)buk_photoEditViewControllerDidCancelEditingPhoto:(BUKPhotoEditViewController *)controller;

@end


@interface BUKPhotoEditViewController : UIViewController

- (instancetype)initWithPhoto:(UIImage *)photo;
- (instancetype)initWithPhoto:(UIImage *)photo tintColor:(UIColor *)tintColor;

@property (weak, nonatomic) id<BUKPhotoEditViewControllerDelegate> delegate;

@end

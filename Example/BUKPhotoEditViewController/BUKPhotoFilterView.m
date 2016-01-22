//
//  BUKPhotoFilterView.m
//  BUKPhotoEditViewController
//
//  Created by Lazy on 1/14/16.
//  Copyright © 2016 lazy. All rights reserved.
//

#import "BUKPhotoFilterView.h"
#import "UIColor+hex.h"
#import <CoreImage/CoreImage.h>

@interface BUKPhotoFilterView ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CIFilter *filter;

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *namelabel;

@end

@implementation BUKPhotoFilterView

const static CGFloat kLabelHeight = 13.0f;
const static CGFloat kImageToLabelVerticalHeight = 9.0f;

- (instancetype)initWithPhoto:(UIImage *)photo name:(NSString *)name filter:(CIFilter *)filter
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _image = photo;
        _filter = filter;
        self.namelabel.text = name;
    }
    return self;
}

- (void)generateFilter
{
    [self addSubview:self.imageView];
    [self addSubview:self.namelabel];

    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - kLabelHeight - kImageToLabelVerticalHeight);
    self.namelabel.frame = CGRectMake(0, self.imageView.frame.size.height + kImageToLabelVerticalHeight, self.frame.size.width, kLabelHeight);
    
    [self generateFilterView];
}

- (void)generateFilterView
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CIImage *ciImage = [[CIImage alloc] initWithImage:self.image];
        CIContext *context = [CIContext contextWithOptions:kNilOptions];
        
        [self.filter setDefaults];
        [self.filter setValue:ciImage forKey:kCIInputImageKey];
        
        UIImage *image = [UIImage imageWithCGImage:[context createCGImage:self.filter.outputImage fromRect:[ciImage extent]]];
        if (image) {
            self.image = image;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = self.image;
        });
    });
}

- (UIImage *)filteredImage
{
    return self.image;
}

#pragma mark - getter -

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UILabel *)namelabel
{
    if (!_namelabel) {
        _namelabel = [[UILabel alloc] init];
        _namelabel.textColor = [UIColor colorWithHex:@"AEAEAE"];
        _namelabel.font = [UIFont systemFontOfSize:12.0f];
        _namelabel.textAlignment = NSTextAlignmentCenter;
    }
    return _namelabel;
}

@end

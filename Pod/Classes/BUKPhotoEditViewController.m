//
//  ViewController.m
//  BUKPhotoEditViewController
//
//  Created by lazy on 15/10/27.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import "BUKPhotoEditViewController.h"
#import "BUKPhotoClipViewController.h"
#import "BUKPhotoMosaicViewController.h"
#import "BUKPhotoFiltersScrollView.h"
#import "BUKPhotoFilterView.h"
#import "UIImage+Crop.h"
#import "UIColor+Theme.h"

#define SCREEN_FACTOR [UIScreen mainScreen].bounds.size.width/414.0

@interface BUKPhotoEditViewController () <BUKPhotoClipViewControllerDelegate, BUKPhotoMosaicViewControllerDelegate, UIAlertViewDelegate, BUKPhotoFiltersDelegate, BUKPhotoFiltersDataSource>

@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UIImage *originalPhoto;

@property (nonatomic, strong) UIButton *rotateButton;
@property (nonatomic, strong) UIButton *mosaicButton;
@property (nonatomic, strong) UIButton *clipButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UILabel *rotateLabel;
@property (nonatomic, strong) UILabel *mosaicLabel;
@property (nonatomic, strong) UILabel *clipLabel;
@property (nonatomic, strong) UILabel *coverLabel;

@property (nonatomic, strong) UIView *bottomMaskView;

@property (nonatomic, strong) BUKPhotoFiltersScrollView *filtersScrollView;

@property (nonatomic, assign) BOOL backBarButtonHidden;

@end

@implementation BUKPhotoEditViewController

static const CGFloat kLabelToBottomPadding = 42.0f;
static const CGFloat kButtonToBottomPadding = 100.0f;

static const CGFloat kDoneButtonHeight = 47.0f;
static const CGFloat kBottomButtonLeftPadding = 43.0f;
static const CGFloat kFilterScrollViewHeight = 118.0f;
static const CGFloat kButtonBaseWidth = 40.0f;
static const CGFloat kLabelBaseWidth = 60.0f;
static const CGFloat kDefaultFontSize = 14.0f;
static const CGFloat kButtonNumberFactor = 6.0f;
static NSString *kPhotoViewObserverPath = @"image.imageOrientation";

#pragma mark - initializer -

- (instancetype)init
{
    NSAssert(NO, @"You Can't Use This Method To Initialize, Please Use `initWithPhoto:` instead!");
    return nil;
}

- (instancetype)initWithPhoto:(UIImage *)photo
{
    self = [super init];
    if (self) {
        [self setupViewsWithPhoto:photo];
    }
    return self;
}

#pragma mark - lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.backBarButtonHidden = self.navigationItem.hidesBackButton;
    [self.navigationItem setHidesBackButton:YES];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self layoutFrame];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.navigationItem setHidesBackButton:self.backBarButtonHidden];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.photoView removeObserver:self forKeyPath:kPhotoViewObserverPath];
}

#pragma mark - event response -

- (void)rotate:(id)sender
{
    UIImageOrientation nextOrientation;
    switch (self.photoView.image.imageOrientation) {
        case UIImageOrientationUp:
            nextOrientation = UIImageOrientationLeft;
            break;
        case UIImageOrientationLeft:
            nextOrientation = UIImageOrientationDown;
            break;
        case UIImageOrientationDown:
            nextOrientation = UIImageOrientationRight;
            break;
        case UIImageOrientationRight:
            nextOrientation = UIImageOrientationUp;
            break;
        default:
            nextOrientation = UIImageOrientationUp;
            break;
    }
    
    UIImage *image = [UIImage imageWithCGImage:[self.photoView.image CGImage] scale:1.0f orientation:nextOrientation];
    self.photoView.image = image;
    self.photoView.center = [self imageCenter];
}

- (void)mosaic:(id)sender
{
    BUKPhotoMosaicViewController *mosaicViewController = [[BUKPhotoMosaicViewController alloc] initWithPhoto:self.photoView.image];
    mosaicViewController.delegate = self;
    [self.navigationController pushViewController:mosaicViewController animated:YES];
}

- (void)clip:(id)sender
{
    BUKPhotoClipViewController *clipViewController = [[BUKPhotoClipViewController alloc] initWithPhoto:self.photoView.image];
    clipViewController.delegate = self;
    [self.navigationController pushViewController:clipViewController animated:YES];
}

- (void)confirm:(id)sender
{
    [self.delegate buk_photoEditViewController:self didFinishEditingPhoto:self.photoView.image];
}

- (void)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(buk_photoEditViewControllerDidCancelEditingPhoto:)]) {
        [self.delegate buk_photoEditViewControllerDidCancelEditingPhoto:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kPhotoViewObserverPath]) {
        [self resetFrame];
        self.photoView.center = [self imageCenter];
    }
}

#pragma mark - delegate -
#pragma mark - BUKPhotoCipViewControllerDelegate -

- (void)photoClipViewController:(BUKPhotoClipViewController *)controller didFinishEditingPhoto:(UIImage *)photo
{
    [controller.navigationController popViewControllerAnimated:YES];
    self.photoView.image = photo;
    self.photoView.center = [self imageCenter];
    
    [self.filtersScrollView reloadData];
}

- (void)photoClipViewControllerDidCancelEditingPhoto:(BUKPhotoClipViewController *)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
}

#pragma mark - BUKPhotoMosaicViewControllerDelegate -

- (void)photoMosaicViewController:(BUKPhotoMosaicViewController *)controller didFinishEditingPhoto:(UIImage *)photo
{
    [controller.navigationController popViewControllerAnimated:YES];
    self.photoView.image = photo;
    self.photoView.center = [self imageCenter];
    
    [self.filtersScrollView reloadData];
}

- (void)photoMosaicViewControllerDidCancelEditingPhoto:(BUKPhotoMosaicViewController *)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
}

#pragma mark - BUKPhotoFilterDataSource & Delegate

- (NSInteger)buk_numberOfFiltersInPhotoFiltersScrollView:(BUKPhotoFiltersScrollView *)photoFiltersScrollView
{
    return 5;
}

- (BUKPhotoFilterView *)buk_photoFiltersScrollView:(BUKPhotoFiltersScrollView *)photoFiltersScrollView filterViewAtIndex:(NSInteger)index
{
    NSString *name;
    CIFilter *filter;
    
    if (index == 0) {
        name = @"原图";
        filter = nil;
    } else if (index == 1) {
        name = @"经典lomo";
        filter = [CIFilter filterWithName:@"CIPhotoEffectChrome"];
    } else if (index == 2) {
        name = @"淡雅";
        filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    } else if (index == 3) {
        name = @"蓝调";
        filter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
    } else if (index == 4) {
        name = @"复古";
        filter = [CIFilter filterWithName:@"CIPhotoEffectFade"];
    }
    
    BUKPhotoFilterView *filterView = [[BUKPhotoFilterView alloc] initWithPhoto:self.photoView.image name:name filter:filter];
    return filterView;
}

- (void)buk_photoFiltersScrollView:(BUKPhotoFiltersScrollView *)photoFiltersScrollView didSelectPhotoFilterAtIndex:(NSInteger)index
{
    UIImage *filteredImage = [photoFiltersScrollView filteredImageAtIndex:index];
    self.photoView.image = filteredImage;
}

#pragma mark - private -

- (void)setupViewsWithPhoto:(UIImage *)photo
{
    self.navigationItem.title = @"照片编辑器";
    self.view.backgroundColor = [UIColor blackColor];
        
    self.photoView.image = photo;
    self.originalPhoto = photo;
    
    [self.photoView addObserver:self forKeyPath:kPhotoViewObserverPath options:NSKeyValueObservingOptionNew context:nil];
    
    [self.view addSubview:self.bottomMaskView];
    [self.view addSubview:self.photoView];
    [self.view addSubview:self.rotateButton];
    [self.view addSubview:self.mosaicButton];
    [self.view addSubview:self.clipButton];
    [self.view addSubview:self.doneButton];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.rotateLabel];
    [self.view addSubview:self.mosaicLabel];
    [self.view addSubview:self.clipLabel];
    [self.view addSubview:self.coverLabel];
    [self.view addSubview:self.filtersScrollView];

}

- (void)layoutFrame
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self.bottomMaskView.frame = CGRectMake(0, screenSize.height - kBottomButtonLeftPadding * SCREEN_FACTOR, screenSize.width, kBottomButtonLeftPadding);
    
    self.rotateButton.frame = CGRectMake(screenSize.width / kButtonNumberFactor - (kButtonBaseWidth ) / 2 * SCREEN_FACTOR, screenSize.height - ((kButtonBaseWidth ) / 2 + kButtonToBottomPadding) * SCREEN_FACTOR, kButtonBaseWidth * SCREEN_FACTOR, kButtonBaseWidth * SCREEN_FACTOR);
    self.mosaicButton.frame = CGRectMake(3 * screenSize.width / kButtonNumberFactor - (kButtonBaseWidth ) / 2 * SCREEN_FACTOR, screenSize.height - ((kButtonBaseWidth ) / 2 + kButtonToBottomPadding) * SCREEN_FACTOR, kButtonBaseWidth * SCREEN_FACTOR, kButtonBaseWidth * SCREEN_FACTOR);
    self.clipButton.frame = CGRectMake(5 * screenSize.width / kButtonNumberFactor - (kButtonBaseWidth ) / 2 * SCREEN_FACTOR, screenSize.height - ((kButtonBaseWidth ) / 2 + kButtonToBottomPadding) * SCREEN_FACTOR, kButtonBaseWidth * SCREEN_FACTOR, kButtonBaseWidth * SCREEN_FACTOR);
    self.cancelButton.frame = CGRectMake(kBottomButtonLeftPadding * SCREEN_FACTOR, screenSize.height - kDoneButtonHeight * SCREEN_FACTOR, kDoneButtonHeight * SCREEN_FACTOR, kDoneButtonHeight * SCREEN_FACTOR);
    self.doneButton.frame = CGRectMake(screenSize.width - (kBottomButtonLeftPadding + kDoneButtonHeight) * SCREEN_FACTOR, screenSize.height - kDoneButtonHeight * SCREEN_FACTOR, kDoneButtonHeight * SCREEN_FACTOR, kDoneButtonHeight * SCREEN_FACTOR);
    
    self.rotateLabel.frame = CGRectMake(screenSize.width / kButtonNumberFactor - kLabelBaseWidth / 2 * SCREEN_FACTOR, screenSize.height - (kLabelBaseWidth / 2 + kLabelToBottomPadding) * SCREEN_FACTOR, kLabelBaseWidth * SCREEN_FACTOR, 30 * SCREEN_FACTOR);
    self.mosaicLabel.frame = CGRectMake(3 * screenSize.width / kButtonNumberFactor - kLabelBaseWidth / 2 * SCREEN_FACTOR, screenSize.height - (kLabelBaseWidth / 2 + kLabelToBottomPadding) * SCREEN_FACTOR, kLabelBaseWidth * SCREEN_FACTOR, 30 * SCREEN_FACTOR);
    self.clipLabel.frame = CGRectMake(5 * screenSize.width / kButtonNumberFactor - kLabelBaseWidth / 2 * SCREEN_FACTOR, screenSize.height - (kLabelBaseWidth / 2 + kLabelToBottomPadding) * SCREEN_FACTOR, kLabelBaseWidth * SCREEN_FACTOR, 30 * SCREEN_FACTOR);
    
    self.filtersScrollView.frame = CGRectMake(0, self.rotateButton.frame.origin.y - kFilterScrollViewHeight * SCREEN_FACTOR - 10, screenSize.width, kFilterScrollViewHeight * SCREEN_FACTOR);
    
    [self resetFrame];
    self.photoView.clipsToBounds = YES;
    self.photoView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoView.center = [self imageCenter];
    
    [self.filtersScrollView reloadData];
}

- (void)resetFrame
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.photoView.frame = CGRectMake(0, 44, screenSize.width, self.filtersScrollView.frame.origin.y - 64);
}

- (CGPoint)imageCenter
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat y = (self.filtersScrollView.frame.origin.y + 64) / 2.0f;
    return CGPointMake(screenSize.width / 2, y);
}

#pragma mark - getter & setter -

- (UIImageView *)photoView
{
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
    }
    return _photoView;
}

- (UIButton *)rotateButton
{
    if (!_rotateButton) {
        _rotateButton = [[UIButton alloc] init];
        [_rotateButton setImage:[UIImage imageNamed:@"qingquan_rotate_button"] forState:UIControlStateNormal];
        [_rotateButton addTarget:self action:@selector(rotate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotateButton;
}

- (UIButton *)mosaicButton
{
    if (!_mosaicButton) {
        _mosaicButton = [[UIButton alloc] init];
        [_mosaicButton setImage:[UIImage imageNamed:@"qingquan_mosaic_button"] forState:UIControlStateNormal];
        [_mosaicButton addTarget:self action:@selector(mosaic:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mosaicButton;
}

- (UIButton *)clipButton
{
    if (!_clipButton) {
        _clipButton = [[UIButton alloc] init];
        [_clipButton setImage:[UIImage imageNamed:@"qingquan_clip_button"] forState:UIControlStateNormal];
        [_clipButton addTarget:self action:@selector(clip:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clipButton;
}

- (UIButton *)doneButton
{
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] init];
        [_doneButton setImage:[UIImage imageNamed:@"photo_edit_done"] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UIButton *)cancelButton {
    if(_cancelButton == nil) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setImage:[UIImage imageNamed:@"qingquan_edit_cancel"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UILabel *)rotateLabel
{
    if (!_rotateLabel) {
        _rotateLabel = [[UILabel alloc] init];
        _rotateLabel.text = @"旋转";
        _rotateLabel.textColor = [UIColor whiteColor];
        _rotateLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _rotateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _rotateLabel;
}

- (UILabel *)mosaicLabel
{
    if (!_mosaicLabel) {
        _mosaicLabel = [[UILabel alloc] init];
        _mosaicLabel.text = @"马赛克";
        _mosaicLabel.textColor = [UIColor whiteColor];
        _mosaicLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _mosaicLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _mosaicLabel;
}

- (UILabel *)clipLabel
{
    if (!_clipLabel) {
        _clipLabel = [[UILabel alloc] init];
        _clipLabel.text = @"裁剪";
        _clipLabel.textColor = [UIColor whiteColor];
        _clipLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _clipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _clipLabel;
}

- (UILabel *)coverLabel
{
    if (!_coverLabel) {
        _coverLabel = [[UILabel alloc] init];
        _coverLabel.text = @"设为封面";
        _coverLabel.textColor = [UIColor whiteColor];
        _coverLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _coverLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _coverLabel;
}

- (BUKPhotoFiltersScrollView *)filtersScrollView
{
    if (!_filtersScrollView) {
        _filtersScrollView = [[BUKPhotoFiltersScrollView alloc] init];
        _filtersScrollView.filtersDelegate = self;
        _filtersScrollView.dataSource = self;
        _filtersScrollView.backgroundColor = [UIColor pev_darkGrayColor];
    }
    return _filtersScrollView;
}

- (UIView *)bottomMaskView {
	if(_bottomMaskView == nil) {
		_bottomMaskView = [[UIView alloc] init];
        _bottomMaskView.backgroundColor = [UIColor pev_darkGrayColor];
	}
	return _bottomMaskView;
}

@end

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

@interface BUKPhotoEditViewController () <BUKPhotoClipViewControllerDelegate, BUKPhotoMosaicViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIImageView *photoView;

@property (nonatomic, strong) UIImage *originalPhoto;

@property (nonatomic, strong) UIButton *rotateButton;
@property (nonatomic, strong) UIButton *mosaicButton;
@property (nonatomic, strong) UIButton *clipButton;
@property (nonatomic, strong) UIButton *coverButton;

@property (nonatomic, strong) UILabel *rotateLabel;
@property (nonatomic, strong) UILabel *mosaicLabel;
@property (nonatomic, strong) UILabel *clipLabel;
@property (nonatomic, strong) UILabel *coverLabel;

@end

@implementation BUKPhotoEditViewController

static const CGFloat kButtonToBottomPadding = 83.0f;
static const CGFloat kLabelToBottomPadding = 25.0f;
static const CGFloat kButtonBaseWidth = 40.0f;
static const CGFloat kPortraitPhotoPadding = 200.0f;
static const CGFloat kLabelBaseWidth = 60.0f;
static const CGFloat kDefaultFontSize = 14.0f;
static NSString *kPhotoViewObserverPath = @"image.imageOrientation";

#pragma mark - initializer -

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
    
    [self layoutFrame];
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
    [self.delegate photoEditViewController:self didFinishEditingPhoto:self.photoView.image];
}

- (void)cancel:(id)sender
{
    [self.delegate photoEditViewControllerDidCancelEditingPhoto:self];
}

- (void)cover:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"要设为封面吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)delete:(id)sender
{
    [self.delegate photoEditViewControllerDidDeletePhoto:self];
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
}

- (void)photoMosaicViewControllerDidCancelEditingPhoto:(BUKPhotoMosaicViewController *)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.delegate photoEditViewController:self didSetCoverWithPhoto:self.photoView.image];
    }
}

#pragma mark - private -

- (void)setupViewsWithPhoto:(UIImage *)photo
{
    self.navigationItem.title = @"照片编辑器";
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"photo_edit_delete"] style:UIBarButtonItemStylePlain target:self action:@selector(delete:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.photoView.image = photo;
    self.originalPhoto = photo;
    
    [self.photoView addObserver:self forKeyPath:kPhotoViewObserverPath options:NSKeyValueObservingOptionNew context:nil];
    
    [self.view addSubview:self.photoView];
    [self.view addSubview:self.rotateButton];
    [self.view addSubview:self.mosaicButton];
    [self.view addSubview:self.clipButton];
    [self.view addSubview:self.coverButton];
    [self.view addSubview:self.rotateLabel];
    [self.view addSubview:self.mosaicLabel];
    [self.view addSubview:self.clipLabel];
    [self.view addSubview:self.coverLabel];
    
    [self resetFrame];
    self.photoView.clipsToBounds = YES;
    self.photoView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoView.center = [self imageCenter];
}

- (void)layoutFrame
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    self.rotateButton.frame = CGRectMake(screenSize.width / 8.0f - (kButtonBaseWidth * scale) / 2, screenSize.height - (kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding, kButtonBaseWidth * scale, kButtonBaseWidth * scale);
    self.mosaicButton.frame = CGRectMake(3 * screenSize.width / 8.0f - (kButtonBaseWidth * scale) / 2, screenSize.height - (kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding, kButtonBaseWidth * scale, kButtonBaseWidth * scale);
    self.clipButton.frame = CGRectMake(5 * screenSize.width / 8.0f - (kButtonBaseWidth * scale) / 2, screenSize.height - (kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding, kButtonBaseWidth * scale, kButtonBaseWidth * scale);
    self.coverButton.frame = CGRectMake(7 * screenSize.width / 8.0f - (kButtonBaseWidth * scale) / 2, screenSize.height - (kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding, kButtonBaseWidth * scale, kButtonBaseWidth * scale);
    
    self.rotateLabel.frame = CGRectMake(screenSize.width / 8.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
    self.mosaicLabel.frame = CGRectMake(3 * screenSize.width / 8.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
    self.clipLabel.frame = CGRectMake(5 * screenSize.width / 8.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
    self.coverLabel.frame = CGRectMake(7 * screenSize.width / 8.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
}

- (void)resetFrame
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (self.photoView.image.size.width >= self.photoView.image.size.height) {
        self.photoView.frame = CGRectMake(0, 0, screenSize.width, screenSize.width * 0.75f);
    } else {
        self.photoView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height - kPortraitPhotoPadding);
    }
}

- (CGPoint)imageCenter
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat y = screenSize.height / 2 - ((kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding + 66) / 2;
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
        [_rotateButton setImage:[UIImage imageNamed:@"photo_edit_rotate"] forState:UIControlStateNormal];
        _rotateButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_rotateButton addTarget:self action:@selector(rotate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotateButton;
}

- (UIButton *)mosaicButton
{
    if (!_mosaicButton) {
        _mosaicButton = [[UIButton alloc] init];
        [_mosaicButton setImage:[UIImage imageNamed:@"photo_edit_mosaic"] forState:UIControlStateNormal];
        _mosaicButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_mosaicButton addTarget:self action:@selector(mosaic:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mosaicButton;
}

- (UIButton *)clipButton
{
    if (!_clipButton) {
        _clipButton = [[UIButton alloc] init];
        [_clipButton setImage:[UIImage imageNamed:@"photo_edit_clip"] forState:UIControlStateNormal];
        _clipButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_clipButton addTarget:self action:@selector(clip:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clipButton;
}

- (UIButton *)coverButton
{
    if (!_coverButton) {
        _coverButton = [[UIButton alloc] init];
        [_coverButton setImage:[UIImage imageNamed:@"photo_edit_cover"] forState:UIControlStateNormal];
        _coverButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_coverButton addTarget:self action:@selector(cover:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coverButton;
}

- (UILabel *)rotateLabel
{
    if (!_rotateLabel) {
        _rotateLabel = [[UILabel alloc] init];
        _rotateLabel.text = @"旋转";
        _rotateLabel.textColor = [UIColor whiteColor];
        _rotateLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _rotateLabel.textAlignment = NSTextAlignmentCenter;
        _rotateLabel.translatesAutoresizingMaskIntoConstraints = NO;
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
        _mosaicLabel.translatesAutoresizingMaskIntoConstraints = NO;
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
        _clipLabel.translatesAutoresizingMaskIntoConstraints = NO;
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
        _coverLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _coverLabel;
}

@end

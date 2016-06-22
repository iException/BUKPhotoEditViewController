//
//  BUKViewController.m
//  BUKPhotoEditViewController
//
//  Created by LazyClutch on 02/19/2016.
//  Copyright (c) 2016 LazyClutch. All rights reserved.
//

#import "BUKViewController.h"
#import <BUKPhotoEditViewController.h>


@interface BUKViewController ()

@end


@implementation BUKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"照片编辑器";

    BUKPhotoEditViewController *photoEditViewController = [[BUKPhotoEditViewController alloc] initWithPhoto:[UIImage imageNamed:@"1.jpg"]];
    [self.navigationController pushViewController:photoEditViewController animated:YES];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

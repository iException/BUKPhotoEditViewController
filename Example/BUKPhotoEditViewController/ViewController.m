//
//  ViewController.m
//  BUKPhotoEditViewController
//
//  Created by lazy on 15/11/8.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import "ViewController.h"
#import "BUKPhotoEditViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"照片编辑器";
    
    BUKPhotoEditViewController *photoEditViewController = [[BUKPhotoEditViewController alloc] initWithPhoto:[UIImage imageNamed:@"2.png"]];
    [self.navigationController pushViewController:photoEditViewController animated:YES];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

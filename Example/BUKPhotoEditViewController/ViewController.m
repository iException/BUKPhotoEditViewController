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
    
    BUKPhotoEditViewController *photoEditViewController = [[BUKPhotoEditViewController alloc] initWithPhoto:[UIImage imageNamed:@"sample_landscape"]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    [self.navigationController pushViewController:photoEditViewController animated:YES];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

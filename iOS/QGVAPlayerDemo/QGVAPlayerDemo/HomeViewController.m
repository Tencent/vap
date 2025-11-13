//
//  HomeViewController.m
//  QGVAPlayerDemo
//
//  Created by york on 2025/4/9.
//  Copyright © 2025 Tencent. All rights reserved.
//

#import "ViewController.h"
#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (IBAction)test1Click:(id)sender {
    ViewController * toVC =  [[ViewController alloc] init];
    [self.navigationController pushViewController:toVC animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

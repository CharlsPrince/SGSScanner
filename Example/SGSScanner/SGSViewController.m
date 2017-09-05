//
//  SGSViewController.m
//  SGSScanner
//
//  Created by Lee on 01/12/2017.
//  Copyright (c) 2017 Lee. All rights reserved.
//

#import "SGSViewController.h"
#import "UIStoryboard+SGS.h"
#import "SGSScannerHelper.h"
#import "SGSScannerViewController.h"

@interface SGSViewController ()

@end

@implementation SGSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)gotoScanViewController:(UIButton *)sender {
    SGSScannerViewController *vc = [[SGSScannerViewController alloc] initWithDelegate:[SGSScannerHelper new]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoGenerateCodeImageViewController:(UIButton *)sender {
    UIViewController *vc = [UIStoryboard viewControllerInMainStoryboardWithIdentifier:@"SGSGenerateCodeImageViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

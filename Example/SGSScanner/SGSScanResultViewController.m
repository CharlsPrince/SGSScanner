//
//  SGSScanResultViewController.m
//  SGSScanner
//
//  Created by Lee on 2017/1/13.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "SGSScanResultViewController.h"
#import "SGSScannerViewController.h"

@interface SGSScanResultViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation SGSScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫描结果";
    
    if (self.navigationController.viewControllers.count >= 3) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        NSUInteger index = array.count - 2;
        UIViewController *scannerVC = array[index];
        if ([scannerVC isKindOfClass:[SGSScannerViewController class]]) {
            [array removeObjectAtIndex:index];
            self.navigationController.viewControllers = array.copy;
        }
    }
    
    if (self.scanResult) {
        self.textView.text = self.scanResult;
    } else {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"扫描失败" attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}];
        self.textView.attributedText = str;
    }
}

@end

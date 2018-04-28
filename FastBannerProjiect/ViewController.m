//
//  ViewController.m
//  FastBannerProjiect
//
//  Created by 冷胜任 on 2018/4/28.
//  Copyright © 2018年 NB.com. All rights reserved.
//

#import "ViewController.h"
#import "FastBannerView.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet FastBannerView *fastBanner;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *imageArray2 = @[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"6.jpg"];
    FastBannerView *banner = [[FastBannerView alloc] init];
    banner.frame = CGRectMake(0, 300, self.view.frame.size.width, 200);
    banner.imageDataArray = imageArray2;
    [self.view addSubview:banner];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

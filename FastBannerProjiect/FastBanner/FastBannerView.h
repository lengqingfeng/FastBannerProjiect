//
//  FastBannerView.h
//  FastBannerView
//
//  Created by lsr on 14-4-21.
//  Copyright (c) 2014年 lsr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastPageControl.h"

typedef NS_ENUM(NSInteger, PageControlType) {
    PageControlTypeCenter,
    PageControlTypeRight,
    PageControlTypeLeft,
};

@protocol FastBannerViewDelegate <NSObject>
- (void)selectBannerIndex:(NSInteger)index;
@end


@interface FastBannerView : UIView <UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *imageDataArray; //图片数据
@property (nonatomic, weak) id<FastBannerViewDelegate> delegate;
@property (nonatomic, strong) UIColor *noteViewColor;                // 描述栏的颜色
@property (nonatomic, strong) UIColor *noteTitleColor;               // 添加文字描述字体颜色
@property (nonatomic, assign) NSInteger bannerLoopTime;              //设置滚动时间 0 为停止滚动
@property (nonatomic, strong) UIColor *pageControlCoreNormalColor;   //设置圈圈颜色
@property (nonatomic, strong) UIColor *pageControlCoreSelectedColor; //设置圈圈选中颜色
@property (nonatomic, assign) PageControlType type;                  //pageControll 样式

/**
 显示图片和底部标题栏样式

 @param imagesArray 数据源
 @param nodeArray 标题数组
 */
- (void)setupBanner:(NSArray *)imagesArray nodeArray:(NSArray *)nodeArray;

@property (nonatomic, copy) void (^tapBannerImageViewActionBlock)(NSInteger pageIndex);


@end

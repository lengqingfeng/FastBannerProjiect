//
//  FastBannerView.m
//  FastBannerView
//
//  Created by lsr on 14-4-21.
//  Copyright (c) 2014年 lsr. All rights reserved.
//

#import "FastBannerView.h"
#import "UIImageView+WebCache.h"
#define Screen_W [UIScreen mainScreen].bounds.size.width
#define Screen_H [UIScreen mainScreen].bounds.size.height


@interface FastBannerView () {
    NSInteger currentPageIndex;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FastPageControl *pageControl;
@property (nonatomic, strong) UIView *noteView;
@property (nonatomic, strong) UILabel *noteTitle;
@property (nonatomic, strong) NSTimer *loopTime;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) NSArray *noteTitleArray;
@property (nonatomic, strong) NSArray *currentImageArray;
@property (nonatomic, assign) NSInteger imagesCount;

@property (nonatomic, strong) UIColor *defaultPageNormColor;
@property (nonatomic, strong) UIColor *defaultPageSelectColor;

@property (nonatomic, strong) UIColor *defaultNoteViewColor;
@property (nonatomic, strong) UIColor *defaultNoteTitleColor;

@property (nonatomic, assign) CGFloat defaultPageWidth;
@property (nonatomic, assign) CGFloat defaultPageHeight;
@property (nonatomic, assign) CGFloat currentLoopTimes;
@property (nonatomic, assign) BOOL isAddNodeView; //是否添加Banner说明样式

@end


@implementation FastBannerView
@synthesize pageCount;
@synthesize loopTime;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupDefaultValue];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultValue];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDefaultValue];
    }
    return self;
}

- (void)setImageDataArray:(NSArray *)imageDataArray {
    [self initWithScrollView:imageDataArray noteArray:nil];
}

- (void)setupBanner:(NSArray *)imagesArray nodeArray:(NSArray *)nodeArray {
    [self initWithScrollView:imagesArray noteArray:nodeArray];
}

#pragma mark - DefaultValue
- (void)setupDefaultValue {
    self.defaultPageNormColor = [UIColor whiteColor];
    self.defaultPageSelectColor = [UIColor whiteColor];
    self.defaultNoteViewColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.defaultNoteTitleColor = [UIColor whiteColor];
    self.defaultPageHeight = 12;
    self.currentLoopTimes = 2.8;
    self.userInteractionEnabled = YES;
    self.noteTitleArray = [[NSArray alloc] init];
}

- (void)setNoteTitleColor:(UIColor *)noteTitleColor {
    if (noteTitleColor && self.defaultNoteViewColor != noteTitleColor) {
        self.defaultNoteTitleColor = noteTitleColor;
    }
    _noteTitleColor = noteTitleColor;
}

- (void)setNoteViewColor:(UIColor *)noteViewColor {
    if (noteViewColor && self.defaultNoteViewColor != noteViewColor) {
        self.defaultNoteViewColor = noteViewColor;
    }
}

- (void)setPageControlCoreNormalColor:(UIColor *)color {
    self.pageControl.coreNormalColor = color;
}

- (void)setPageControlCoreSelectedColor:(UIColor *)color {
    self.pageControl.coreSelectedColor = color;
}

#pragma mark -  InitWith ScrollView
- (void)initWithScrollView:(NSArray *)imagesArray
                 noteArray:(NSArray *)noteArray {
    pageCount = imagesArray.count + 2; // 页数
    self.defaultPageWidth = imagesArray.count * 10.0f + 44.f;
    if (noteArray.count > 0) {
        self.noteTitleArray = noteArray;
        self.isAddNodeView = YES;
    } else {
        self.noteTitleArray = @[];
        self.isAddNodeView = NO;
    }

    self.imagesCount = imagesArray.count;

    NSMutableArray *tempMutableArray = [[NSMutableArray alloc] initWithArray:imagesArray];
    [tempMutableArray insertObject:[imagesArray objectAtIndex:imagesArray.count - 1] atIndex:0];
    [tempMutableArray addObject:[imagesArray objectAtIndex:0]];
    self.currentImageArray = [NSArray arrayWithArray:tempMutableArray];
    [self addImageViewInView];
}

#pragma mark - ImageViewTapGestureRecognizer
- (void)addImageViewInView {
    if (self.currentImageArray.count == 0) {
        return;
    }
    for (int i = 0; i < pageCount; i++) {
        NSString *bannerImgeURL = [self.currentImageArray objectAtIndex:i];
        UIImageView *bannerImgeView = [[UIImageView alloc] init];
        bannerImgeView.clipsToBounds = YES;
        bannerImgeView.contentMode = UIViewContentModeScaleToFill;

        if ([bannerImgeURL hasPrefix:@"http://"] || [bannerImgeURL hasPrefix:@"https://"]) {
            [bannerImgeView sd_setImageWithURL:[NSURL URLWithString:bannerImgeURL]];
        } else {
            UIImage *localImage = [UIImage imageNamed:[self.currentImageArray objectAtIndex:i]];
            [bannerImgeView setImage:localImage];
        }

        [bannerImgeView setFrame:CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height)];

        bannerImgeView.tag = i;
        bannerImgeView.clipsToBounds = YES;
        [self imageAddTapGestureWithImageView:bannerImgeView];
        [self.scrollView addSubview:bannerImgeView];
    }

    [self.scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
    [self addSubview:self.scrollView];
    [self addBannerStyle];
    [self startLoopAnimatedTime];
}

- (void)imageAddTapGestureWithImageView:(UIImageView *)imageView {
    //创建滑动手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressed:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    imageView.userInteractionEnabled = YES;      // imageview 可以点击事件
    [imageView addGestureRecognizer:tapGesture]; //添加手势
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    currentPageIndex = page;
    self.pageControl.currentPage = (page - 1);
    NSInteger titleIndex = page - 1;
    if (titleIndex == self.noteTitleArray.count) {
        titleIndex = 0;
    }
    if (titleIndex < 0) {
        titleIndex = self.noteTitleArray.count - 1;
    }
    if (self.noteTitleArray.count > 0) {
        [self.noteTitle setText:[self.noteTitleArray objectAtIndex:titleIndex]];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (currentPageIndex == 0) {
        [self.scrollView setContentOffset:CGPointMake(([self.currentImageArray count] - 2) * self.frame.size.width, 0)]; //是跳转到你指定内容的坐标
    }
    if (currentPageIndex == ([self.currentImageArray count] - 1)) {
        [self.scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (loopTime) {
        [self stopLoopAnimageTime];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.loopTime == nil) {
        [self startLoopAnimatedTime];
    }
}

#pragma mark - ScrollerViewLoop
- (void)setBannerLoopTime:(NSInteger)bannerLoopTime {
    self.currentLoopTimes = bannerLoopTime;
    if (loopTime == 0) {
        [self stopLoopAnimageTime];
    } else {
        if (self.loopTime == nil) {
            [self startLoopAnimatedTime];
        }
    }
}

- (void)startLoopAnimatedTime {
    if (self.loopTime) {
        return;
    }

    self.loopTime = [NSTimer scheduledTimerWithTimeInterval:self.currentLoopTimes target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:loopTime forMode:NSRunLoopCommonModes];
}

- (void)stopLoopAnimageTime {
    [self.loopTime invalidate];
    self.loopTime = nil;
}

- (void)runTimePage {
    NSInteger page = self.pageControl.currentPage; // 获取当前的page
    page++;
    page = page >= self.imagesCount ? 0 : page;
    self.pageControl.currentPage = page;
    [self turnPage];
}

- (void)turnPage {
    NSInteger pagenow = self.pageControl.currentPage; // 获取当前的page
    if (pagenow == 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(Screen_W * (pagenow + 1), 0, Screen_W, 460) animated:NO]; // 触摸pagecontroller那个点点 往后翻一页 +1
    } else {
        [self.scrollView scrollRectToVisible:CGRectMake(Screen_W * (pagenow + 1), 0, Screen_W, 460) animated:YES]; // 触摸pagecontroller那个点点 往后翻一页 +1
    }
}

#pragma mark - Add NodeView and PageControl
- (void)addBannerStyle {
    if (self.isAddNodeView == YES) {
        if (self.imagesCount > 1) {
            CGRect frame = CGRectMake((self.frame.size.width / 2 - self.defaultPageWidth / 2), 6, self.defaultPageWidth, self.defaultPageHeight);
            self.pageControl.frame = frame;
            [self.noteView addSubview:self.pageControl];
        }

        [self.noteView addSubview:self.noteTitle];
        [self addSubview:self.noteView];

    } else {
        if (self.imagesCount > 1) {
            CGRect frame;
            if (self.type == PageControlTypeCenter) {
                //居中
                frame = CGRectMake((self.frame.size.width / 2 - self.defaultPageWidth / 2), self.frame.size.height - 20, self.defaultPageWidth, self.defaultPageHeight);

            } else if (self.type == PageControlTypeLeft) {
                frame = CGRectMake(10, self.frame.size.height - 20, self.defaultPageWidth, self.defaultPageHeight);

            } else {
                frame = CGRectMake((self.frame.size.width - self.defaultPageWidth - 20), self.frame.size.height - 20, self.defaultPageWidth, self.defaultPageHeight);
            }

            self.pageControl.frame = frame;
            [self addSubview:self.pageControl];
        }
    }
}

- (void)animationTimerDidFired:(NSTimer *)timer {
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];
}

- (void)imagePressed:(UITapGestureRecognizer *)sender {
    if (self.tapBannerImageViewActionBlock) {
        self.tapBannerImageViewActionBlock(sender.view.tag);
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(selectBannerIndex:)]) {
        [self.delegate selectBannerIndex:sender.view.tag];
    }
}


- (void)dealloc {
    [self stopLoopAnimageTime];
}

- (UIView *)noteView {
    if (!_noteView) {
        _noteView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 30, self.bounds.size.width, 30)];
        [_noteView setBackgroundColor:self.defaultNoteViewColor];
    }
    return _noteView;
}

- (UILabel *)noteTitle {
    if (!_noteTitle) {
        _noteTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, self.frame.size.width - self.defaultPageWidth - 15, 20)];
        [_noteTitle setText:[self.noteTitleArray objectAtIndex:0]];
        _noteTitle.textColor = self.defaultNoteTitleColor;
        [_noteTitle setBackgroundColor:[UIColor clearColor]];
        [_noteTitle setFont:[UIFont systemFontOfSize:13]];
    }
    return _noteTitle;
}

- (FastPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[FastPageControl alloc] initWithFrame:CGRectZero];
        [_pageControl setPageControlStyle:PageControlStyleStrokedCircle];
        _pageControl.strokeNormalColor = self.defaultPageNormColor;
        //pageControl.alpha = 0.7;
        _pageControl.strokeWidth = 1.5;
        _pageControl.diameter = 10;
        _pageControl.strokeSelectedColor = self.defaultPageSelectColor;
        _pageControl.coreSelectedColor = [UIColor whiteColor];
        if (pageCount > 2) {
            [_pageControl setNumberOfPages:(pageCount - 2)];
        }
        [_pageControl setCurrentPage:0];
    }
    return _pageControl;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        if (self.imagesCount == 1) {
            _scrollView.pagingEnabled = NO;
            [_scrollView setScrollEnabled:NO];

        } else {
            _scrollView.pagingEnabled = YES;
        }
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * pageCount, self.bounds.size.height); //滚动范围的大小
        _scrollView.showsHorizontalScrollIndicator = NO;                                                   //水平方向的滚动指示
        _scrollView.showsVerticalScrollIndicator = NO;                                                     //垂直方向的滚动指示
        _scrollView.scrollsToTop = NO;                                                                     //是否控制控件滚动到顶部
        _scrollView.delegate = self;
    }
    return _scrollView;
}

//假如你有5个元素需要循环：
//
//[0, 1, 2, 3, 4]
//
//那么你在将这四个元素添加到UIScrollView里面的时候，就需要多添加两个，变成这样：
//
//[ 4, 0, 1, 2, 3, 4, 0 ]

@end

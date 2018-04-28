//
//  FastPageControl.h
//  FastPageControl
//


#import <UIKit/UIKit.h>

typedef enum
{
    PageControlStyleDefault = 0,
    PageControlStyleStrokedCircle = 1,
    PageControlStylePressed1 = 2,
    PageControlStylePressed2 = 3,
    PageControlStyleWithPageNumber = 4,
    PageControlStyleThumb = 5,
    PageControlStyleStrokedSquare = 6,
} PageControlStyle;

@interface FastPageControl : UIControl
@property (nonatomic) UIColor *coreNormalColor, *coreSelectedColor;
@property (nonatomic) UIColor *strokeNormalColor, *strokeSelectedColor;
@property (nonatomic) NSInteger currentPage, numberOfPages;
@property (nonatomic, assign) BOOL hidesForSinglePage;
@property (nonatomic, assign) PageControlStyle pageControlStyle;
@property (nonatomic, assign) NSInteger strokeWidth, diameter, gapWidth;
@property (nonatomic) UIImage *thumbImage, *selectedThumbImage;
@property (nonatomic) NSMutableDictionary *thumbImageForIndex, *selectedThumbImageForIndex;

- (void)setThumbImage:(UIImage *)aThumbImage forIndex:(NSInteger)index;
- (UIImage *)thumbImageForIndex:(NSInteger)index;
- (void)setSelectedThumbImage:(UIImage *)aSelectedThumbImage forIndex:(NSInteger)index;
- (UIImage *)selectedThumbImageForIndex:(NSInteger)index;

@end

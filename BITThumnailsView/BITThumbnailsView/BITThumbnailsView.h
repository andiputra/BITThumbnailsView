//
//  BITThumbnailsView.h
//  BITThumnailsView
//
//  Created by Andi Putra on 26/06/12.
//  Copyright (c) 2012 BitsnPixel. All rights reserved.
//

struct BITMargin {
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
    CGFloat left;
};
typedef struct BITMargin BITMargin;

static inline BITMargin
BITMarginMake(CGFloat top, CGFloat right, CGFloat bottom, CGFloat left)
{
    BITMargin margin;
    margin.top = top;
    margin.right = right;
    margin.bottom = bottom;
    margin.left = left;
    return margin;
}

typedef enum {
    BITThumbnailsViewTypeHorizontal = 0,
    BITThumbnailsViewTypeVertical,
} BITThumbnailsViewType;

@class BITThumbnailsView;
@protocol BITThumbnailsViewDataSource <NSObject>

- (NSInteger)numberOfItemsInScrollView;
- (UIView *)scrollView:(BITThumbnailsView *)scrollView viewForItemAtIndex:(NSInteger)index;

@end

@protocol BITThumbnailsViewDelegate <NSObject>

@optional
- (void)scrollView:(BITThumbnailsView *)scrollView didTapItemAtIndex:(NSInteger)index;
/** If paging is not enabled, index will always be zero. */
- (void)scrollView:(BITThumbnailsView *)scrollView didScrollToPageAtIndex:(NSInteger)index;

@end

@interface BITThumbnailsView : UIScrollView <UIScrollViewDelegate>

/** Default thumbnail size is 100., 100. */
@property (unsafe_unretained, nonatomic) CGSize thumbnailSize;
@property (unsafe_unretained, nonatomic) BITMargin margin;
@property (unsafe_unretained, nonatomic) id<BITThumbnailsViewDataSource> tDataSource;
@property (unsafe_unretained, nonatomic) id<BITThumbnailsViewDelegate> tDelegate;
@property (unsafe_unretained, nonatomic) BITThumbnailsViewType type;

/** You need to call this after you setup the thumbnail scroll view for now. */
- (void)reloadThumbnailsScrollView;

/** If paging is enabled, allows you to jump to a certain page by providing the page index. */
/** Animated by default. */
- (void)jumpToPageAtIndex:(NSInteger)index;
- (void)jumpToPageAtIndex:(NSInteger)index animated:(BOOL)animated;

/** If paging is enabled, will return number of pages. 
 * If paging is not enabled, will return 1.
 */
- (NSInteger)numberOfPages;

@end

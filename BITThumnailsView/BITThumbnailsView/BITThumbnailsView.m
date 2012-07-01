//
//  BITThumbnailsView.m
//  BITThumnailsView
//
//  Created by Andi Putra on 26/06/12.
//  Copyright (c) 2012 BitsnPixel. All rights reserved.
//

#import "BITThumbnailsView.h"

@interface BITThumbnailsView ()

@property (strong, nonatomic) NSMutableSet *visibleItems;
@property (strong, nonatomic) NSMutableSet *recycledItems;
@property (unsafe_unretained, nonatomic) NSInteger numberOfItemsForEachRow;
@property (unsafe_unretained, nonatomic) NSInteger numberOfItemsForEachColumn;
@property (unsafe_unretained, nonatomic) NSInteger numberOfItemsForEachPage;
@property (unsafe_unretained, nonatomic) CGFloat widthWithMarginForEachItem;
@property (unsafe_unretained, nonatomic) CGFloat heightWithMarginForEachItem;

- (void)initialize;
- (CGSize)contentSizeForSelectedType;
- (void)tileSubviews;
- (BOOL)isDisplayingItemAtIndex:(NSInteger)index;
- (CGRect)frameForSubviewContainerAtIndex:(NSInteger)index;
- (void)resetVisibleAndRecycledSets;

@end

@implementation BITThumbnailsView
@synthesize thumbnailSize = _thumbnailSize;
@synthesize margin = _margin;
@synthesize tDataSource = _tDataSource;
@synthesize tDelegate = _tDelegate;
@synthesize type = _type;
@synthesize visibleItems = _visibleItems;
@synthesize recycledItems = _recycledItems;
@synthesize numberOfItemsForEachRow = _numberOfItemsForEachRow;
@synthesize numberOfItemsForEachColumn = _numberOfItemsForEachColumn;
@synthesize numberOfItemsForEachPage = _numberOfItemsForEachPage;
@synthesize widthWithMarginForEachItem = _widthWithMarginForEachItem;
@synthesize heightWithMarginForEachItem = _heightWithMarginForEachItem;

- (void)dealloc
{
    [_visibleItems release], _visibleItems = nil;
    [_recycledItems release], _recycledItems = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _visibleItems = [[NSMutableSet alloc] init];
    _recycledItems = [[NSMutableSet alloc] init];
    _thumbnailSize = CGSizeMake(100., 100.);
    
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

#pragma mark - Public Methods

- (void)reloadThumbnailsScrollView
{
    self.contentSize = [self contentSizeForSelectedType];
    [self resetVisibleAndRecycledSets];
    [self tileSubviews];
}

- (void)jumpToPageAtIndex:(NSInteger)index
{
    if (![self isPagingEnabled]) {
        return;
    }
    CGPoint offset;
    if (_type == BITThumbnailsViewTypeHorizontal) {
        offset = CGPointMake(self.frame.size.width * index, 0.);
    } else {
        offset = CGPointMake(0., self.frame.size.height * index);
    }
    [self setContentOffset:offset animated:YES];
}

- (NSInteger)numberOfPages
{
    if (_tDataSource && [_tDataSource conformsToProtocol:@protocol(BITThumbnailsViewDataSource)] && [_tDataSource respondsToSelector:@selector(numberOfItemsInScrollView)] && [self isPagingEnabled]) {
        double totalNumberOfItems = (double)[_tDataSource numberOfItemsInScrollView];
        double numberOfItemsOnPage = (double)_numberOfItemsForEachPage;
        NSInteger numberOfPages = ceil(totalNumberOfItems/numberOfItemsOnPage);
        
        return numberOfPages;
    }
    return 1;
}

// Unfinished, private for now
- (UIView *)viewAtIndex:(NSInteger)index
{
    UIView *viewAtIndex = nil;
    for (UIView *view in self.visibleItems) {
        if (view.tag == index) {
            viewAtIndex = view;
            break;
        }
    }
    
    // If the view is not found within visible items...create a new one and add it to visible items? Makes sense to me, need to think about it more.
    
    return viewAtIndex;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tileSubviews];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([_tDelegate conformsToProtocol:@protocol(BITThumbnailsViewDelegate)] && [_tDelegate respondsToSelector:@selector(scrollView:didScrollToPageAtIndex:)]) {
        
        NSInteger index;
        if (_type == BITThumbnailsViewTypeHorizontal) {
            index = scrollView.contentOffset.x / self.frame.size.width;
        } else {
            index = scrollView.contentOffset.y / self.frame.size.height;
        }
        [_tDelegate scrollView:self didScrollToPageAtIndex:index];
    }
}

#pragma mark - Private Methods

- (void)setupCalculationVariables
{
    // 2. Check margin for each item. 
    // Add the left margin + right margin + item width. We'll get total width for each item.
    // Add the top margin + bottom margin + item height. We'll get total height for each item.
    _widthWithMarginForEachItem = _thumbnailSize.width + _margin.left + _margin.right;
    _heightWithMarginForEachItem = _thumbnailSize.height + _margin.top + _margin.bottom;
    
    _numberOfItemsForEachRow = floor(self.frame.size.width / _widthWithMarginForEachItem);
    _numberOfItemsForEachColumn = floor(self.frame.size.height / _heightWithMarginForEachItem);
    
    // 3. Calculate the number of items that can fit on each page.
    // Number of items per page = number of items per row * number of items per column.
    _numberOfItemsForEachPage = _numberOfItemsForEachRow * _numberOfItemsForEachColumn;
}

- (CGSize)contentSizeForSelectedType
{
    CGSize contentSize;
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    // 1. Check total number of items
//    NSInteger totalNumberOfItems = [_tDataSource numberOfItemsInScrollView];

    // Need to convert the integers to double in order for the ceil() function to return the correct value, not truncated one.
    double dbTotalNumberOfItems = (double)[_tDataSource numberOfItemsInScrollView];
    double dbNumberOfItemsForEachPage = (double)_numberOfItemsForEachPage;
    NSInteger numberOfPages = ceil(dbTotalNumberOfItems / dbNumberOfItemsForEachPage);
    
    if (_type == BITThumbnailsViewTypeHorizontal) {
        
        if ([self isPagingEnabled]) {
            
            width = numberOfPages * self.frame.size.width;
            
        } else {
            
            NSInteger numberOfColumns = ceil(dbTotalNumberOfItems / _numberOfItemsForEachColumn);
            width = numberOfColumns * _widthWithMarginForEachItem;
            
        }
        
    } else {
        
        if ([self isPagingEnabled]) {
            
            height = numberOfPages * self.frame.size.height;
            
        } else {
            
            NSInteger numberOfRows = ceil(dbTotalNumberOfItems / _numberOfItemsForEachRow);
            height = numberOfRows * _heightWithMarginForEachItem;
            
        }
        
    }
    
    contentSize = CGSizeMake(width, height);
    return contentSize;
}

- (void)tileSubviews
{
    CGRect visibleBounds = self.bounds;
    
    NSInteger firstVisibleItemIndex = floor(CGRectGetMinX(visibleBounds) / _widthWithMarginForEachItem);
    NSInteger itemCountForEachRow;
    NSInteger itemCountForEachColumn;
    
    if (_type == BITThumbnailsViewTypeHorizontal) {
        itemCountForEachRow = ceil(CGRectGetMaxX(visibleBounds) / _widthWithMarginForEachItem);
        itemCountForEachColumn = floor(CGRectGetMaxY(visibleBounds) / _heightWithMarginForEachItem);
    } else {
        itemCountForEachRow = floor(CGRectGetMaxX(visibleBounds) / _widthWithMarginForEachItem);
        itemCountForEachColumn = ceil(CGRectGetMaxY(visibleBounds) / _heightWithMarginForEachItem);
    }
    
    // Need to substract by 1, as the returned value will be the count
    NSInteger lastVisibleItemIndex = (itemCountForEachRow * itemCountForEachColumn) - 1;
    
    firstVisibleItemIndex = MAX(firstVisibleItemIndex, 0);
    lastVisibleItemIndex = MIN(lastVisibleItemIndex, ([_tDataSource numberOfItemsInScrollView] - 1));
    
    NSSet *visible = [[_visibleItems copy] autorelease];
    for (UIView *view in visible) {
        if (view.tag < firstVisibleItemIndex || view.tag > lastVisibleItemIndex) {
            [_recycledItems addObject:view];
            [view removeFromSuperview];
        }
    }
    [_visibleItems minusSet:_recycledItems];
    
    for (int i = firstVisibleItemIndex; i <= lastVisibleItemIndex; i++) {
        
        if (![self isDisplayingItemAtIndex:i]) {
            
            UIView *subviewContainer = [[UIView alloc] initWithFrame:[self frameForSubviewContainerAtIndex:i]];
            subviewContainer.clipsToBounds = YES;
            subviewContainer.tag = i;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapThumbnail:)];
            [subviewContainer addGestureRecognizer:tap];
            [tap release];
            
            UIView *subview = [_tDataSource scrollView:self viewForItemAtIndex:i];
            [subview setFrame:CGRectMake(0., 0., subview.frame.size.width, subview.frame.size.height)];
            [subviewContainer addSubview:subview];
            
            [self addSubview:subviewContainer];
            [_visibleItems addObject:subviewContainer];
            [subviewContainer release];
            
        }
        
    }
}

- (BOOL)isDisplayingItemAtIndex:(NSInteger)index
{
    BOOL isVisible = NO;
    NSSet *visible = [[_visibleItems copy] autorelease];
    for (UIView *view in visible) {
        if (view.tag == index) {
            isVisible = YES;
            break;
        }
    }
    return isVisible;
}

- (CGRect)frameForSubviewContainerAtIndex:(NSInteger)index
{
    int pageIndex = floor(index/(double)_numberOfItemsForEachPage);
    int rowIndex;
    int columnIndex;
    
    CGFloat positionX;
    CGFloat positionY;
    
    if (_type == BITThumbnailsViewTypeHorizontal) {
        
        CGFloat pageWidth = 0.;
        rowIndex = index;
        if (rowIndex > (_numberOfItemsForEachColumn - 1)) {
            rowIndex = (index % _numberOfItemsForEachColumn);
        }
        
        if ([self isPagingEnabled]) {
            pageWidth = (self.frame.size.width * pageIndex);
            columnIndex = floor((index - (pageIndex * _numberOfItemsForEachPage))/(double)_numberOfItemsForEachColumn);
        } else {
            columnIndex = index/(double)_numberOfItemsForEachColumn;
        }
        
        positionX = (_margin.left * (columnIndex + 1)) + (_margin.right * columnIndex) + (_thumbnailSize.width * columnIndex) + pageWidth;
        positionY = (_margin.top * (rowIndex + 1)) + (_margin.bottom * rowIndex) + (_thumbnailSize.height * rowIndex);
        
    } else {
        
        CGFloat pageHeight = 0.;
        columnIndex = index;
        if (columnIndex > (_numberOfItemsForEachRow - 1)) {
            columnIndex = (index % _numberOfItemsForEachRow);
        }
        
        if ([self isPagingEnabled]) {
            pageHeight = (self.frame.size.height * pageIndex);
            rowIndex = floor((index - (pageIndex * _numberOfItemsForEachPage))/(double)_numberOfItemsForEachRow);
        } else {
            rowIndex = index/(double)_numberOfItemsForEachRow;
        }
        
        positionX = (_margin.left * (columnIndex + 1)) + (_margin.right * columnIndex) + (_thumbnailSize.width * columnIndex);
        positionY = (_margin.top * (rowIndex + 1)) + (_margin.bottom * rowIndex) + (_thumbnailSize.height * rowIndex) + pageHeight;
        
    }
    
    return CGRectMake(positionX, positionY, _thumbnailSize.width, _thumbnailSize.height);
    
}

- (void)resetVisibleAndRecycledSets
{
    for (UIView *view in _visibleItems) {
        [view removeFromSuperview];
    }
    [_visibleItems removeAllObjects];
    [_recycledItems removeAllObjects];
}

- (void)didTapThumbnail:(UITapGestureRecognizer *)recognizer
{
    UIView *thumbnail = [recognizer view];
    if ([_tDelegate conformsToProtocol:@protocol(BITThumbnailsViewDelegate)] && [_tDelegate respondsToSelector:@selector(scrollView:didTapItemAtIndex:)]) {
        [_tDelegate scrollView:self didTapItemAtIndex:thumbnail.tag];
    }
}

#pragma mark - Accessors

- (void)setThumbnailSize:(CGSize)thumbnailSize
{
    _thumbnailSize = thumbnailSize;
    [self setupCalculationVariables];
}

- (void)setMargin:(BITMargin)margin
{
    _margin = margin;
    [self setupCalculationVariables];
}

@end

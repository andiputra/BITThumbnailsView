//
//  ViewController.m
//  BITThumnailsView
//
//  Created by Andi Putra on 26/06/12.
//  Copyright (c) 2012 BitsnPixel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize thumbnailsView = _thumbnailsView;

- (void)dealloc
{
    [_thumbnailsView release], _thumbnailsView = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.thumbnailsView.thumbnailSize = CGSizeMake(100., 120.);
    self.thumbnailsView.margin = BITMarginMake(10., 0., 0., 10.);
    self.thumbnailsView.type = BITThumbnailsViewTypeHorizontal;
    self.thumbnailsView.pagingEnabled = YES;
    self.thumbnailsView.tDelegate = self;
    self.thumbnailsView.tDataSource = self;
    
    [self.thumbnailsView reloadThumbnailsScrollView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.thumbnailsView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - BITThumbnailsViewDataSource

- (NSInteger)numberOfItemsInScrollView
{
    return 200;
}

- (UIView *)scrollView:(BITThumbnailsView *)scrollView viewForItemAtIndex:(NSInteger)index
{
    UIView *awesomeView = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., scrollView.thumbnailSize.width, scrollView.thumbnailSize.height)] autorelease];
    awesomeView.backgroundColor = [UIColor blackColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0., 0., scrollView.thumbnailSize.width, scrollView.thumbnailSize.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"Thumb %d", index];
    label.textAlignment = UITextAlignmentCenter;
    [awesomeView addSubview:label];
    [label release];
    
    return awesomeView;
}

#pragma mark - BITThumbnailsViewDelegate

- (void)scrollView:(BITThumbnailsView *)scrollView didTapItemAtIndex:(NSInteger)index
{
    NSLog(@"Thumnail %d tapped!", index);
}

@end

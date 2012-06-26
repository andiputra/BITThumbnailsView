//
//  ViewController.h
//  BITThumnailsView
//
//  Created by Andi Putra on 26/06/12.
//  Copyright (c) 2012 BitsnPixel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BITThumbnailsView.h"

@interface ViewController : UIViewController <BITThumbnailsViewDataSource, BITThumbnailsViewDelegate>

@property (strong, nonatomic) IBOutlet BITThumbnailsView *thumbnailsView;

@end

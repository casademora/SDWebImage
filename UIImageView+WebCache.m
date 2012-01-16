/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import <objc/runtime.h>

typedef enum {
    SDUIImageViewTransitionOptionNone               = 0,
    SDUIImageViewTransitionOptionFade               = 1 << 0,
    SDUIImageViewTransitionOptionHorizontalFlip     = 1 << 1
} SDWebimageUIImageViewTransitionOption;


@implementation UIImageView (WebCache)

- (void) setDownloadImageTransitionOptions:(NSUInteger)options;
{
    objc_setAssociatedObject(self, @"downloadTransitionOption", [NSNumber numberWithUnsignedInteger:options], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger) downloadImageTransitionOptions;
{
    NSNumber *options = objc_getAssociatedObject(self, @"downloadTransitionOption");
    return [options unsignedIntegerValue];
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    self.image = placeholder;

    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options];
    }
}

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    NSUInteger options = self.downloadImageTransitionOptions;
    
    if ((options & SDUIImageViewTransitionOptionNone) == 0)
    {
        self.image = image;
    }
    else if (options & SDUIImageViewTransitionOptionFade)
    {        
        [UIView animateWithDuration:.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished)
        {
            self.image = image;
            
            [UIView animateWithDuration:.25 animations:^{
                self.alpha = 1;
            }];
        }];
    }
}

@end

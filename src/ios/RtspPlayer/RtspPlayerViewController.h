//
//  RtspPlayerViewController.h
//  Pager
//
//  Created by Tibor Bence Gore on 2018. 11. 21..
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MediaPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RtspPlayerViewController : UIViewController<MediaPlayerCallback>

    @property NSString *videoUrl;

@end

NS_ASSUME_NONNULL_END

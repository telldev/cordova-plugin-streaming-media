//
//  RtspPlayerViewController.m
//  Pager
//
//  Created by Tibor Bence Gore on 2018. 11. 21..
//

#import "RtspPlayerViewController.h"

@interface RtspPlayerViewController ()

@end

@implementation RtspPlayerViewController {
    __weak IBOutlet UIView *videoBaseView;
    __weak IBOutlet UIActivityIndicatorView *streamLoadingIndicatorView;
    
    MediaPlayer* player;
    MediaPlayerConfig* mediaConfig;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupStream:self.videoUrl];
}

- (void)setupStream:(NSString *)withUrlString {
    
    mediaConfig    = [[MediaPlayerConfig alloc] init];
    
    mediaConfig.decodingType               = 1; // 1 - hardware, 0 - software
    mediaConfig.synchroEnable              = 1; // syncronization mediaConfig
    mediaConfig.synchroNeedDropVideoFrames = 1; // synchroNeedDropVideoFrames
    mediaConfig.aspectRatioMode            = 1;
    mediaConfig.connectionNetworkProtocol  = -1; // // 0 - udp, 1 - tcp, 2 - http, 3 - https, -1 - AUTO
    mediaConfig.connectionDetectionTime    = 1000; // in milliseconds
    mediaConfig.connectionTimeout          = 20000;
    mediaConfig.decoderLatency             = 0;
    
    mediaConfig.connectionUrl = withUrlString;
    
    [streamLoadingIndicatorView startAnimating];
    player  = [[MediaPlayer alloc] init: [videoBaseView bounds]];
    [videoBaseView addSubview: [player contentView]];
    [videoBaseView sendSubviewToBack: [player contentView]];
    
    [mediaConfig setPlayerMode:PP_MODE_ALL];
    [player Open:mediaConfig callback: self];
    
}


- (IBAction)closeButtonAction:(UIButton *)sender {
    
    if (player) {
        [player Close];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showError: (NSString*) title msg: (NSString*) msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* code = [UIAlertController alertControllerWithTitle:title message: msg preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *confirmCancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
        [code addAction:confirmCancel];
        [self presentViewController:code animated:YES completion:nil];
    });
}

- (int)Status:(MediaPlayer *)player args:(int)arg {
    MediaPlayerNotifyCodes nc = arg;
    switch (nc) {
        case PLP_EOS: {
            
        } break;
        case PLP_ERROR: {
            [self showError:@"Error" msg: @"Something wrong with pipeline"];
            [player Close];
        } break;
        case PLP_TRIAL_VERSION: {
            // close and start again
            dispatch_async(dispatch_get_main_queue(), ^{
                [player Close];
                [self setupStream:self.videoUrl];
            });
        } break;
        case PLP_PLAY_SUCCESSFUL:
        case PLP_PLAY_PLAY: {
            NSLog(@"Start playing");
        } break;
        case VRP_FIRSTFRAME: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [streamLoadingIndicatorView stopAnimating];
            });
        } break;
        default: {
            NSLog(@"<binary> Notify code : %d", arg);
        } break;
    }
    
    return 0;
}

@end

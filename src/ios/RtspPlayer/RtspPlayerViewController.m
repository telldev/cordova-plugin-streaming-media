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
    __weak IBOutlet UIButton *closeButton;
    
    MediaPlayer* player;
    MediaPlayerConfig* mediaConfig;
    
    NSTimer* timeoutTimer;

    BOOL isClose;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [closeButton setImage:[UIImage imageNamed:@"RtspPlayer.bundle/icn_close"] forState:UIControlStateNormal];
    [closeButton.layer setCornerRadius:8];

    [self setupStream:self.videoUrl];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:self];
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

    isClose = NO;
    [player Open:mediaConfig callback: self];
    
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:25 target:self selector:@selector(timeoutHandler:) userInfo:nil repeats:NO];
    
}


- (IBAction)closeButtonAction:(UIButton *)sender {
    isClose = YES;
    
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

- (void)timeoutHandler:(NSTimer *)timer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self invalidateTimeoutTimer];
        [self->player Close];
        [self dismissViewControllerAnimated:YES completion:nil];
        self.errorHandler(@"RTSP_TIMEOUT");
    });
}

- (void)invalidateTimeoutTimer {
    if (self->timeoutTimer != nil ) {
        [self->timeoutTimer invalidate];
        self->timeoutTimer = nil;
    }
}

- (int)Status:(MediaPlayer *)player args:(int)arg {
    MediaPlayerNotifyCodes nc = arg;
    switch (nc) {
        case PLP_EOS: {
            
        } break;
        case CP_CONNECT_FAILED:
        case PLP_ERROR: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self invalidateTimeoutTimer];
                [self->player Close];
                [self dismissViewControllerAnimated:YES completion:nil];
                if ( !self->isClose ) {
                    self.errorHandler(@"RTSP_ERROR");
                }
            });
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [self invalidateTimeoutTimer];
                if ( !self->isClose ) {
                    self.successHandler();
                }
            });
        } break;
        case VRP_FIRSTFRAME: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->streamLoadingIndicatorView stopAnimating];
            });
        } break;
        default: {
            NSLog(@"<binary> Notify code : %d", arg);
        } break;
    }
    
    return 0;
}

@end

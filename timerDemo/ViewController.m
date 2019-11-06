//
//  ViewController.m
//  timerDemo
//
//  Created by lifevc on 2019/11/6.
//  Copyright © 2019 lifevc. All rights reserved.
//

#import "ViewController.h"
#import "ViewController1.h"
#import "ViewControllers.h"
NSString *kRegisteTimeKey = @"kRegisteTimeKey";
NSString *kRegistePhoneKey = @"kRegistePhoneKey";
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *yanZMBtn;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
@property (nonatomic) BOOL doCaptcha;
@property (nonatomic, strong) NSTimer *countTimer;
@property (nonatomic, assign) NSInteger timedown;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
      self.backgroundTaskId = UIBackgroundTaskInvalid;
        NSDate *preDate = [[NSUserDefaults standardUserDefaults] objectForKey:kRegisteTimeKey];
        NSInteger tick = [[NSDate date] timeIntervalSinceDate:preDate];
        if (preDate &&  tick < 60 && tick > 0) {
    //        NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:kRegistePhoneKey];
    //        self.phoneTextField.text = phone;
            [self buildTimeTicker:60 - tick];
        } else {
            [self buildTimeTicker:0];
        }
        _timedown = 60;
}
- (void)buildTimeTicker:(NSInteger)tick {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if (self.backgroundTaskId == UIBackgroundTaskInvalid && !self->_yanZMBtn.enabled) {
            UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
            self.backgroundTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
                [application endBackgroundTask:self.backgroundTaskId];
                self.backgroundTaskId = UIBackgroundTaskInvalid;
            }];
        }
    }];
    if (tick > 0 && tick < 60) {
        [self tickdown:tick];
    }
}
- (NSTimer *)countTimer{
    if (!_countTimer) {
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    return _countTimer;
}
- (IBAction)click:(id)sender {
    [self setPhoneTickInfo:NO];
    [self tickdown:60];
}
- (void)tickdown:(NSInteger)tick{
    self.doCaptcha = YES;
    self.yanZMBtn.enabled = NO;
    __block NSInteger timedown = tick;
    [self.yanZMBtn setTitle:[NSString stringWithFormat:@"倒计时（%lds）", (long)(timedown)] forState:UIControlStateNormal];
    [[NSRunLoop mainRunLoop] addTimer:self.countTimer forMode:NSRunLoopCommonModes];
}
- (void)countDown{
    if (_timedown == 0) {
        [self.yanZMBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        self.yanZMBtn.enabled = YES;
        self.doCaptcha = NO;
        _timedown = 60;
        if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
            UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
            [application endBackgroundTask:self.backgroundTaskId];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
        }
        [self setPhoneTickInfo:YES];
    }else{
        [self.yanZMBtn setTitle:[NSString stringWithFormat:@"倒计时（%lds）", (long)(--_timedown)] forState:UIControlStateNormal];
    }
}
- (void)setPhoneTickInfo:(BOOL)reset {
    if (reset) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRegisteTimeKey];
//        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRegistePhoneKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kRegisteTimeKey];
//        [[NSUserDefaults standardUserDefaults] setObject:self.phoneTextField.text forKey:kRegistePhoneKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self presentViewController:[ViewControllers new] animated:YES completion:nil];
}
@end

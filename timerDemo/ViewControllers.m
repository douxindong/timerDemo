//
//  ViewControllers.m
//  timerDemo
//
//  Created by lifevc on 2019/11/6.
//  Copyright © 2019 lifevc. All rights reserved.
//

#import "ViewControllers.h"
#import "ReactiveObjC.h"
NSString *kRegisteTimeKeys = @"kRegisteTimeKeys";
NSString *kRegistePhoneKeys = @"kRegistePhoneKeys";
@interface ViewControllers ()
@property (weak, nonatomic) IBOutlet UIButton *yzmBtn;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
@property (nonatomic) BOOL doCaptcha;
@property (nonatomic, strong) NSTimer *countTimer;
@property (nonatomic, assign) NSInteger timedown;
@end

@implementation ViewControllers

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
      self.backgroundTaskId = UIBackgroundTaskInvalid;
        NSDate *preDate = [[NSUserDefaults standardUserDefaults] objectForKey:kRegisteTimeKeys];
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
        if (self.backgroundTaskId == UIBackgroundTaskInvalid && !self->_yzmBtn.enabled) {
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
    self.yzmBtn.enabled = NO;
    __block NSInteger timedown = tick;
    [self.yzmBtn setTitle:[NSString stringWithFormat:@"倒计时（%lds）", (long)(timedown)] forState:UIControlStateNormal];
//    [[NSRunLoop mainRunLoop] addTimer:self.countTimer forMode:NSRunLoopCommonModes];
    
    @weakify(self);
    [[[[[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] take:timedown] takeUntil:_yzmBtn.rac_willDeallocSignal] doNext:^(id x) {
        @strongify(self);
        [self.yzmBtn setTitle:[NSString stringWithFormat:@"倒计时（%lds）", (long)(--timedown)] forState:UIControlStateNormal];
    }] doCompleted:^{
        @strongify(self);
        [self.yzmBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        self.yzmBtn.enabled = YES;
        timedown = 60;
        if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
            UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
            [application endBackgroundTask:self.backgroundTaskId];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
        }
        self.doCaptcha = NO;
        [self setPhoneTickInfo:YES];
    }] subscribeNext:^(id x) {
        
    }];
}
- (void)countDown{
    if (_timedown == 0) {
        [self.yzmBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        self.yzmBtn.enabled = YES;
        self.doCaptcha = NO;
        _timedown = 60;
        if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
            UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
            [application endBackgroundTask:self.backgroundTaskId];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
        }
        [self setPhoneTickInfo:YES];
    }else{
        [self.yzmBtn setTitle:[NSString stringWithFormat:@"倒计时（%lds）", (long)(--_timedown)] forState:UIControlStateNormal];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setPhoneTickInfo:(BOOL)reset {
    if (reset) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRegisteTimeKeys];
//        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRegistePhoneKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kRegisteTimeKeys];
//        [[NSUserDefaults standardUserDefaults] setObject:self.phoneTextField.text forKey:kRegistePhoneKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

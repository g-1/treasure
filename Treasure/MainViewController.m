//
//  MainViewController.m
//  Treasure
//
//  Created by タカ on 2014/06/28.
//  Copyright (c) 2014年 Taka. All rights reserved.
//

#import "MainViewController.h"
#import "RiddleViewController.h"

@interface MainViewController ()

@property(nonatomic) CLLocationManager* locationManager;
@property(nonatomic) NSUUID* proximityUUID;
@property(nonatomic) CLBeaconRegion* beaconRegion;

@property(nonatomic, weak) IBOutlet UIView* baseMessage;
@property(nonatomic, weak) IBOutlet UILabel* enterMessageLabel;

//action
- (IBAction)tap:(id)sender;

//utility
- (void)setEnterMessage:(NSString*)message;
- (void)hideEnterMessage;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
    // CLLocationManagerの生成とデリゲートの設定
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    // 生成したUUIDからNSUUIDを作成
    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    
    // 観測するビーコン領域の作成
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                                major:0x0001
                                                                minor:0x0090
                                                           identifier:@"net.noumenon-th"];
    
    //以下はデフォルト値で設定されている
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;
    self.beaconRegion.notifyEntryStateOnDisplay = NO;
    
    // Beaconによる領域観測を開始
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if( [segue.identifier isEqualToString:@"riddle"] ){
    RiddleViewController* nextViewController = (RiddleViewController*)segue.destinationViewController;
    nextViewController.roomType = 0;//仮
  }
}

#pragma mark -utility
- (void)setEnterMessage:(NSString*)message
{
  self.baseMessage.hidden = NO;
  self.enterMessageLabel.hidden = NO;
  self.enterMessageLabel.text = message;
  [self.enterMessageLabel sizeToFit];
}

- (void)hideEnterMessage
{
  self.enterMessageLabel.hidden = YES;
  self.baseMessage.hidden = YES;
}

#pragma mark - delegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  NSLog(@"ビーコン領域に入りました");
  //self.enterMessageLabel.text = @"部屋に入りました";//仮
  [self setEnterMessage:@"部屋に入りました"];
  //(8F6633)背景カラー
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  NSLog(@"ビーコン領域を出ました");
  [self hideEnterMessage];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
  if (beacons.count > 0) {
    // 最も距離の近いBeaconについて処理する
    CLBeacon *nearestBeacon = beacons.firstObject;
    
    NSString *rangeMessage;
    
    // Beacon の距離でメッセージを変える
    switch (nearestBeacon.proximity) {
      case CLProximityImmediate:
        rangeMessage = @"ものすごく近い";
        break;
      case CLProximityNear:
        rangeMessage = @"近い";
        break;
      case CLProximityFar:
        rangeMessage = @"遠い";
        break;
      default:
        rangeMessage = @"よく分からない ";
        break;
    }
    
    // ローカル通知
    NSString *message = [NSString stringWithFormat:@"major:%@, minor:%@, accuracy:%f, rssi:%ld",
                         nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, (long)nearestBeacon.rssi];
    //[destLabel setText:rangeMessage];
    //[self sendLocalNotificationForMessage:[rangeMessage stringByAppendingString:message]];
  }
}


//新しい領域のモニタリングを開始したことを伝える
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
  [self.locationManager requestStateForRegion:region];
}


//モニタリングの結果を受けて、現在どのような状態かを知らせる
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
  switch (state) {
    case CLRegionStateInside:
      NSLog(@"ビーコン領域にいます");
      [self setEnterMessage:@"部屋に入りました"];
      break;
    case CLRegionStateOutside:
      NSLog(@"ビーコン領域外です");
      [self hideEnterMessage];
      break;
    case CLRegionStateUnknown:
      NSLog(@"どちらにいるのか良く分かりません");
      break;
    default:
      break;
  }
}


- (void)sendLocalNotificationForMessage:(NSString *)message
{
  UILocalNotification *localNotification = [UILocalNotification new];
  localNotification.alertBody = message;
  localNotification.fireDate = [NSDate date];
  localNotification.soundName = UILocalNotificationDefaultSoundName;
  [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


#pragma mark - action
- (IBAction)tap:(id)sender
{
  [self performSegueWithIdentifier:@"riddle" sender:sender];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

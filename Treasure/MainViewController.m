//
//  MainViewController.m
//  Treasure
//
//  Created by タカ on 2014/06/28.
//  Copyright (c) 2014年 Taka. All rights reserved.
//

#import "MainViewController.h"
#import "RiddleViewController.h"

#import "RoomType.h"

@interface MainViewController ()

@property(nonatomic) CLLocationManager* locationManager;
@property(nonatomic) NSUUID* proximityUUID;
@property(nonatomic) CLBeaconRegion* beaconRegion;
@property(nonatomic) int roomType;

@property(nonatomic, weak) IBOutlet UIView* baseMessage;
@property(nonatomic, weak) IBOutlet UILabel* enterMessageLabel;
@property(nonatomic, weak) IBOutlet UIButton* riddleButton;

//utility
- (void)setEnterMessage:(NSString*)message;
- (void)hideEnterMessage;
- (int)getRoomType:(CLBeacon*)beacon;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    _roomType = RoomType_END;
  }
  return self;
}

- (void)viewDidLoad
{
  NSLog(@"viewDidLoad");
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
    
    //動作権限
    [self.locationManager requestAlwaysAuthorization];
    
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
  RiddleViewController* nextViewController = (RiddleViewController*)segue.destinationViewController;
  nextViewController.roomType = self.roomType;//仮
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

- (int)getRoomType:(CLBeacon*)beacon
{
  unsigned int const major = [beacon.major unsignedIntValue];
  unsigned int const minor = [beacon.minor unsignedIntValue];
  
  if(major == 0x0001 && minor == 0x0006){
    return RoomType_01;
  }else if(major == 0x0002 && minor == 0x0008){
    return RoomType_02;
  }else if(major == 0x0003 && minor == 0x0003){
    return RoomType_03;
  }else if(major == 0x0001 && minor == 0x0090){
    return RoomType_04;
  }else if(major == 0x0001 && minor == 0x0005){
    return RoomType_05;
  }else if(major == 0x0003 && minor == 0x0c30){
    return RoomType_ENTRANCE;
  }else if(major == 0x0002 && minor == 0x0510){
    return RoomType_ALASKA;
  }else if(major == 0x0100 && minor == 0x0036){
    return RoomType_AMAZON;
  }else if(major == 0x0002 && minor == 0x01ff){
    return RoomType_TEXAS;
  }else if(major == 0x0100 && minor == 0x00c1){
    return RoomType_SHANGHAI;
  }
  
  return RoomType_END;
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
    CLBeacon* nearestBeacon = beacons.firstObject;
    
    NSString* rangeMessage;
    
    // Beacon の距離でメッセージを変える
    self.riddleButton.hidden = YES;
    switch (nearestBeacon.proximity) {
      case CLProximityImmediate:
        rangeMessage = @"ものすごく近い";
        self.riddleButton.hidden = NO;
        self.roomType = [self getRoomType:nearestBeacon];
        break;
      case CLProximityNear:
        rangeMessage = @"近い";
        self.riddleButton.hidden = NO;
        self.roomType = [self getRoomType:nearestBeacon];
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

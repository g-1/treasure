//
//  RiddleViewController.m
//  Treasure
//
//  Created by タカ on 2014/06/28.
//  Copyright (c) 2014年 Taka. All rights reserved.
//

#import "RiddleViewController.h"

@interface RiddleViewController ()

@property(nonatomic, weak) IBOutlet UILabel* riddleTitle;

@end

@implementation RiddleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    _roomType = 0;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  switch (self.roomType) {
    case 0:
      self.riddleTitle.text = @"ナゾ001";
      break;
      
    default:
      break;
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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

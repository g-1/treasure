//
//  ViewController.m
//  Treasure
//
//  Created by タカ on 2014/06/28.
//  Copyright (c) 2014年 Taka. All rights reserved.
//

#import "TitleViewController.h"

@interface TitleViewController ()

- (IBAction)tap:(id)sender;

@end

@implementation TitleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tap:(id)sender
{
  [self performSegueWithIdentifier:@"main" sender:sender];
}

@end

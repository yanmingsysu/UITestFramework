//
//  BDIOSPYViewController.m
//  BDiOSpy
//
//  Created by yanmingsysu on 12/05/2019.
//  Copyright (c) 2019 yanmingsysu. All rights reserved.
//

#import "BDIOSPYViewController.h"
#import <malloc/malloc.h>

@interface BDIOSPYViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation BDIOSPYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.items = [NSMutableArray arrayWithCapacity:100];
    for (int i = 0; i < 100; i++) {
        [self.items addObject:@{@"name":[NSString stringWithFormat:@"Cell %d", i]}];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *item = self.items[indexPath.row];
    cell.textLabel.text = item[@"name"];
    UIButton *btn = [cell viewWithTag:1];
    [btn setTitle:[NSString stringWithFormat:@"ShowDetail_%lu", indexPath.row] forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)onClick:(UIButton *)sender {
    CGPoint p = [sender convertPoint:CGPointMake(0, 0) toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Detail %lu", indexPath.row];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

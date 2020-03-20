//
//  ViewController.m
//  HelloDemo
//
//  Created by Lin Yong on 2020/1/15.
//  Copyright © 2020 ByteDance. All rights reserved.
//

#import "ViewController.h"
#import <malloc/malloc.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [NSMutableArray arrayWithCapacity:100];
    for (int i = 0; i < 100; i++) {
        [self.items addObject:[@{@"name":[NSString stringWithFormat:@"Cell %d", i], @"showed": @(NO)} mutableCopy]];
    }
    
    NSLog(@"start time=%@", NSDate.now);
    NSData *d = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://127.0.0.1"]]; // network access trigger
    NSLog(@"end time=%@ networ trigger received %lu", NSDate.now, d.length);
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
    if ([item[@"showed"] boolValue]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Detail %ld", indexPath.row];
    }
    else {
        cell.detailTextLabel.text = @"Detail";
    }
    UIButton *btn = [cell viewWithTag:1];
    [btn setTitle:[NSString stringWithFormat:@"ShowDetail_%ld", indexPath.row] forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)onClick:(UIButton *)sender {
    CGPoint p = [sender convertPoint:CGPointMake(0, 0) toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Detail %ld", indexPath.row];
    NSMutableDictionary *item = self.items[indexPath.row];
    item[@"showed"] = @(YES);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end

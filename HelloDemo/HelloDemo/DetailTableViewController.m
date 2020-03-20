//
//  DetailTableViewController.m
//  HelloDemo
//
//  Created by Lin Yong on 2020/2/13.
//  Copyright © 2020 ByteDance. All rights reserved.
//

#import "DetailTableViewController.h"
#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>

#define DEBUG_DISM_ALERT (NO)

@interface DetailTableViewController () <NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *lpLabel;
@property (weak, nonatomic) IBOutlet UILabel *lpdLabel;
@property (weak, nonatomic) IBOutlet UILabel *slideLabel;

@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)onLongPress:(id)sender {
    self.lpdLabel.text = @"你好";
    [self.lpdLabel sizeToFit];
}

- (IBAction)onSlideBar:(id)sender {
    self.slideLabel.text = [NSString stringWithFormat:@"%.1f", ((UISlider *)sender).value];
    [self.slideLabel sizeToFit];
}

- (void)logState {
    NSLog(@"curr state: %ld", (long)[UIApplication sharedApplication].applicationState);
    if (DEBUG_DISM_ALERT) {
        [self sendDismissRequest];
    }
}

- (IBAction)showAlert:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Current password";
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Current password %@", [[alertController textFields][0] text]);
        //compare the current password and do action here

    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
        
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    [self performSelector:@selector(logState) withObject:nil afterDelay:0.3f];
}

- (IBAction)createAppSheet:(UIButton *)sender
{
    UIAlertController *alerController =
    [UIAlertController alertControllerWithTitle:@"Magic Sheet"
                                        message:@"Should read"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIPopoverPresentationController *popPresenter = [alerController popoverPresentationController];
    popPresenter.sourceView = sender;
    [alerController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

         // Cancel button tappped.
         [self dismissViewControllerAnimated:YES completion:^{
         }];
     }]];

     [alerController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {

         // Distructive button tapped.
         [self dismissViewControllerAnimated:YES completion:^{
         }];
     }]];

     [alerController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

         // OK button tapped.

         [self dismissViewControllerAnimated:YES completion:^{
         }];
     }]];
    [self presentViewController:alerController animated:YES completion:nil];
    [self performSelector:@selector(logState) withObject:nil afterDelay:0.3f];
}


- (IBAction)showNotificationAlert:(id)sender {
      [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    [self performSelector:@selector(logState) withObject:nil afterDelay:0.3f];
}

- (IBAction)showCameraAlert:(id)sender {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    }];
    [self performSelector:@selector(logState) withObject:nil afterDelay:0.3f];
}

- (void)sendDismissRequest {
    NSError *error;

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"http://localhost:8088"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [request setHTTPMethod:@"POST"];
    NSDictionary *mapData = @{@"method": @"dismissAlert",
                              @"id": @"1",
                              @"params": @{
                                      @"bundle_id": @"com.bytedance.demo.HelloDemo",
                                      @"button_text": @[@"OK", @"Allow"],
                                      @"timeout": @(1),
                            }};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    [request setHTTPBody:postData];


    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response: %@， err: %@", response, error);
    }];

    [postDataTask resume];
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

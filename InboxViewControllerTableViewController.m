//
//  InboxViewControllerTableViewController.m
//  snapchatRibbit
//
//  Created by Vetri Selvi Vairamuthu on 7/9/15.
//  Copyright (c) 2015 Vetri Selvi Vairamuthu. All rights reserved.
//



#import "InboxViewControllerTableViewController.h"
#import "ImageViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
@interface InboxViewControllerTableViewController ()

@end

@implementation InboxViewControllerTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] init];

    PFUser *currentUser = [PFUser currentUser];
    
//    if(currentUser) {
//        NSLog(@"Current User : %@", currentUser.username);
//        self.title = @"Inbox";
//        [self.navigationItem setHidesBackButton:YES animated:YES];
//
//    }
//    else{
//     [self.navigationItem setHidesBackButton:YES animated:YES];
//   
//    [self performSegueWithIdentifier:@"ShowLogin" sender:self];
//    CALayer* ca = [[CALayer alloc] init];
//
//    [ca setFrame:self.view.bounds];
//
////        [self.navigationItem setHidesBackButton:YES animated:YES];
//       // [self.navigationController.tabBarController.navigationItem setHidesBackButton:YES animated:NO];
//
//        
//    }
    PFUser *currentuser = [PFUser currentUser];
    
    if(currentuser) {
        NSLog(@"Current User : %@", currentuser.username);
        self.title = @"Inbox";
        [self.navigationItem setHidesBackButton:YES animated:YES];
        
    }
    else{
        
        [self performSegueWithIdentifier:@"ShowLogin" sender:self];
        //[self.navigationItem setHidesBackButton:YES animated:YES];
        
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    PFQuery *recipientId = [[PFUser currentUser] objectId];
    if(recipientId)
    {
        [query whereKey:@"recipientsId" equalTo:[[PFUser currentUser] objectId]];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            else
            {
                // We found messages!
                self.messages = objects;
                [self.tableView reloadData];
                NSLog(@"Retrieved %lu messages", (unsigned long)[self.messages count]);
            }
        }];
    }
    else
    {
        // [self.navigationItem setHidesBackButton:YES animated:YES];
        [self performSegueWithIdentifier:@"ShowLogin" sender:self];
    }
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" ];
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = [message objectForKey:@"senderName"];
    
    NSString *fileType = [message objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"showImage" sender:self];
    }
    else {
        // File type is video
        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"];
        NSURL *fileUrl = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileUrl;
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        // Add it to the view controller so we can see it
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    
    // Delete it!
    NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientsId"]];
    NSLog(@"Recipients: %@", recipientIds);
    
    if ([recipientIds count] == 1) {
        // Last recipient - delete!
        [self.selectedMessage deleteInBackground];
    }
    else {
        // Remove the recipient and save
        [recipientIds removeObject:[[PFUser currentUser] objectId]];
        [self.selectedMessage setObject:recipientIds forKey:@"recipientsId"];
        [self.selectedMessage saveInBackground];
    }
    
}



- (IBAction)logout:(id)sender {
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"ShowLogin" sender:self];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"ShowLogin"]) {
//        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
//       // [self.navigationController.tabBarController.navigationItem setHidesBackButton:YES animated:YES];
//                      // [self.navigationController popToRootViewControllerAnimated:YES];
//    }
////    else if ([segue.identifier isEqualToString:@"showImage"]) {
////        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
////        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
////        imageViewController.message = self.selectedMessage;
////    }
//}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowLogin"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
//         [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if([segue.identifier isEqualToString:@"showImage"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
                ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
                imageViewController.message = self.selectedMessage;
    }
//    if([segue.identifier isEqualToString:@"ShowSignUp"]){
//        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
//        //         [self.navigationController popToRootViewControllerAnimated:YES];
//        //        [self.navigationItem setHidesBackButton:NO];
//    }
    
    
}

@end

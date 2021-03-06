//
//  PastResultsTVC.m
//  TOTO
//
//  Created by Chanh Minh Vo on 3/7/14.
//  Copyright (c) 2014 USV Solutions. All rights reserved.
//

#import "PastResultsTVC.h"
#import "TOTOResultVC.h"
#import "PageAppVC.h"

@interface PastResultsTVC ()

@end

static NSString * const APIURL = @"https://usvsolutions.com/lottery/totoResult/";

@implementation PastResultsTVC
@synthesize results = _results;

- (NSArray *)results
{
    if (!_results) {
        [self getAllResults];
    }
    return _results;
}

- (void)getAllResults
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGPoint aPoint;
    aPoint.x = self.view.bounds.size.width /2;
    aPoint.y = self.view.bounds.size.height/2;
    [spinner setCenter:aPoint];
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    dispatch_queue_t aQueue = dispatch_queue_create("GetAllResult", NULL);
    dispatch_async(aQueue, ^{
        //NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSURL *url = [NSURL URLWithString:[APIURL stringByAppendingString:@"get"]];
        NSData *response = [NSData dataWithContentsOfURL:url];
        NSError *jsonParsingError = nil;
        //NSDictionary *temp = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
        NSArray *resultsFromJson = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&jsonParsingError];
        NSMutableArray *resultsTemp = [NSMutableArray array];
        for (NSString *result in resultsFromJson) {
            [resultsTemp addObject:[[Utilities class] dateFromString:result]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [spinner removeFromSuperview];
            _results = [[NSArray alloc] initWithArray:resultsTemp];
            [self.tableView reloadData];
        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.results != nil)
        return [self.results count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResultDateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (self.results != nil) {
        NSDate *resultDate = [self.results objectAtIndex:indexPath.row];
        if (resultDate != nil) {
            cell.textLabel.text = [[Utilities class] getResultDateForDisplay:resultDate];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    UIViewController *appVC = [self.navigationController.viewControllers lastObject];
    if ([appVC isKindOfClass:[PageAppVC class]]) {
        NSDate *resultDate = [self.results objectAtIndex:indexPath.row];
        ((PageAppVC *)appVC).date = resultDate;
    }
}

@end

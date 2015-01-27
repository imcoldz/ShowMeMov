//
//  MainViewController.m
//  ShowMeMov
//
//  Created by Xiangyu Zhang on 1/24/15.
//  Copyright (c) 2015 Yahoo!. All rights reserved.
//

#import "MainViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailViewController.h"
#import "JGProgressHUD.h"

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UIRefreshControl* refreshControl;
}
@property (weak, nonatomic) IBOutlet UITableView *movieTableView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) NSArray * movies;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil];
    if (self){
        self.title = @"Box-office Movies";
    }
    return self;
}

- (void)loadMovies{
    NSURL *url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dfembtks7bz66k84ejyf8jg7&limit=20"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError!=nil){
            self.movies = nil;
            NSString * errorMsg = [connectionError localizedDescription];
            NSLog(@"Network Connection Error Happend!");
            
            unichar chr[1] = {'\n'};
            NSString *singleCR = [NSString stringWithCharacters:(const unichar *)chr length:1];
            NSString * finalMsg = [[self.errorLabel.text stringByAppendingString:singleCR] stringByAppendingString:errorMsg];
            
            [self.errorLabel setText:finalMsg];
            [UIView animateWithDuration:1.0 animations:^{
                [self.errorLabel setHidden:NO];
                [self.errorLabel setAlpha:0.8];
            }];
            [HUD dismissAfterDelay:0.1];
        }else{
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.movies = (NSArray*)responseDictionary[@"movies"];
            NSLog(@"response: %@", responseDictionary);
            [self.movieTableView reloadData];
            [HUD dismissAfterDelay:0.1];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.errorLabel setAlpha:0];
    [self.errorLabel setHidden:YES];
    
    [self loadMovies];

    self.movieTableView.dataSource = self;
    self.movieTableView.delegate = self;
    self.movieTableView.rowHeight = 188;

    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor redColor];
    [refreshControl addTarget:self action:@selector(reloadDatas) forControlEvents:UIControlEventValueChanged];
    [self.movieTableView insertSubview:refreshControl atIndex:0];
    
    [self.movieTableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    }

-(void)reloadDatas
{
    //update here...
    [self loadMovies];
    [refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    MovieCell * cell = [self.movieTableView dequeueReusableCellWithIdentifier:@"MovieCell"];    
    NSDictionary * movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    NSString * date = movie[@"release_dates"][@"theater"];
    if (date.length == 0){
        date = @"N/A";
    }
    NSString * release_date = @"Release date: ";
    release_date = [release_date stringByAppendingString:date];
    [cell.rdateLabel setText:release_date];
    NSString * movieposterurl = [[movie valueForKeyPath:@"posters.thumbnail"]stringByReplacingOccurrencesOfString:@"tmb"
withString:@"pro"];
   
    //[cell.thumbView setImageWithURL:[NSURL URLWithString:movieposterurl]];

    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: movieposterurl]];
    [cell.thumbView setImageWithURLRequest:imageRequest
                           placeholderImage:nil
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
      
         cell.thumbView.image = image;
     }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
      
     }];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //to counter the select highlight effect:
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailViewController * vc = [[DetailViewController alloc] init];
    //UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.movie = self.movies[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    

}

@end

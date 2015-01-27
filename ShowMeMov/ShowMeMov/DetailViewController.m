//
//  DetailViewController.m
//  ShowMeMov
//
//  Created by Xiangyu Zhang on 1/25/15.
//  Copyright (c) 2015 Yahoo!. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "JGProgressHUD.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *synoTextView;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.titleLabel.text = self.movie[@"title"];
    self.synoTextView.text = self.movie[@"synopsis"];
    
    NSString * movieposterurl = [[self.movie valueForKeyPath:@"posters.thumbnail"]stringByReplacingOccurrencesOfString:@"tmb" withString:@"org"];
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    HUD.marginInsets = (UIEdgeInsets) {
        .top = 0.0f,
        .bottom = 100.0f,
        .left = 0.0f,
        .right = 0.0f,
    };
    [HUD showInView:self.view];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: movieposterurl]];
    [self.posterView setImageWithURLRequest:imageRequest
                    placeholderImage:nil
                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         [HUD dismissAfterDelay:0.3];
         self.posterView.image = image;
     }
                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         [HUD dismissAfterDelay:0.3];
     }];
    
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

@end

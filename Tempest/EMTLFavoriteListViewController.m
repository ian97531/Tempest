//
//  EMTLFavoriteListViewController.m
//  Tempest
//
//  Created by Ian White on 8/26/12.
//
//

#import "EMTLFavoriteListViewController.h"
#import "NSDate+IW_ISO8601.h"


@interface EMTLFavoriteListViewController ()

@end

@implementation EMTLFavoriteListViewController

- (id)initWithPhoto:(EMTLPhoto *)photo
{
    self = [super init];
    if (self) {
        _photo = photo;
        self.title = @"Favorites";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Photos" style:UIBarButtonItemStyleDone target:self action:@selector(backToPhotos)];
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:photo.favorites.count];
        for (NSDictionary *favorite in photo.favorites) {
            [users addObject:[favorite objectForKey:EMTLFavoriteUser]];
        }
        _users = [NSArray arrayWithArray:users];
    }
    
    return self;
}

- (void)backToPhotos
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadView
{
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    self.view = _tableView;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tableView reloadData];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark -
#pragma mark UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    // When the EMTLPhotos are returned to us using the photoSource:retreivedMorePhotos:
//    // method, we stored the heights needed for each cell in the heights array.
//    EMTLPhoto *photo = [_photoQuery.photoList objectAtIndex:indexPath.row];
//    return roundf((294 / photo.aspectRatio.floatValue) + 150);
//    
//}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //NSLog(@"Getting cell at index path: %i", indexPath.row);
    // Grab a cell from the queue or create a new one.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FavoriteCell"];
        
    }
    EMTLUser *user = [[_photo.favorites objectAtIndex:indexPath.row] objectForKey:EMTLFavoriteUser];
    
    cell.textLabel.text = [user username];
    cell.detailTextLabel.text = [[[_photo.favorites objectAtIndex:indexPath.row] objectForKey:EMTLFavoriteDate] humanString];
    
    if(user.icon) {
        NSLog(@"icon size: %f x %f", user.icon.size.width, user.icon.size.height);
        cell.imageView.image = user.icon;
    }
    else {
        UIImage *blankIcon = [UIImage imageNamed:@"BlankIcon.gif"];
        cell.imageView.image = blankIcon;
        NSLog(@"Blank icon size: %f x %f", blankIcon.size.width, blankIcon.size.height);
        [user loadUserWithDelegate:self];
    }
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _photo.favorites.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)userWillLoad:(EMTLUser *)user
{
    return;
}

- (void)userDidLoad:(EMTLUser *)user
{
    int index = [_users indexOfObject:user];
    
    NSIndexPath *cellIndex = [NSIndexPath indexPathForRow:index inSection:0];
    //UITableViewCell *cell = [_tableView cellForRowAtIndexPath:cellIndex];
    
    //cell.imageView.image = user.icon;
    
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:cellIndex] withRowAnimation:UITableViewRowAnimationNone];
}





@end

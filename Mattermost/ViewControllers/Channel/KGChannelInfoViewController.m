//
//  KGChannelInfoViewController.m
//  Mattermost
//
//  Created by Julia Samoshchenko on 20.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//
#import "KGBusinessLogic.h"
#import "KGBusinessLogic+Channel.h"
#import "KGChannelInfoViewController.h"
#import "UIStatusBar+SharedBar.h"
#import "UIFont+KGPreparedFont.h"
#import "UIColor+KGPreparedColor.h"
#import "KGChannel.h"
#import "KGTeam.h"
#import "KGMembersViewController.h"

static NSString *const kPresentMembersSegueIdentier = @"showMembers";

typedef NS_ENUM(NSInteger, Sections) {
    kSectionTitle = 0,
    kSectionInformation,
    kSectionNotification,
    kSectionMembers,
    kSectionLeave,
    
    kSectionCount
};

typedef NS_ENUM(NSInteger, NumberOfRows) {
    kSectionTitleNumberOfRows = 1,
    kSectionInformationNumberOfRows = 4,
    kSectionNotificationNumberOfRows = 1,
    kSectionMembersNumberOfRows = 5,
    kSectionLeaveNumberOfRows = 1,
};

static CGFloat const kTableViewTitleSectionHeaderHeight = 0.1f;
static CGFloat const kTableViewMembersSectionHeaderHeight = 30.f;
static CGFloat const kTableViewOtherSectionsHeaderHeight = 15.f;


@interface KGChannelInfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *titlesArray;
@property (nonatomic, strong) NSArray *detailsArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, assign) BOOL isAdditionMembers;
@end

@implementation KGChannelInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCloseBarItem];
    [self setupTitle];
    [self fillTitlesArray];
    [self fillDetailsArray];
    [self fillUsersArray];
    [self setupNavigationBar];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionTitle) {
        return 80.f;
    }
    if (indexPath.section == kSectionMembers) {
        return 60.f;
    }
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == kSectionTitle) {
        return kTableViewTitleSectionHeaderHeight;
    }
    if (section == kSectionMembers ) {
        return kTableViewMembersSectionHeaderHeight;
    }
    return kTableViewOtherSectionsHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == kSectionMembers) {
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] init];
    header.textLabel.font = [UIFont kg_regular16Font];
    header.textLabel.text = [NSString stringWithFormat:@"%d members", (int)self.channel.members.count];
    return header;
    }
    return [UIView new];
}

#pragma mark - TableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kSectionTitle:
            return kSectionTitleNumberOfRows;
        case kSectionInformation:
            return kSectionInformationNumberOfRows;
        case kSectionNotification:
            return kSectionNotificationNumberOfRows;
        case kSectionMembers:
            return kSectionMembersNumberOfRows;
        case kSectionLeave:
            return kSectionLeaveNumberOfRows;
        default:
            return 0;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kSectionTitle: {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"];
            
            cell.textLabel.text = self.channel.name;
            cell.imageView.image = [UIImage imageNamed:@"about_kg_icon"];
            return cell;
        }
            
        case kSectionInformation: {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DefaultStyleCell"];
            cell.textLabel.text = [self.titlesArray objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [self.detailsArray objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
            
        case kSectionNotification: {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DefaultStyleCell"];
            cell.textLabel.text = @"Notification";
            cell.imageView.image = [UIImage imageNamed:@"profile_notification_icon"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
            
        case kSectionMembers: {
            if (indexPath.row == 0) {
                UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"];
                cell.textLabel.text = @"Add Members";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor kg_blueColor];
                return cell;
            }
            if (indexPath.row == (kSectionMembersNumberOfRows - 1)) {
                UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"];
                cell.textLabel.text = @"See all Members";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor kg_blueColor];
                return cell;
            }
                UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DefaultStyleCell"];
                cell.imageView.image = [UIImage imageNamed:@"about_mattermost_icon"];
            
                KGUser *user = [self.users objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", user.status];
            
                return cell;
                                     
        }
        case kSectionLeave: {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"];
            cell.textLabel.text = @"Leave Channel";
            cell.textLabel.textColor = [UIColor kg_blueColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        }
            
        default:
            break;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kSectionTitle: {
            
            break;
        }
            
        case kSectionInformation: {
            
            break;
        }
            
        case kSectionNotification: {
            
            break;
        }
            
        case kSectionMembers: {
            if (indexPath.row == 0 || indexPath.row == (kSectionMembersNumberOfRows - 1)) {
                if (indexPath.row == 0) {
                    self.isAdditionMembers = YES;
                } else {
                    self.isAdditionMembers = NO;
                }
                [self navigateToMembers];
            }
            break;
            
        }
        case kSectionLeave: {
            
            break;
        }
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Setup

- (void)fillTitlesArray {
    self.titlesArray = @[@"Header", @"Purpose", @"URL", @"ID"];
}

// TODO self.channel.team -> URL
- (void)fillDetailsArray {
    self.detailsArray = @[self.channel.header, self.channel.purpose, @"kilograpp", self.channel.identifier];
}

- (void)fillUsersArray {
    [[KGBusinessLogic sharedInstance] loadExtraInfoForChannel:self.channel withCompletion:^(KGError *error) {
        self.users = [self.channel.members allObjects];
        [self.tableView reloadData];
    }];
}

- (void)setupNavigationBar {
    [[UIStatusBar sharedStatusBar] moveTemporaryToRootView];
}

- (void)setupTableView {
    self.tableView.delegate = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

- (void)setupCloseBarItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeChannelInfo)];
}

- (void)setupTitle {
    self.title = @"Channel Info";
}

- (void)navigateToMembers {
    [self performSegueWithIdentifier:kPresentMembersSegueIdentier sender:nil];
}

#pragma mark - Action

- (void)closeChannelInfo {
        [self dismissViewControllerAnimated:YES completion:^ {
            [[UIStatusBar sharedStatusBar] moveToPreviousView];
        }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kPresentMembersSegueIdentier]) {
        KGMembersViewController *vc = segue.destinationViewController;
        vc.channel = self.channel;
        vc.isAdditionMembers = self.isAdditionMembers;
    }
}
@end


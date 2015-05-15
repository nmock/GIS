//
//  GIImageSearchViewController.m
//  GoogleImages
//
//  Created by Nathan Mock on 5/13/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import "GIImageSearchViewController.h"
#import "Utilities/UIView+ViewHelpers.m"
#import "Utilities/UIColor+BFKit.h"
#import "GIImagesManager.h"
#import "GIImageCollectionViewCell.h"
#import <PureLayout/PureLayout.h>
#import <AMScrollingNavbar/UIViewController+ScrollingNavbar.h>
#import "GISearchHistoryManager.h"
#import "GIConstants.h"

CGFloat currentKeyboardHeight = 0.0f;
CGFloat recentSearchPadding = 24.0f;

@interface GIImageSearchViewController ()
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL didSetupConstraints;
@end

@implementation GIImageSearchViewController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.searchTextField = [[UITextField alloc] init];
        self.searchTextField.delegate = self;
        
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(GI_PADDING, GI_PADDING, GI_PADDING, GI_PADDING);
        layout.minimumColumnSpacing = GI_PADDING;
        layout.minimumInteritemSpacing = GI_PADDING;
        layout.columnCount = GI_COLUMNS;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        _tableView = [[UITableView alloc] initForAutoLayout];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.tableView];
    
    [self.view setNeedsUpdateConstraints];
    
    self.navigationItem.titleView = self.searchTextField;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"RecentSearchCell"];
    [self.collectionView registerClass:[GIImageCollectionViewCell class] forCellWithReuseIdentifier:@"GIImageResultCell"];
    [self configureViews];
    
    // perform default search query
    [[GIImagesManager sharedManager] getImagesForQuery:GI_DEFAULT_QUERY success:^{
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showNavBarAnimated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self showNavBarAnimated:NO];
}

#pragma mark - Configuration

- (void)configureViews {
    [self.navigationController.navigationBar setTranslucent:NO];

    self.searchTextField.size = CGSizeMake([UIView screenSize].width, 44.0);

    UIFont *searchTextFieldFont = [UIFont fontWithName:@"OpenSans" size:18.0];
    NSString *placeholderString = NSLocalizedString(@"Search Google Images...", nil);
    
    if ([self.searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderString attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"EBEBEB"], NSFontAttributeName : searchTextFieldFont}];
    }
    else {
        self.searchTextField.placeholder = placeholderString;
    }
    
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.enablesReturnKeyAutomatically = YES;
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchTextField.clearsOnBeginEditing = YES;
    self.searchTextField.tintColor = [UIColor whiteColor];
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.font = searchTextFieldFont;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.layer.cornerRadius = 3.0;
    self.tableView.alpha = 0.0;
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 6, 0, 0);
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 6, 0, 0);
    }
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        [self.collectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeTop];
        NSLayoutConstraint *topLayoutConstraint = [self.collectionView autoPinToTopLayoutGuideOfViewController:self withInset:0];
        
        [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(30, 30, 30, 30) excludingEdge:ALEdgeBottom];
        [self.tableView autoPinToBottomLayoutGuideOfViewController:self withInset:30];
        
        [self followScrollView:self.collectionView usingTopConstraint:topLayoutConstraint withDelay:60.0];
        [self setShouldScrollWhenContentFits:NO];
        self.didSetupConstraints = YES;
    }
    
    [super updateViewConstraints];
}

#pragma mark - UITableView DataSource / Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[GISearchHistoryManager sharedManager].recentSearches count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSLocalizedString(@"Recent Searches", nil) uppercaseString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RecentSearchCell" forIndexPath:indexPath];
    
    NSString *recentSearchQuery = [[GISearchHistoryManager sharedManager].recentSearches objectAtIndex:indexPath.row];
    cell.textLabel.text = recentSearchQuery;
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *recentSearchQuery = [[GISearchHistoryManager sharedManager].recentSearches objectAtIndex:indexPath.row];
    
    [[GIImagesManager sharedManager] getImagesForQuery:recentSearchQuery success:^{
        [self.collectionView reloadData];
        [self.searchTextField resignFirstResponder];
        [[GISearchHistoryManager sharedManager] addSearchQuery:recentSearchQuery];
    } failure:^(NSError *error) {
        
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *recentSearchQuery = [[GISearchHistoryManager sharedManager].recentSearches objectAtIndex:indexPath.row];
        [[GISearchHistoryManager sharedManager] removeSearchQuery:recentSearchQuery];
            
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[GIImagesManager sharedManager].images count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GIImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GIImageResultCell" forIndexPath:indexPath];
    [cell updateWithImage:[[GIImagesManager sharedManager].images objectAtIndex:indexPath.row]];
    
    if(indexPath.row == [[GIImagesManager sharedManager].images count] - 1) {
        [[GIImagesManager sharedManager] getNextPage:^{
            [self.collectionView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }
    
    return cell;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    GIImage *gImage = [[GIImagesManager sharedManager].images objectAtIndex:indexPath.row];
    return gImage.normalizedThumbnailSize;
}

#pragma mark - UIScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [self showNavbar];
    
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        [[GISearchHistoryManager sharedManager] addSearchQuery:[GIImagesManager sharedManager].currentQuery];
        [self.searchTextField resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *query = [self.searchTextField.text stringByReplacingCharactersInRange:range
                                                                         withString:string];
    
    if ([query length] != 0) {
        [self performSearchQuery:query];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.searchTextField.text = [GIImagesManager sharedManager].currentQuery;
    [[GISearchHistoryManager sharedManager] addSearchQuery:[GIImagesManager sharedManager].currentQuery];
    
    return [textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.searchTextField.text = [GIImagesManager sharedManager].currentQuery;
    
    [self hideRecentSearches];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showRecentSearches];
}

// try to be smart about auto-complete (queue before making request)
- (void)performSearchQuery:(NSString*)searchQuery {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reallyPerformSearchQuery:) object:nil];
    [self performSelector:@selector(reallyPerformSearchQuery:) withObject:searchQuery afterDelay:GI_AUTO_COMPLETE_DELAY];
}

- (void)reallyPerformSearchQuery:(NSString*)searchQuery {
    [[GIImagesManager sharedManager] getImagesForQuery:searchQuery success:^{
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - State 
- (void)hideRecentSearches {
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.tableView.hidden = YES;
    }];
}

- (void)showRecentSearches {
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.alpha = 0.98;
    }];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.tableView.frame = CGRectMake(recentSearchPadding, recentSearchPadding, [UIView screenSize].width - (recentSearchPadding * 2), self.view.height - kbSize.height -(recentSearchPadding * 2));
    
    currentKeyboardHeight = kbSize.height;
}

- (void)dealloc {
    [self stopFollowingScrollView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

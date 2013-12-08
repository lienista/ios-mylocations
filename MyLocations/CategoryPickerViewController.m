//
//  CategoryPickerViewController.m
//  MyLocations
//
//  Created by Lienne Nguyen on 11/26/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//

#import "CategoryPickerViewController.h"

@interface CategoryPickerViewController ()

@end

@implementation CategoryPickerViewController

{
    NSArray *_categories;
    NSIndexPath *_selectedIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _categories = @[
                    @"No Category",
                    @"School",
                    @"Church",
                    @"Hospital",
                    @"Water",
                    @"Obstacle",
                    @"Crisis Area",
                    @"Natural Landmark",
                    ];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_categories count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString *categoryName = _categories[indexPath.row];
    cell.textLabel.text=categoryName;
    
    if([categoryName isEqualToString:self.selectedCategoryName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedIndexPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row != _selectedIndexPath.row) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        _selectedIndexPath = indexPath;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PickedCategory"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        self.selectedCategoryName = _categories[indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor brownColor];
    cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    
    selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    
    cell.selectedBackgroundView = selectionView;
}

@end
//
//  VillagesViewController.m
//  MyVillages
//
//  Created by Esther Resendiz on 12/7/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//


#import "VillagesViewController.h"
#import "Village.h"
#import "VillageCell.h"
#import "VillageDetailsViewController.h"
// esther
#import "CurrentVillageViewController.h"

#import "UIImage+Resize.h"
#import "NSMutableString+AddText.h"

@interface VillagesViewController () <NSFetchedResultsControllerDelegate>
@end

@implementation VillagesViewController
{
    NSFetchedResultsController *_fetchedResultsController;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    return [sectionInfo numberOfObjects];
}

/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Village"];
 
 Village *Village = _locations[indexPath.row];
 
 UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:100];
 
 descriptionLabel.text = location.locationDescription;
 
 UILabel *addressLabel = (UILabel *)[cell viewWithTag:101];
 addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@",
 location.placemark.subThoroughfare,
 location.placemark.thoroughfare,
 location.placemark.locality];
 return cell;
 }*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Village"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    VillageCell *villageCell = (VillageCell *) cell;
    Village *village = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([village.locationDescription length] > 0) {
        villageCell.descriptionLabel.text = village.locationDescription;
    } else {
        villageCell.descriptionLabel.text = @"(No Description)";
    }
    
    if (village.placemark != nil){
        NSMutableString *string = [NSMutableString stringWithCapacity:100];
        [string addText:village.placemark.subThoroughfare withSeparator:@""];
        [string addText:village.placemark.thoroughfare withSeparator:@" "];
        [string addText:village.placemark.locality withSeparator:@", "];
        villageCell.addressLabel.text = string;
        
    } else {
        villageCell.addressLabel.text = [NSString stringWithFormat: @"Lat: %.8f, Long: %.8f",
                                          [village.latitude doubleValue],
                                          [village.longitude doubleValue]];
    }
    
    UIImage *image = nil;
    if ([village hasPhoto]) {
        image = [village photoImage];
        if (image != nil) {
            image = [image resizedImageWithBounds:CGSizeMake(52, 52)];
        }
    }
    if (image == nil) {
        image = [UIImage imageNamed:@"No Photo"];
    }
    villageCell.photoImageView.image = image;
    villageCell.backgroundColor = [UIColor blackColor];
    villageCell.descriptionLabel.textColor = [UIColor whiteColor];
    villageCell.descriptionLabel.highlightedTextColor = villageCell.descriptionLabel.textColor;
    villageCell.addressLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    villageCell.addressLabel.highlightedTextColor = villageCell.addressLabel.textColor;
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    
    selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    
    villageCell.selectedBackgroundView = selectionView;
    villageCell.photoImageView.layer.cornerRadius = villageCell.photoImageView.bounds.size.width / 2.0f;
    villageCell.photoImageView.clipsToBounds = YES;
    villageCell.separatorInset = UIEdgeInsetsMake(0, 82, 0, 0);
}

//fetchedResultsController is lazy loading method - objects are not created until needed
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Village" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
        
        [fetchRequest setFetchBatchSize:20];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"category"
                                                                                   cacheName:@"Villages"];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [NSFetchedResultsController deleteCacheWithName:@"Villages"];
    [self performFetch];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
}

- (void)performFetch {
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
}

- (void)dealloc
{
    _fetchedResultsController.delegate = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditVillage"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        
        VillageDetailsViewController *controller = (VillageDetailsViewController *) navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        Village *Village = [self.fetchedResultsController objectAtIndexPath:indexPath];
        controller.VillageToEdit = Village;
    } else if ([segue.identifier isEqualToString:@"CurrVillage"]) {
        CurrentVillageViewController *controller =segue.destinationViewController;
        // core data objects from data store
        controller.managedObjectContext = self.managedObjectContext;
    }
    
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent: (NSFetchedResultsController *)controller
{
    NSLog(@"*** controllerWillChangeContent"); [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** NSFetchedResultsChangeInsert (object)"); [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** NSFetchedResultsChangeDelete (object)");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            NSLog(@"*** NSFetchedResultsChangeUpdate (object)");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath]; break;
        case NSFetchedResultsChangeMove:
            NSLog(@"*** NSFetchedResultsChangeMove (object)");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** NSFetchedResultsChangeInsert (section)");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** NSFetchedResultsChangeDelete (section)");
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent: (NSFetchedResultsController *)controller
{
    NSLog(@"*** controllerDidChangeContent");
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Village *Village = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [Village removePhotoFile];
        [self.managedObjectContext deleteObject:Village];
        NSError *error;
        
        if (![self.managedObjectContext save:&error]) {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
    }
}
- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    return [[sectionInfo name] uppercaseString];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:
                      CGRectMake(15.0f, tableView.sectionHeaderHeight - 14.0f, 300.0f, 14.0f)];
    label.font = [UIFont boldSystemFontOfSize:11.0f];
    label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    label.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    label.backgroundColor = [UIColor clearColor];
    
    UIView *separator = [[UIView alloc] initWithFrame: CGRectMake(15.0f, tableView.sectionHeaderHeight - 0.5f, tableView.bounds.size.width - 15.0f, 0.5f)]; separator.backgroundColor = tableView.separatorColor;
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
    view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.85f];
    
    [view addSubview:label];
    [view addSubview:separator];
    
    return view;
}

@end
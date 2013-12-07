//
//  VillageDetailsViewController.m
//  MyVillages
//
//  Created by Esther Resendiz on 12/7/13.
//  Copyright (c) 2013 Lienne Nguyen. All rights reserved.
//


#import "VillageDetailsViewController.h"
#import "CategoryPickerViewController.h"
#import "HudView.h"
#import "Village.h"
#import "NSMutableString+AddText.h"

@interface VillageDetailsViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *photoLabel;

@end

@implementation VillageDetailsViewController
{
    NSString *_descriptionText;
    NSString *_categoryName;
    NSDate *_date;
    UIImage *_image;
    
    UIActionSheet *_actionSheet;
    UIImagePickerController *_imagePicker;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _descriptionText = @"";
        _categoryName = @"No Category";
        _date = [NSDate date];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*- (IBAction)done:(id)sender {
 
 HudView *hudView = [HudView hudInView: self.navigationController.view animated:YES];
 hudView.text = @"Tagged";
 
 // 1
 Village *Village = [NSEntityDescription insertNewObjectForEntityForName:@"Village" inManagedObjectContext:self.managedObjectContext];
 
 // 2
 Village.VillageDescription = _descriptionText;
 Village.category = _categoryName;
 Village.latitude = @(self.coordinate.latitude);
 Village.longitude = @(self.coordinate.longitude);
 Village.date = _date;
 Village.placemark = self.placemark;
 // 3
 NSError *error;
 if (![self.managedObjectContext save:&error]) {
 FATAL_CORE_DATA_ERROR(error);
 return;
 }
 [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
 }*/

- (IBAction)done:(id)sender {
    
    HudView *hudView = [HudView hudInView: self.navigationController.view animated:YES];
    
    Village *village = nil;
    
    if(self.VillageToEdit != nil) {
        hudView.text = @"Updated";
        village = self.VillageToEdit;
    } else {
        hudView.text = @"Tagged";
        NSLog(@"Tagged--->");
        if (self.managedObjectContext == nil)
        {
            NSLog(@"Ruh Roh- managed obj in Village Nil");
        } else
        {
            NSLog(@"Not nil-what gives?");
        }
        village = [NSEntityDescription insertNewObjectForEntityForName:@"Village" inManagedObjectContext:self.managedObjectContext];
        NSLog(@"post Tagged--->");
        village.photoId = @-1;
    }
    
    village.locationDescription = _descriptionText;
    village.category = _categoryName;
    village.latitude = @(self.coordinate.latitude);
    village.longitude = @(self.coordinate.longitude);
    village.date = _date;
    village.placemark = self.placemark;
    if (_image != nil) {
        // 1
        if (![village hasPhoto]) {
            village.photoId = @([Village nextPhotoId]);
        }
        // 2
        NSData *data = UIImageJPEGRepresentation(_image, 0.5); NSError *error;
        if (![data writeToFile:[village photoPath]
                       options:NSDataWritingAtomic error:&error]) {
            NSLog(@"Error writing file: %@", error);
        }
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"BEFORE FATAL");
        FATAL_CORE_DATA_ERROR(error);
        NSLog(@"POST - FATAL");
        return;
    }
    
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
    
}


- (IBAction)cancel:(id)sender
{
    [self closeScreen];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickVillageCategory"]) {
        CategoryPickerViewController *controller = segue.destinationViewController;
        controller.selectedCategoryName = _categoryName; }
}

- (void)closeScreen {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.VillageToEdit != nil) {
        self.title = @"Edit Village";
        if ([self.VillageToEdit hasPhoto]) {
            UIImage *existingImage = [self.VillageToEdit photoImage];
            if (existingImage != nil) {
                [self showImage:existingImage];
                
            }
        }
    }
    
    self.descriptionTextView.text = _descriptionText;
    self.categoryLabel.text = _categoryName;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat: @"%.8f", self.coordinate.longitude];
    if (self.placemark != nil) {
        self.addressLabel.text = [self stringFromPlacemark:self.placemark];
        
    } else {
        self.addressLabel.text = @"No Address Found";
    }
    self.dateLabel.text = [self formatDate:_date];
    
    UITapGestureRecognizer *gesturRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    
    gesturRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gesturRecognizer];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    self.descriptionTextView.textColor = [UIColor brownColor];
    self.descriptionTextView.backgroundColor = [UIColor whiteColor];
    self.photoLabel.textColor = [UIColor brownColor];
    self.photoLabel.highlightedTextColor = self.photoLabel.textColor;
    self.addressLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    self.addressLabel.highlightedTextColor = self.addressLabel.textColor;
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)placemark
{
    NSMutableString *line = [NSMutableString stringWithCapacity:100];
    
    [line addText:placemark.subThoroughfare withSeparator:@""];
    [line addText:placemark.thoroughfare withSeparator:@" "];
    [line addText:placemark.locality withSeparator:@", "];
    [line addText:placemark.administrativeArea withSeparator:@", "];
    [line addText:placemark.postalCode withSeparator:@" "];
    [line addText:placemark.country withSeparator:@", "];
    
    return line;
}

- (NSString *)formatDate:(NSDate *)theDate {
    static NSDateFormatter *formatter = nil; if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init]; [formatter setDateStyle:NSDateFormatterMediumStyle]; [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return [formatter stringFromDate:theDate];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    _descriptionText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _descriptionText = textView.text;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 88;
    } else if (indexPath.section == 1) {
        if (self.imageView.hidden) {
            return 44;
        } else {
            return 280;
        }
    } else if (indexPath.section == 2 && indexPath.row == 2) {
        CGRect rect = CGRectMake(100, 10, 205, 10000);
        self.addressLabel.frame = rect;
        [self.addressLabel sizeToFit];
        
        rect.size.height = self.addressLabel.frame.size.height;
        self.addressLabel.frame = rect;
        return self.addressLabel.frame.size.height + 20;
    } else {
        return 44;
    }
}

- (IBAction)categoryPickerDidPickCategory:(UIStoryboardSegue *)segue
{
    CategoryPickerViewController *viewController = segue.sourceViewController;
    _categoryName = viewController.selectedCategoryName;
    self.categoryLabel.text = _categoryName;
}

- (void)takePhoto
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    _imagePicker.view.tintColor = self.view.tintColor;
    
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    _imagePicker.view.tintColor = self.view.tintColor;
    
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 || indexPath.section ==1) {
        return indexPath;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0) {
        [self.descriptionTextView becomeFirstResponder];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showPhotoMenu];
    }
}

- (void)hideKeyboard:(UIGestureRecognizer *) gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if(indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    
    [self.descriptionTextView resignFirstResponder];
}

- (void)setVillageToEdit:(Village *)newVillageToEdit {
    
    if (_VillageToEdit != newVillageToEdit) {
        _VillageToEdit = newVillageToEdit;
        _descriptionText = _VillageToEdit.locationDescription;
        _categoryName = _VillageToEdit.category;
        _date = _VillageToEdit.date;
        
        self.coordinate = CLLocationCoordinate2DMake( [_VillageToEdit.latitude doubleValue], [_VillageToEdit.longitude doubleValue]);
        self.placemark = _VillageToEdit.placemark;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = info[UIImagePickerControllerEditedImage];
    [self showImage:_image];
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}

- (void)imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    _imagePicker = nil;
}

- (void)showPhotoMenu {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        _actionSheet = [[UIActionSheet alloc]
                        initWithTitle:nil
                        delegate:self
                        cancelButtonTitle:@"Cancel"
                        destructiveButtonTitle:nil
                        otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        [_actionSheet showInView:self.view];
    } else {
        [self choosePhotoFromLibrary];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self choosePhotoFromLibrary];
    }
    _actionSheet = nil;
}

- (void)showImage:(UIImage *)image {
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(10, 10, 260, 260);
    self.photoLabel.hidden = YES;
}

- (void)applicationDidEnterBackground
{
    if (_imagePicker != nil) {
        [self dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;}
    if (_actionSheet != nil) {
        [_actionSheet dismissWithClickedButtonIndex:
         _actionSheet.cancelButtonIndex animated:NO];
        _actionSheet = nil;
    }
    [self.descriptionTextView resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor brownColor];
    
    cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    cell.selectedBackgroundView = selectionView;
    
    if (indexPath.row == 2) {
        UILabel *addressLabel = (UILabel *)[cell viewWithTag:100];
        addressLabel.textColor = [UIColor brownColor];
        addressLabel.highlightedTextColor = addressLabel.textColor;
    }
}

@end

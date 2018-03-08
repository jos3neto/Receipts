//
//  AddViewController.m
//  Receipts
//
//  Created by Jose on 28/2/18.
//  Copyright © 2018 appcat.com. All rights reserved.
//

#import "AddViewController.h"
#import "Receipt+CoreDataClass.h"

@interface AddViewController () <UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView* descriptionView;
@property (weak, nonatomic) IBOutlet UITextField* amountField;
@property (weak, nonatomic) IBOutlet UIDatePicker* datePicker;
@property (strong, nonatomic) UIToolbar* toolbar;
@property (weak, nonatomic) IBOutlet UIButton* addButton;
@property (weak, nonatomic) IBOutlet UIButton* cancelButton;
@property (weak, nonatomic) IBOutlet UIButton* personalButton;
@property (weak, nonatomic) IBOutlet UIButton* businessButton;
@property (weak, nonatomic) IBOutlet UIButton* familyButton;
@property (strong, nonatomic) NSMutableSet* tagSet;
@end

@implementation AddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _amountField.delegate = self;
    _descriptionView.delegate = self;
    
    _descriptionView.layer.borderWidth = 1;
    _descriptionView.layer.cornerRadius = 8;
    _amountField.layer.borderWidth = 1;
    _amountField.layer.cornerRadius = 8;
    _addButton.layer.borderWidth = 1;
    _addButton.layer.cornerRadius = 8;
    _cancelButton.layer.borderWidth = 1;
    _cancelButton.layer.cornerRadius = 8;
    
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didClickDone)];
    UIBarButtonItem* emptySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_toolbar setItems:[NSArray arrayWithObjects:emptySpace,doneButton,nil]];
    //[_toolBar sizeToFit];
    //_toolBar.barStyle = UIBarStyleBlackTranslucent;
    //_descriptionView.returnKeyType = UIReturnKeyDone;
}

#pragma mark - textField and textView

-(void) didClickDone
{
    [_amountField resignFirstResponder];
    [_descriptionView resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    [textField setInputAccessoryView:_toolbar];
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView*)textView
{
    [textView setInputAccessoryView:_toolbar];
    
    if ([textView.text isEqualToString:@"Description"])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

#pragma mark - receipt category buttons

-(void)toggleButton:(UIButton*)sender
{
    UIImage* checked = [UIImage imageNamed:@"checked.png"];
    
    if (!sender.selected)
    {
        [sender setBackgroundImage:checked forState:UIControlStateSelected];
        sender.selected = YES;
    } else
    {
        sender.selected = NO;
    }
}

- (IBAction)personalButton:(UIButton*)sender
{
    [self toggleButton:sender];
}

- (IBAction)businessButton:(UIButton*)sender
{
    [self toggleButton:sender];
}

- (IBAction)familyButton:(UIButton*)sender
{
    [self toggleButton:sender];
}

#pragma mark - add new receipt methods

-(void) executeFetch:(NSFetchRequest*)fetchRequest withPredicate:(NSPredicate*)predicate
{
    [fetchRequest setPredicate:predicate];
    NSError* error = nil;
    NSArray* tagArray = [_context executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSLog(@"Error fetching tags: %@", error.localizedDescription);
    }
    
    [_tagSet addObject:[tagArray lastObject]];
    
    //NSLog(@"%d", _tagSet.count);
}

- (IBAction)addButton:(UIButton*)sender
{
    Receipt* newReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipt" inManagedObjectContext:_context];
    newReceipt.amount = [NSString stringWithFormat:@"$%@", _amountField.text];
    newReceipt.date = _datePicker.date;
    newReceipt.desc = _descriptionView.text;
    _tagSet = [newReceipt mutableSetValueForKey:@"tag"];

    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:_context];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    if (_personalButton.selected)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name == 'personal'"];
        [self executeFetch:fetchRequest withPredicate:predicate];
    }
    
    if (_businessButton.selected)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name == 'business'"];
        [self executeFetch:fetchRequest withPredicate:predicate];
    }
    
    if (_familyButton.selected)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name == 'family'"];
        [self executeFetch:fetchRequest withPredicate:predicate];
    }
    
    NSError* error = nil;
    [_context save:&error];
    
    if (error)
    {
        NSLog(@"Error saving receipt: %@",error.localizedDescription);
    }
}

- (void)didReceiveMemoryWarning
{
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

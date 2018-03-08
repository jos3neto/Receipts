//
//  ViewController.m
//  Receipts
//
//  Created by Jose on 26/2/18.
//  Copyright © 2018 appcat.com. All rights reserved.
//

#import "ViewController.h"
#import "AddViewController.h"
#import "Receipt+CoreDataClass.h"
#import "Tag+CoreDataClass.h"

@interface ViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) NSArray<Tag*>* tagsArray;
@property (strong, nonatomic) NSMutableArray<NSArray*>* sectionsArray;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.dataSource = self;
    [self fetchTags];
    [self fetchReceipts];
}

//this method fetches the receipts, grouped by tags.
-(void) fetchReceipts
{
    _sectionsArray = [[NSMutableArray alloc] init];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    
    for (Tag* tag in _tagsArray)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ANY %K == %@",@"tag.name",tag.name];
        [fetchRequest setPredicate:predicate];
        
        NSError* error = nil;
        
        // this is the array of receipts for one particular tag
        NSArray* receiptsArray = [_context executeFetchRequest:fetchRequest error:&error];
        
        if (error)
        {
            NSLog(@"Error fetching tags: %@", error.localizedDescription);
        }
        
        //this is an array of arrays, one array for each tag, with its corresponding receipts
        [_sectionsArray addObject:receiptsArray];
    }
    
    //NSLog(@"first receipt: %@", ((Receipt*)_sectionsArray[0][2]).desc);
    //NSLog(@"second receipt: %@", ((Receipt*)_sectionsArray[1][1]).desc);
    //NSLog(@"third receipt: %@", ((Receipt*)_sectionsArray[2][0]).desc);

}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionsArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sectionsArray[section].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.text = ((Receipt*)_sectionsArray[indexPath.section][indexPath.row]).desc;
    cell.detailTextLabel.text = ((Receipt*)_sectionsArray[indexPath.section][indexPath.row]).amount;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _tagsArray[section].name.capitalizedString;
}

#pragma mark - Tag acquisition

-(void) createTags
{
    Tag* personalTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:_context];
    personalTag.name = @"personal";
    
    Tag* businessTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:_context];
    businessTag.name = @"business";
    
    Tag* familyTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:_context];
    familyTag.name = @"family";
    
    NSError* error = nil;
    [_context save:&error];
    
    if (error)
    {
        NSLog(@"Error saving tags: %@", error.localizedDescription);
    }
}

-(void) fetchTags
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    
    NSError* error = nil;
    _tagsArray = [_context executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSLog(@"Error fetching tags: %@", error.localizedDescription);
    }
    
    if (_tagsArray.count == 0)
    {
        [self createTags];
    }
    
    /*for (Tag* tag in _tagsArray)
    {
        NSLog(@"%@", tag.name);
    }*/
}

#pragma mark - Segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toModal"])
    {
        AddViewController* controller = segue.destinationViewController;
        controller.context = _context;
    }
}

-(IBAction)unwindToTableView:(UIStoryboardSegue*)segue
{
    [self fetchReceipts];
    [_tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

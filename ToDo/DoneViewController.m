//
//  DoneViewController.m
//  ToDo
//
//  Created by JETSMobileLabMini11 on 17/04/2024.
//

#import "DoneViewController.h"
#import "DetailsViewController.h"

@interface DoneViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *noTaskImg;
@property (weak, nonatomic) IBOutlet UITableView *doneTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray<Task *> *tasks;
@property NSMutableArray<Task *> *tasksDone;
@property NSMutableArray<Task *> *tasksLow;
@property NSMutableArray<Task *> *tasksMed;
@property NSMutableArray<Task *> *tasksHigh;

@property BOOL isFiltered;

@end

@implementation DoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _doneTable.delegate = self;
    _doneTable.dataSource = self;
    _searchBar.delegate = self;
    
    _tasks = [NSMutableArray new];
    _tasksDone = [NSMutableArray new];
    
    _isFiltered = NO;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"Done";
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target:self action:@selector(filterTasks:)];
    
    // Load tasks
    _tasks = [self loadData];
    if (!_tasks) {
        _tasks = [NSMutableArray new];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %hd", 2];
    _tasksDone = [[_tasks filteredArrayUsingPredicate:predicate] mutableCopy];
    
    [_doneTable reloadData];
}

-(void) filterTasks:(id) sender{
    NSLog(@"will filter");
    _isFiltered = !_isFiltered;
    
    _searchBar.hidden =_isFiltered;
    
    [_doneTable reloadData];
}

-(NSMutableArray <Task *> *) loadData{
    NSData *unarchiveData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myTasks"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:unarchiveData];
}

-(void) saveData:(NSMutableArray <Task *> *) tasks{
    NSError * error = [NSError new];
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:tasks];
    if (archivedData) {
        [[NSUserDefaults standardUserDefaults] setObject:archivedData forKey:@"myTasks"];
    } else {
        NSLog(@"Error archiving object: %@", error);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _isFiltered ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    long numberOfRows = 0;
    
    if(_isFiltered){
        NSPredicate *low = [NSPredicate predicateWithFormat:@"status == %hd && priority == %hd", 2, 0];
        _tasksLow = [[_tasks filteredArrayUsingPredicate:low] mutableCopy];
        NSLog(@"_tasksLow = %lu",(unsigned long)_tasksLow.count);
        NSPredicate *med = [NSPredicate predicateWithFormat:@"status == %hd && priority == %hd", 2, 1];
        _tasksMed = [[_tasks filteredArrayUsingPredicate:med] mutableCopy];
        NSLog(@"_tasksMed = %lu",(unsigned long)_tasksMed.count);
        NSPredicate *high = [NSPredicate predicateWithFormat:@"status == %hd && priority == %hd", 2, 2];
        _tasksHigh = [[_tasks filteredArrayUsingPredicate:high] mutableCopy];
        NSLog(@"_tasksHigh = %lu",(unsigned long)_tasksHigh.count);
    }
    
    if(_isFiltered){
        switch (section) {
            case 0:
                numberOfRows = _tasksLow.count;
                break;
            case 1:
                numberOfRows = _tasksMed.count;
                break;
            case 2:
                numberOfRows = _tasksHigh.count;
                break;
                
            default:
                break;
        }
        _noTaskImg.hidden = ((_tasksLow.count + _tasksMed.count + _tasksHigh.count) > 0);
    }else{
        numberOfRows = _tasksDone.count;
        _noTaskImg.hidden = (numberOfRows > 0);
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Task *task;
    if(_isFiltered){
        switch (indexPath.section) {
            case 0:
                task = _tasksLow[indexPath.row];
                break;
            case 1:
                task = _tasksMed[indexPath.row];
                break;
            case 2:
                task = _tasksHigh[indexPath.row];
                break;
                
            default:
                break;
        }
    }else{
        task = _tasksDone[indexPath.row];
    }
    
    // Configure cell
    UIImageView *img = (UIImageView *)[cell viewWithTag:0];
    img.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", task.priority]];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = task.title;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(tableView.numberOfSections == 1){
        return @"All Tasks";
    }else{
        switch (section) {
            case 0:
                return @"Low";
                break;
            case 1:
                return @"Meduim";
                break;
            case 2:
                return @"High";
                break;
            default:
                return @"";
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DetailsViewController *details =[self.storyboard instantiateViewControllerWithIdentifier:@"details"];
    
    Task *task;
    if(_isFiltered){
        switch (indexPath.section) {
            case 0:
                task = _tasksLow[indexPath.row];
                break;
            case 1:
                task = _tasksMed[indexPath.row];
                break;
            case 2:
                task = _tasksHigh[indexPath.row];
                break;
                
            default:
                break;
        }
    }else{
        task = [_tasksDone objectAtIndex:indexPath.row];
    }
    
    details.tasks = _tasks;
    
    if(_tasks.count > 0){
        details.index = [self indexOfTask:task];
    }else{
        details.index = -1;
    }
    
    NSLog(@"task index = %ld", details.index);
    [self.navigationController pushViewController:details animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self showAlert:@"Delete" message:@"Do you want to delete this task?" action: [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            Task *task;
            if(self->_isFiltered){
                switch (indexPath.section) {
                    case 0:
                        task = self->_tasksLow[indexPath.row];
                        [self->_tasksLow removeObjectAtIndex:indexPath.row];
                        break;
                    case 1:
                        task = self->_tasksMed[indexPath.row];
                        [self->_tasksMed removeObjectAtIndex:indexPath.row];
                        break;
                    case 2:
                        task = self->_tasksHigh[indexPath.row];
                        [self->_tasksHigh removeObjectAtIndex:indexPath.row];
                        break;
                        
                    default:
                        break;
                }
                [self->_tasksDone removeObjectIdenticalTo:task];
            }else{
                task = [self->_tasksDone objectAtIndex:indexPath.row];
                [self->_tasksDone removeObjectAtIndex:indexPath.row];
            }
            
            [self->_tasks removeObjectAtIndex:[self indexOfTask:task]];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self saveData:self->_tasks];
            
        }]];
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Filter tasks based on search text
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@ && status == %hd", searchText, 2];
        _tasksDone = [[_tasks filteredArrayUsingPredicate:predicate] mutableCopy];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %hd", 2];
        _tasksDone = [[_tasks filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    
    // Reload table view
    [_doneTable reloadData];
}

-(long) indexOfTask:(Task *)task {
    long taskIndex = -1;
    for (int i =0; i< _tasks.count; i++) {
        if([task isEqualToTask:_tasks[i]]){
            taskIndex = i;
        }
    }
    return taskIndex;
}

-(void) showAlert:(NSString *) title message:(NSString *)message action:(UIAlertAction *) action {
    UIAlertController * alert =[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancel];
    if(action)
        [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end

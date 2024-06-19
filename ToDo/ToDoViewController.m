//
//  ViewController.m
//  ToDo
//
//  Created by JETSMobileLabMini11 on 17/04/2024.
//

#import "ToDoViewController.h"
#import "DetailsViewController.h"
#import "Task.h"

@interface ToDoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *noTaskImg;
@property (weak, nonatomic) IBOutlet UITableView *toDoTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray<Task *> *filteredTasks;
@property NSMutableArray<Task *> *tasks;
@end

@implementation ToDoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _toDoTable.delegate = self;
    _toDoTable.dataSource = self;
    _searchBar.delegate = self;
    
    _tasks = [NSMutableArray new];
    _filteredTasks = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"ToDo";
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addTask:)];
    
    // Load tasks
    _tasks = [self loadData];
    if (!_tasks) {
        _tasks = [NSMutableArray new];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %hd", 0];
    _filteredTasks = [[_tasks filteredArrayUsingPredicate:predicate] mutableCopy];
    
    // _filteredTasks = [_tasks mutableCopy];
    [_toDoTable reloadData];
}

-(void) addTask:(id) sender{
    DetailsViewController *details =[self.storyboard instantiateViewControllerWithIdentifier:@"details"];
    details.tasks = _tasks;
    details.index = -1;
    [self.navigationController pushViewController:details animated:YES];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    _noTaskImg.hidden = (_filteredTasks.count > 0);
    return _filteredTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure cell
    UIImageView *img = (UIImageView *)[cell viewWithTag:0];
    img.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", _filteredTasks[indexPath.row].priority]];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = _filteredTasks[indexPath.row].title;
    
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
    
    details.tasks = _tasks;
    if(_tasks.count > 0){
        details.index = [_tasks indexOfObject:[_filteredTasks objectAtIndex:indexPath.row]];
    }else{
        details.index = -1;
    }
    NSLog(@"task index = %lu",(unsigned long)details.index);
    [self.navigationController pushViewController:details animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self showAlert:@"Delete" message:@"Do you want to delete this task?" action: [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self->_tasks removeObjectAtIndex:[self indexOfTask:[self->_filteredTasks objectAtIndex:indexPath.row]]];
            [self->_filteredTasks removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self saveData:self->_tasks];
        }]];
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Filter tasks based on search text
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@ && status == %hd", searchText, 0];
        _filteredTasks = [[_tasks filteredArrayUsingPredicate:predicate] mutableCopy];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %hd", 0];
        _filteredTasks = [[_tasks filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    
    // Reload table view
    [_toDoTable reloadData];
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

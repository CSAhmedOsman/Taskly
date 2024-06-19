#import "ToDoViewController.h"
#import "DetailsViewController.h"
#import "Task.h"

@interface ToDoViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *noTaskImg;
@property (weak, nonatomic) IBOutlet UITableView *toDoTable;
@property (strong, nonatomic) NSMutableArray<Task *> *tasks;
@property (strong, nonatomic) NSMutableArray<Task *> *filteredTasks;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ToDoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _toDoTable.delegate = self;
    _toDoTable.dataSource = self;
    _searchBar.delegate = self;
    
    // Initialize arrays
    _tasks = [NSMutableArray new];
    _filteredTasks = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"ToDo";
    
    // Set up navigation bar
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTask:)];
    
    // Load tasks
    [self loadTasks];
}

- (void)loadTasks {
    // Load tasks from UserDefaults
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"myTasks"];
    _tasks = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    // Reload table view
    [_toDoTable reloadData];
    
    // Check if there are tasks to display
    _noTaskImg.hidden = (_tasks.count > 0);
}

- (void)addTask:(id)sender {
    // Navigate to DetailsViewController for adding a new task
    DetailsViewController *details = [self.storyboard instantiateViewControllerWithIdentifier:@"details"];
    details.isNew = YES;
    [self.navigationController pushViewController:details animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchBar.text.length > 0) {
        return _filteredTasks.count;
    } else {
        return _tasks.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Task *task;
    if (_searchBar.text.length > 0) {
        task = _filteredTasks[indexPath.row];
    } else {
        task = _tasks[indexPath.row];
    }
    
    // Configure cell
    UIImageView *img = (UIImageView *)[cell viewWithTag:0];
    img.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", task.priority]];

    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = task.title;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigate to DetailsViewController for editing the selected task
    DetailsViewController *details = [self.storyboard instantiateViewControllerWithIdentifier:@"details"];
    details.task = (_searchBar.text.length > 0) ? _filteredTasks[indexPath.row] : _tasks[indexPath.row];
    details.isNew = NO;
    [self.navigationController pushViewController:details animated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Filter tasks based on search text
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchText];
        _filteredTasks = [[_tasks filteredArrayUsingPredicate:predicate] mutableCopy];
    } else {
        _filteredTasks = [_tasks mutableCopy];
    }
    
    // Reload table view
    [_toDoTable reloadData];
}

@end


#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface DetailsViewController : UIViewController <UIDocumentPickerDelegate>

// Properties and IBOutlet declarations...

@end

@implementation DetailsViewController

// Method to handle attaching a file
- (IBAction)attachFile:(id)sender {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.content"] inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

// Delegate method for UIDocumentPickerViewController
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    // Handle the selected file URL(s) here
    NSURL *selectedFileURL = [urls firstObject];
    // Store or associate the file URL with the task
}

// Method to handle adding a reminder
- (IBAction)addReminder:(id)sender {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        if (granted && !error) {
            EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
            reminder.title = _taskTitle.text; // Set the reminder title
            reminder.dueDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:_taskData.date]; // Set the reminder due date
            EKCalendar *calendar = [eventStore defaultCalendarForNewReminders];
            [calendar saveReminder:reminder commit:YES error:nil];
        } else {
            // Handle access denied or error
        }
    }];
}

@end


- (IBAction)addReminder:(id)sender {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        if (granted && !error) {
            EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
            reminder.title = _taskTitle.text; // Set the reminder title
            // Get the date components from the UIDatePicker
            NSDateComponents *dueDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:_taskData.date];
            // Set the reminder due date
            reminder.dueDateComponents = dueDateComponents;
            EKCalendar *calendar = [eventStore defaultCalendarForNewReminders];
            [calendar saveReminder:reminder commit:YES error:nil];
        } else {
            // Handle access denied or error
        }
    }];
}

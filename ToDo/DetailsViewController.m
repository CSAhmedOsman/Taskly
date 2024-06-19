//
//  DetailsViewController.m
//  ToDo
//
//  Created by JETSMobileLabMini11 on 17/04/2024.
//

#import "DetailsViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *taskTitle;
@property (weak, nonatomic) IBOutlet UITextView *taskDescription;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskPriority;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskStatus;
@property (weak, nonatomic) IBOutlet UIDatePicker *taskData;
@property (weak, nonatomic) IBOutlet UIImageView *taskImg;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnAddFile;
@property (weak, nonatomic) IBOutlet UILabel *taskFile;
@property NSURL * url;
@property QLPreviewController *previewController;


@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad");
    _previewController = [[QLPreviewController alloc] init];
    _previewController.dataSource = self;
    _previewController.delegate = self;
        
    _taskDescription.layer.borderWidth = 1.0;
    _taskDescription.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _taskDescription.layer.cornerRadius = 8.0;
    
    _taskTitle.layer.borderWidth = 1.0;
    _taskTitle.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _taskTitle.layer.cornerRadius = 8.0;
    
    if(_index < 0){
        _btnSave.titleLabel.text = @"Add";
        [_taskStatus setEnabled:NO forSegmentAtIndex:1];
        [_taskStatus setEnabled:NO forSegmentAtIndex:2];
        _taskImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld",(long)_taskPriority.selectedSegmentIndex]];
        _taskData.minimumDate = [NSDate date];
        NSLog(@"index = 0");
        _url = [[NSURL alloc] initWithString: @""];
    }else{
        Task *_task = [_tasks objectAtIndex:_index];
        NSLog(@"get task");
        
        _btnSave.titleLabel.text = @"Edit";
        _taskTitle.text = _task.title;
        _taskDescription.text = _task.descript;
        _taskPriority.selectedSegmentIndex = _task.priority;
        _taskStatus.selectedSegmentIndex = _task.status;
        _taskData.date = _task.date;
        _taskData.minimumDate = _task.date;
        _taskImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",_task.priority]];
        _url = _task.file;
        _taskFile.text = [_task.file lastPathComponent];
        
        switch(_task.status){
            case 1:
                [_taskStatus setEnabled:NO forSegmentAtIndex:0];
                break;
            case 2:
                _btnSave.hidden = YES;
                _btnAddFile.hidden = YES;
                _taskTitle.enabled = NO;
                _taskDescription.editable = NO;
                _taskStatus.enabled = NO;
                _taskPriority.enabled = NO;
                _taskData.enabled = NO;
                break;
            default:
                break;
        }
    }
}

- (IBAction)saveTask:(id)sender {
    
    NSString *title = (_index >=0) ? @"Edit" : @"Add" ;
    
    if(_taskTitle.text.length < 1){
        [self showAlert:@"Roung" message:@"You can't add task with empty title!" action:nil];
    }
    else{
        [self showAlert:title message:[NSString stringWithFormat:@"Do you want to %@ this task?",title] action: [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            Task *myTask = [[Task alloc] initWithTitle:self->_taskTitle.text description:self->_taskDescription.text priority:self->_taskPriority.selectedSegmentIndex status:self->_taskStatus.selectedSegmentIndex date:self->_taskData.date file:self->_url];
            
            if (!self->_tasks) {
                self->_tasks = [NSMutableArray new];
            }
            
            if(self->_index < 0){
                [self->_tasks addObject:myTask];
            }else{
                [self->_tasks replaceObjectAtIndex:self->_index withObject:myTask];
            }
            
            [self saveData:self->_tasks];
            [self.navigationController popViewControllerAnimated:YES];
            
            [self showAlert:@"Remender" message:@"Task Saved Successfully Do you want to add this task to remender?" action: [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self addReminder:myTask];
            }]];
            
        }]];
    }
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

- (IBAction)priorityChanged:(UISegmentedControl *)sender {
    _taskImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld",(long)sender.selectedSegmentIndex]];
}

-(void) showAlert:(NSString *) title message:(NSString *)message action:(UIAlertAction *) action {
    UIAlertController * alert =[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancel];
    if(action)
        [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addReminder:(Task *)task {
    // Step 1: Request permission to display notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            NSLog(@"Notification permission denied");
            return;
        }
        
        // Step 2: Create and configure notification content
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = task.title;
        content.body = task.descript;
        content.sound = [UNNotificationSound defaultSound];
        
        // Step 3: Create the trigger for the notification
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:task.date];
        
        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
        
        // Step 4: Create the notification request
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"ToDo Task" content:content trigger:trigger];
        
        // Step 5: Schedule the notification
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error scheduling notification: %@", error);
            } else {
                NSLog(@"Notification scheduled successfully");
            }
        }];
    }];
}

- (IBAction)attachFile:(id)sender {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.content"] inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    // Handle the selected file URL(s) here
    NSLog(@"Selected URLs: %@", urls);

    NSURL *selectedFileURL;
    
    if(urls.count > 0){
        selectedFileURL = [urls firstObject];
        NSLog(@"url %@",selectedFileURL);
        
        _url = selectedFileURL;
        
        _taskFile.text = [selectedFileURL lastPathComponent];
    }else{
        _url = [[NSURL alloc] initWithString: @""];
        _taskFile.text =@"No File Attached";
    }
}

- (IBAction)openFile:(id)sender {
    [self presentViewController:_previewController animated:YES completion:nil];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1; // Return the number of items to preview (in this case, 1)
}

- (id)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    // Specify the URL of the document you want to preview
    return _url;
}

@end

//
//  DetailsViewController.h
//  ToDo
//
//  Created by JETSMobileLabMini11 on 17/04/2024.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController <UIDocumentPickerDelegate, QLPreviewControllerDataSource>
@property NSMutableArray <Task *> * tasks;
@property long index;

@end

NS_ASSUME_NONNULL_END

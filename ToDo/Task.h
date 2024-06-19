//
//  Task.h
//  ToDo
//
//  Created by JETSMobileLabMini11 on 17/04/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Task : NSObject  <NSCoding,NSSecureCoding>

@property NSString *title;
@property NSString *descript;
@property short priority;
@property short status;
@property NSDate *date;
@property NSURL *file;

- (instancetype)initWithTitle:(NSString *)title description:(NSString *)descript priority:(short)priority status:(short)status date:(NSDate *) date file:(NSURL *)file;
- (BOOL)isEqualToTask:(Task *)task;

@end

NS_ASSUME_NONNULL_END

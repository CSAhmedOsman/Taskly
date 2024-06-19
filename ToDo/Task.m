//
//  Task.m
//  ToDo
//
//  Created by JETSMobileLabMini11 on 17/04/2024.
//

#import "Task.h"

@implementation Task

- (instancetype)initWithTitle:(NSString *)title description:(NSString *)descript priority:(short)priority status:(short)status date:(NSDate *) date file:(NSURL *)file {
    self = [super init];
    if (self) {
        _title = title;
        _descript = descript;
        _priority = priority;
        _status = status;
        _date = date;
        _file = file;
    }
    return self;
}

- (BOOL)isEqualToTask:(Task *)task{
    return [_title isEqual:task.title] && [_descript isEqual:task.descript] && [_date isEqual:task.date] && [_file isEqual:task.file] && (_priority == task.priority) && (_status == task.status);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _title = [coder decodeObjectOfClass:[NSString class] forKey:@"title"];
        _descript = [coder decodeObjectOfClass:[NSString class] forKey:@"descript"];
        _priority = [coder decodeIntForKey:@"priority"];
        _status = [coder decodeIntForKey:@"status"];
        _date = [coder decodeObjectOfClass:[NSDate class] forKey:@"date"];
        _file = [coder decodeObjectOfClass:[NSURL class] forKey:@"file"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.descript forKey:@"descript"];
    [coder encodeInt:self.priority forKey:@"priority"];
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.file forKey:@"file"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

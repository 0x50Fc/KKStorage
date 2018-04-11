//
//  KKSqlite.h
//  KKStorage
//
//  Created by hailong11 on 2018/4/11.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>

@interface KKSqlite : NSObject

@property(nonatomic,readonly,assign) sqlite3 * db;
@property(nonatomic,strong,readonly) dispatch_queue_t queue;

-(instancetype) initWithFilePath:(NSString *) filePath queue:(dispatch_queue_t) queue;

+(dispatch_queue_t) defaultQueue;

@end

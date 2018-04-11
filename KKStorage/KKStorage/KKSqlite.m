//
//  KKSqlite.m
//  KKStorage
//
//  Created by hailong11 on 2018/4/11.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKSqlite.h"

@interface KKSqlite() {
    
}

@end

@implementation KKSqlite

@synthesize queue = _queue;

-(void) dealloc {
    
    if(_db) {
        
        sqlite3 * db = _db;
        
        dispatch_async(self.queue, ^{
            sqlite3_close(db);
        });
    }
    
    
}

-(instancetype) initWithFilePath:(NSString *) filePath queue:(dispatch_queue_t) queue {
    if((self = [super init])) {
        _queue = queue;
        if(SQLITE_OK != sqlite3_open([filePath UTF8String],&_db)) {
            return nil;
        }
    }
    return self;
}

-(dispatch_queue_t) queue {
    if(_queue == nil) {
        _queue = [KKSqlite defaultQueue];
    }
    return _queue;
}


+(dispatch_queue_t) defaultQueue {
    static dispatch_queue_t v = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = dispatch_queue_create("KKSqlite", nil);
    });
    return v;
}


@end

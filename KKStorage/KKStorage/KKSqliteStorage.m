//
//  KKSqliteStorage.m
//  KKStorage
//
//  Created by hailong11 on 2018/4/11.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKSqliteStorage.h"

#include <sqlite3.h>

@interface KKSqliteStorage() {

}

@end

@implementation KKSqliteStorage


-(instancetype) initWithSqlite:(KKSqlite *) sqlite name:(NSString *) name {
    if((self = [super init])) {
        _sqlite = sqlite;
        _name = name;
        
        if(_sqlite == nil) {
            return nil;
        }
        
        sqlite3 * db = _sqlite.db;
        
        dispatch_async(_sqlite.queue, ^{
            
            char * errmsg = NULL;
            
            if(SQLITE_OK != sqlite3_exec(db,[[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS [%@](key VARCHAR(4096) PRIMARY KEY , value TEXT)",name] UTF8String],NULL,NULL,&errmsg)) {
                NSLog(@"[KK] %s", errmsg);
            }
            
        });
        
    }
    return self;
}

-(id) kk_getValue:(NSString *) key {
    
    if(_sqlite == nil) {
        return nil;
    }
    
    sqlite3 * db = _sqlite.db;
    NSString * name = _name;
    
    __block id v = nil;
    
    dispatch_sync(_sqlite.queue, ^{
        
        sqlite3_stmt * stmt;
        
        if(sqlite3_prepare_v2(db, [[NSString stringWithFormat:@"SELECT value FROM [%@] WHERE key=@key",name] UTF8String], -1, &stmt, NULL) != SQLITE_OK){
            NSLog(@"[KK] %s", sqlite3_errmsg(db));
            return;
        }
        
        if(sqlite3_step(stmt) == SQLITE_ROW) {
            
            char * text = (char *) sqlite3_column_text(stmt,1);
            
            if(text != NULL){
                NSData * data = [NSData dataWithBytesNoCopy:text length:strlen(text)];
                v = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            }
        }
        
        sqlite3_finalize(stmt);
        
    });
    
    return v;
}

-(void) kk_setValue:(NSString *) key value:(id) value {
    
    if(_sqlite == nil) {
        return ;
    }
    
    sqlite3 * db = _sqlite.db;
    NSString * name = _name;
    
    dispatch_async(_sqlite.queue, ^{
        
        BOOL hasKey = NO;
        
        sqlite3_stmt * stmt;
        
        if(sqlite3_prepare_v2(db, [[NSString stringWithFormat:@"SELECT key FROM [%@] WHERE key=@key",name] UTF8String], -1, &stmt, NULL) != SQLITE_OK){
            NSLog(@"[KK] %s", sqlite3_errmsg(db));
            return;
        }
        
        sqlite3_bind_text(stmt,1, [key UTF8String],-1,SQLITE_STATIC);
        
        if(sqlite3_step(stmt) == SQLITE_ROW) {
            hasKey = YES;
        }
        
        sqlite3_finalize(stmt);
        
        if(hasKey) {
            
            if(sqlite3_prepare_v2(db, [[NSString stringWithFormat:@"UPDATE [%@] SET value=@value WHERE key=@key",name] UTF8String], -1, &stmt, NULL) != SQLITE_OK){
                NSLog(@"[KK] %s", sqlite3_errmsg(db));
                return;
            }
            
            NSData * data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
            
            sqlite3_bind_text(stmt,1, [data bytes], (int) [data length] ,SQLITE_STATIC);
            
            sqlite3_bind_text(stmt,2, [key UTF8String],-1,SQLITE_STATIC);
            
            int r = sqlite3_step(stmt);
            
            if(r != SQLITE_ROW && r != SQLITE_OK && r != SQLITE_DONE) {
                NSLog(@"[KK] %s", sqlite3_errmsg(db));
            }
            
            sqlite3_finalize(stmt);
            
        } else {
            
            if(sqlite3_prepare_v2(db, [[NSString stringWithFormat:@"INSERT [%@](key,value) VALUES (@key,@value) ",name] UTF8String], -1, &stmt, NULL) != SQLITE_OK){
                NSLog(@"[KK] %s", sqlite3_errmsg(db));
                return;
            }
            
            sqlite3_bind_text(stmt,1, [key UTF8String],-1,SQLITE_STATIC);
            
            NSData * data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
            
            sqlite3_bind_text(stmt,2, [data bytes], (int) [data length] ,SQLITE_STATIC);
            
            int r = sqlite3_step(stmt);
            
            if(r != SQLITE_ROW && r != SQLITE_OK && r != SQLITE_DONE) {
                NSLog(@"[KK] %s", sqlite3_errmsg(db));
            }
            
            sqlite3_finalize(stmt);
            
        }
        
        
    });
    
}

@end

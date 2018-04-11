//
//  KKSqliteStorage.h
//  KKStorage
//
//  Created by hailong11 on 2018/4/11.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KKStorage/KKStorageProtocol.h>
#import <KKStorage/KKSqlite.h>

@interface KKSqliteStorage : NSObject<KKStorageProtocol>

@property(nonatomic,strong,readonly) NSString * name;
@property(nonatomic,strong,readonly) KKSqlite * sqlite;

-(instancetype) initWithSqlite:(KKSqlite *) sqlite name:(NSString *) name;

@end

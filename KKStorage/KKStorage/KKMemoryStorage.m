//
//  KKMemoryStorage.m
//  KKStorage
//
//  Created by hailong11 on 2018/4/11.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKMemoryStorage.h"

@interface KKMemoryStorage() {
    NSMutableDictionary * _object;
}

@end

@implementation KKMemoryStorage

-(id) kk_getValue:(NSString *) key {
    return [_object valueForKey:key];
}

-(void) kk_setValue:(NSString *) key value:(id) value {
    if(value == nil) {
        [_object removeObjectForKey:key];
    } else {
        if(_object == nil) {
            _object = [[NSMutableDictionary alloc] initWithCapacity:4];
        }
        [_object setValue:value forKey:key];
    }
}

@end

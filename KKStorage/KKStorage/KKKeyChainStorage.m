//
//  KKKeyChainStorage.m
//  KKStorage
//
//  Created by hailong11 on 2018/4/11.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKKeyChainStorage.h"

@interface KKKeyChainStorage() {
    NSString * _name;
    NSMutableDictionary * _object;
    BOOL _synchronizing;
}

@end

@implementation KKKeyChainStorage

-(instancetype) initWithName:(NSString *) name {
    if((self = [super init])) {
        _name = name;
        _synchronizing = NO;
    }
    return self;
}

-(NSMutableDictionary *) object {
    
    if(_object == nil){
        
        NSMutableDictionary * query = [NSMutableDictionary dictionaryWithObjectsAndKeys:(NSString *)kSecClassGenericPassword,(NSString *)kSecClass
                                       , _name,(NSString *) kSecAttrAccount
                                       , _name,(NSString *) kSecAttrService
                                       , _name,(NSString *) kSecAttrLabel
                                       , [NSNumber numberWithBool:YES],(NSString *) kSecReturnData
                                       , nil];
        
        CFDataRef v = nil;
        
        OSStatus status = SecItemCopyMatching((CFDictionaryRef)query,(CFTypeRef *) & v);
        
        if(status != noErr){
            SecItemDelete((CFDictionaryRef) query);
        }
        
        if(v == nil){
            
            _object = [[NSMutableDictionary alloc] initWithCapacity:4];
            
            NSMutableData * data = [NSMutableData dataWithCapacity:128];
            
            NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            
            [_object encodeWithCoder:archiver];
            
            [archiver finishEncoding];
            
            [query removeObjectForKey:(NSString *)kSecReturnData];
            [query setValue:data forKey:(NSString *)kSecValueData];
            
            SecItemAdd( (CFDictionaryRef) query, nil);
        }
        else{
            
            NSKeyedUnarchiver * archiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:(__bridge NSData *) v];
            
            _object = [[NSMutableDictionary alloc] initWithCoder:archiver];
            
            [archiver finishDecoding];
            
            CFRelease(v);
            
        }
    }
    
    if(_object == nil){
        _object = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    return _object;
}

-(void) synchronize {
    
    NSMutableData * data = [NSMutableData dataWithCapacity:128];
    
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [[self object] encodeWithCoder:archiver];
    
    [archiver finishEncoding];
    
    NSDictionary * query = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)kSecClassGenericPassword,(NSString *)kSecClass
                            , _name,(NSString *) kSecAttrAccount
                            , _name,(NSString *) kSecAttrService
                            , _name,(NSString *) kSecAttrLabel
                            , nil];
    
    SecItemUpdate((CFDictionaryRef) query, (CFDictionaryRef) [NSDictionary dictionaryWithObject:data forKey:(NSString *)kSecValueData]);
    
    _synchronizing = NO;
}

-(id) kk_getValue:(NSString *) key {
    return [[self object] valueForKey:key];
}

-(void) kk_setValue:(NSString *) key value:(id) value {
    
    if(value == nil) {
        [[self object] removeObjectForKey:key];
    } else {
        [[self object] setValue:value forKey:key];
    }
    
    if(!_synchronizing) {
        
        _synchronizing = YES;
        
        __weak KKKeyChainStorage * v = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(v) {
                [v synchronize];
            }
        });
    }
}

@end

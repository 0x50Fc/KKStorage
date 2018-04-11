//
//  KKStorageProtocol.h
//  KKStorage
//
//  Created by hailong11 on 2018/4/11.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KKStorageProtocol <NSObject>

-(id) kk_getValue:(NSString *) key;

-(void) kk_setValue:(NSString *) key value:(id) value;

@end

//
//  GlobalCache.h
//  ChangNet
//
//  Created by len on 16/6/16.
//  Copyright © 2016年 len. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPGlobalCache : NSObject

+ (instancetype)shareCache;

- (BOOL)containsObjectForKey:(id)key;

- (id)objectForKey:(id)key;

- (void)setObject:(id)object forKey:(id)key;

- (void)removeObjectForKey:(id)key;

- (void)removeAllObjects;
@end

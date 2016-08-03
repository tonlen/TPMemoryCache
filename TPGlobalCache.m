//
//  GlobalCache.m
//  ChangNet
//
//  Created by len on 16/6/16.
//  Copyright © 2016年 len. All rights reserved.
//

#import "TPGlobalCache.h"
#import <CoreFoundation/CoreFoundation.h>
#import <pthread.h>

static inline dispatch_queue_t TPCacheGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

@implementation TPGlobalCache{
    pthread_mutex_t _lock;
    CFMutableDictionaryRef _dic;
}

+ (instancetype)shareCache
{
    static dispatch_once_t onceToken;
    static TPGlobalCache *globalCache;
    dispatch_once(&onceToken, ^{
        globalCache = [[self alloc] init];
    });
    return globalCache;
}

- (instancetype)init
{
    self = super.init;
    pthread_mutex_init(&_lock, NULL);
    _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return self;
}

- (BOOL)containsObjectForKey:(id)key {
    if (!key) return NO;
    pthread_mutex_lock(&_lock);
    BOOL contains = CFDictionaryContainsKey(_dic, (__bridge const void *)(key));
    pthread_mutex_unlock(&_lock);
    return contains;
}

- (id)objectForKey:(id)key {
    if (!key) return nil;
    pthread_mutex_lock(&_lock);
    id value = CFDictionaryGetValue(_dic, (__bridge const void *)(key));

    pthread_mutex_unlock(&_lock);
    return value ? value : nil;
}

- (void)setObject:(id)object forKey:(id)key {
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost {
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    pthread_mutex_lock(&_lock);
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(key));
    CFDictionarySetValue(_dic, (__bridge const void *)(key), (__bridge const void *)(object));
    pthread_mutex_unlock(&_lock);
}

- (void)removeObjectForKey:(id)key {
    if (!key) return;
    pthread_mutex_lock(&_lock);
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(key));
    pthread_mutex_unlock(&_lock);
}

- (void)removeAllObjects {
    pthread_mutex_lock(&_lock);
    if (CFDictionaryGetCount(_dic) > 0) {
        CFMutableDictionaryRef holder = _dic;
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            dispatch_queue_t queue = TPCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                CFRelease(holder); // hold and release in specified queue
            });
    }
    pthread_mutex_unlock(&_lock);
}
@end

//
//  main.m
//  concurrency-pthread
//
//  Created by Eahom on 15/3/9.
//  Copyright (c) 2015年 app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

struct threadInfo {
    uint32_t *inputValues;
    size_t count;
};

struct threadResult {
    uint32_t min;
    uint32_t max;
};

void *findMinAndMax(void *arg)
{
    struct threadInfo const * const info = (struct threadInfo *)arg;
    uint32_t min = UINT32_MAX;
    uint32_t max = 0;
    
    for (size_t i = 0; i < info->count; ++i) {
        uint32_t v = info->inputValues[i];
        min = MIN(min, v);
        max = MAX(max, v);
    }
    
    free(arg);
    struct threadResult * const result = (struct threadResult *)malloc(sizeof(struct threadResult));
    result->max = max;
    result->min = min;
    
    return result;
}

int main(int argc, const char * argv[]) {
    size_t const count = 1000000;
    uint32_t inputValues[count];
    
    // Fill input values with random numbers:
    for (size_t i = 0; i < count; ++i) {
        inputValues[i] = arc4random();
    }
    
    // Spawn 4 threads to find the minimum and maximum:
    size_t const threadCount = 4;
    pthread_t tid[threadCount];
    for (size_t i = 0; i < threadCount; ++i) {
        struct threadInfo * const info = (struct threadInfo *) malloc(sizeof(*info));
        size_t offset = (count / threadCount) * i;
        info->inputValues = inputValues + offset;
        info->count = MIN(count - offset, count / threadCount);
        int err = pthread_create(tid + i, NULL, &findMinAndMax, info);
        NSCAssert(err == 0, @"pthread_create() failed: %d", err);
    }
    // Wait for the threads to exit:
    struct threadResult * results[threadCount];
    for (size_t i = 0; i < threadCount; ++i) {
        int err = pthread_join(tid[i], (void **) &(results[i]));
        NSCAssert(err == 0, @"pthread_join() failed: %d", err);
    }
    // Find the min and max:
    uint32_t min = UINT32_MAX;
    uint32_t max = 0;
    for (size_t i = 0; i < threadCount; ++i) {
        min = MIN(min, results[i]->min);
        max = MAX(max, results[i]->max);
        free(results[i]);
        results[i] = NULL;
    }
    
    NSLog(@"min = %u", min);
    NSLog(@"max = %u", max);
    
    return 0;
}

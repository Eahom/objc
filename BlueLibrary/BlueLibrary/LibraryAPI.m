//
//  LibraryAPI.m
//  BlueLibrary
//
//  Created by InfyMacBook on 18/03/15.
//  Copyright (c) 2015 Eli Ganem. All rights reserved.
//

#import "LibraryAPI.h"

#import "PersistencyManager.h"
#import "HTTPClient.h"

@interface LibraryAPI () {
    PersistencyManager *persistencyManager;
    HTTPClient *httpClient;
    BOOL isOnline;
}

@end

@implementation LibraryAPI

# pragma mark singleton pattern
+ (LibraryAPI *)sharedInstance
{
#pragma mark 1. Declare a static variable to hold the instance of the class, ensuring it's available globally inside the class.
#pragma mark -- 声明一个静态变量去保存类的实例，确保它在类中的全局可用性
    static LibraryAPI *_sharedInstance = nil;
    
#pragma mark 2. Declare the static variable dispaath_once_t which ensures that the initialization code executes only once.
#pragma mark -- 声明一个静态变量dispatch_once_t ,它确保初始化器代码只执行一次
    static dispatch_once_t oncePredicate;
    
#pragma mark 3. Use Grand Central Dispatch(GCD) to excute a block which initializes an instance of the class. This is the essence of the Singleton design pattern: the initializer is never called again once the class has been instantiated
#pragma mark -- 使用Grand Central Dispatch(GCD)执行初始化LibraryAPI变量的block.这  正是单例模式的关键：一旦类已经被初始化，初始化器永远不会再被调用
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        persistencyManager = [[PersistencyManager alloc] init];
        
        httpClient = [[HTTPClient alloc] init];
        
        isOnline = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImage:) name:@"BLDownloadImageNotification" object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)getAlbums
{
    return [persistencyManager getAlbums];
}

- (void)addAlbum:(Album *)album atIndex:(int)index
{
    [persistencyManager addAlbum:album atIndex:index];
    
    if (isOnline) {
        [httpClient postRequest:@"/api/addAlbum" body:[album description]];
    }
}

- (void)deleteAlbumAtIndex:(int)index
{
    [persistencyManager deleteAlbumAtIndex:index];
    
    if (isOnline) {
        [httpClient postRequest:@"/api/deleteAlbum" body:[@(index) description]];
    }
}

- (void)downloadImage:(NSNotification *)notification
{
    // 1
    UIImageView *imageView = notification.userInfo[@"imageView"];
    NSString *coverUrl = notification.userInfo[@"coverUrl"];
    
    // 2
    imageView.image = [persistencyManager getImage:[coverUrl lastPathComponent]];
    if (imageView.image == nil) {
        // 3
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [httpClient downloadImage:coverUrl];
            
            // 4
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = image;
                
                [persistencyManager saveImage:image filename:[coverUrl lastPathComponent]];
            });
        });
    }
}

- (void)saveAlbums
{
    [persistencyManager saveAlbums];
}
@end

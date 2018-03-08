//
//  AppDelegate.h
//  Receipts
//
//  Created by Jose on 26/2/18.
//  Copyright © 2018 appcat.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow* window;

@property (readonly, strong) NSPersistentContainer* persistentContainer;

- (void)saveContext;


@end


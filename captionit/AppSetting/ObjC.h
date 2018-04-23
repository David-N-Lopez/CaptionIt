//
//  ObjC.h
//  ColorMatters
//
//  Created by Jay Van Buiten on 11/24/16.
//  Copyright © 2016 Jay Van Buiten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)())tryBlock error:(__autoreleasing NSError **)error;
+ (void)SwizzleMethod:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end

//
//  ObjC.m
//  ColorMatters
//
//  Created by Jay Van Buiten on 11/24/16.
//  Copyright © 2016 Jay Van Buiten. All rights reserved.
//

#import "ObjC.h"
#import "NSDictionary+JSON.h"

@import ObjectiveC.runtime;

@implementation ObjC

+ (BOOL)catchException:(void (^)())tryBlock error:(NSError *__autoreleasing *)error {
    
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException * exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
    }
    return NO;
}


+ (void)SwizzleMethod:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    IMP swizzledImplemention = method_getImplementation(swizzledMethod);
    const char *swizzledTypeEncoding = method_getTypeEncoding(swizzledMethod);
    
    BOOL addMethod = class_addMethod(class, originalSelector, swizzledImplemention, swizzledTypeEncoding);
    
    if (addMethod) {
        IMP originalImplemention = method_getImplementation(originalMethod);
        const char *originalTypeEncoding = method_getTypeEncoding(originalMethod);
        
        class_replaceMethod(class, swizzledSelector, originalImplemention, originalTypeEncoding);
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end

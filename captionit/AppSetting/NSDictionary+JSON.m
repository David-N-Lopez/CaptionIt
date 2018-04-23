//
//  NSDictionary+JSON.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

+ (nullable id)jsonFromString:(nullable NSString *)strJson {
    
    NSError * error;
    if (strJson == nil) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
}

+ (nullable id)jsonFromData:(nullable NSData *)data {
    
    NSError * error;
    if (data == nil) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

- (nullable NSString *)toJsonString {
    
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    
    if (jsonData == nil) {
        return @"";
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (nullable id)optObject:(nonnull NSString *)key {
    return [self valueForKey:key];
}

- (nullable id)optObject:(nonnull NSString *)key default:(nullable id)defval {
    
    id jsonObject = [self optObject:key];
    if (jsonObject == nil) {
        return defval;
    }
    return jsonObject;
}

- (nullable NSArray *)optArray:(nonnull NSString *)key {
    
    id jsonObject = [self valueForKey:key];
    if (jsonObject && [jsonObject isKindOfClass:[NSArray class]]) {
        return jsonObject;
    }
    return nil;
}

- (nullable NSArray *)optArray:(nonnull NSString *)key default:(nullable NSArray *)defval {
    
    id jsonArray = [self optArray:key];
    if (jsonArray == nil) {
        return defval;
    }
    return jsonArray;
}

- (NSInteger)optInt:(nonnull NSString *)key default:(NSInteger)defval {
    
    id jsonObject = [self valueForKey:key];
    
    if (jsonObject == nil) {
        return defval;
    }
    
    if ([jsonObject isKindOfClass:[NSNumber class]] || [jsonObject isKindOfClass:[NSString class]]) {
        return [jsonObject integerValue];
    }
    
    return defval;
}

- (BOOL)optBool:(nonnull NSString *)key default:(BOOL)defval {
    
    id jsonObject = [self valueForKey:key];
    
    if (jsonObject == nil) {
        return defval;
    }
    
    if ([jsonObject isKindOfClass:[NSNumber class]] || [jsonObject isKindOfClass:[NSString class]]) {
        return [jsonObject boolValue];
    }
    
    return defval;
}

- (double)optDouble:(nonnull NSString *)key default:(double)defval {
    
    id jsonObject = [self valueForKey:key];
    
    if (jsonObject == nil) {
        return defval;
    }
    
    if ([jsonObject isKindOfClass:[NSNumber class]] || [jsonObject isKindOfClass:[NSString class]]) {
        return [jsonObject doubleValue];
    }
    
    return defval;
}

- (nullable NSString *)optString:(nonnull NSString *)key {
    
    id jsonObject = [self valueForKey:key];
    if (jsonObject != nil) {
        if ([jsonObject isKindOfClass:[NSString class]]) {
            return jsonObject;
        } else if ([jsonObject isKindOfClass:[NSNumber class]]) {
            NSNumber * number = (NSNumber *) jsonObject;
            return [number stringValue];
        }
    }
    return nil;
}

- (nullable NSString *)optString:(nonnull NSString *)key default:(nullable NSString *)defval {
    
    id jsonString = [self optString:key];
    if (jsonString == nil) {
        return defval;
    }
    return jsonString;
}

@end

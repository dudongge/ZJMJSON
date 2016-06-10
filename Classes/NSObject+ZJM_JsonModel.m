//
//  NSObject+ZJM_JsonModel.m
//  TestJsonModel
//
//  Created by JiaMeng.Zheng on 16/5/28.
//  Copyright © 2016年 live.bilibili.com. All rights reserved.
//

#import "NSObject+ZJM_JsonModel.h"
#include <assert.h>
@implementation NSObject (ZJM_JsonModel)
static char mappingDicKey;
+(id)ZJM_ObjectWithValue:(id)dic withObjectInModel:(ObjectInModelBlock)DicBlock {
    NSDictionary *mappingDic = DicBlock();
    objc_setAssociatedObject(self, &mappingDicKey, mappingDic, OBJC_ASSOCIATION_RETAIN);
    Class cla = [self class];
    id model = [[cla alloc] init];
    model = [cla ZJM_ObjectWithValue:dic];
    return model;
}
+(id)ZJM_ObjectWithValue:(id)dic {
    //得到所有属性
    NSMutableArray *allNames = [[NSMutableArray alloc] init];
    unsigned int propertyCount = 0;
    objc_property_t *propertys = class_copyPropertyList([self class], &propertyCount);

    for (int i = 0; i < propertyCount; i ++) {
        objc_property_t property = propertys[i];

        const char * propertyName = property_getName(property);

        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    free(propertys);
    
    //得到JSON的所有key
    NSArray *allKeys = [NSArray array];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        allKeys = [((NSDictionary *)dic) allKeys];
    }
    
    Class cla = [self class];
    id model = [[cla alloc] init];
    for (NSString *p in allKeys) {
        
        NSAssert([allNames containsObject:p], @"没有对应的属性");
        
        id pValue = [((NSDictionary *)dic) valueForKey:p];
        ZJM_ValueType valueType = [self ZJM_getValueTypeBy:pValue];
        id propertyValue;
        switch (valueType) {
            case ZJM_ARRAY:{
                propertyValue = [self ZJM_getArrayModelBy:pValue andKey:p];
            }
                break;
            case ZJM_DIC: {
                propertyValue = [self ZJM_getObjectPropertyBy:pValue andKey:p];
            }
                break;
            case ZJM_STRING:
                propertyValue = pValue;
                break;
            default:
                break;
        }
        [model setValue:propertyValue forKey:p];
    }
    return model;
    
}
-(ZJM_ValueType)ZJM_getValueTypeBy:(id)value {
    if ([value isKindOfClass:[NSArray class]]) {
        return ZJM_ARRAY;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        return ZJM_DIC;
    } else if ([value isKindOfClass:[NSString class]]) {
        return ZJM_STRING;
    } else {
        return ZJM_OBJ;
    }
}
-(id)ZJM_getArrayModelBy:(id)valueArr andKey:(NSString*)key {
    NSMutableArray *arr = [NSMutableArray array];
    NSDictionary *mappingDic = objc_getAssociatedObject(self, &mappingDicKey);
    NSString *className = [mappingDic valueForKey:key];
    Class cla = NSClassFromString(className);
    if ([valueArr isKindOfClass:[NSArray class]]) {
        for (id value in valueArr) {
            id propertValue = [cla ZJM_ObjectWithValue:value];
            [arr addObject:propertValue];
        }
    }
    return arr;
}
-(id)ZJM_getObjectPropertyBy:(NSDictionary*)dic andKey:(NSString*)key
{
    NSDictionary *mappingDic = objc_getAssociatedObject(self, &mappingDicKey);
    NSString *className = [mappingDic valueForKey:key];
    Class cls = NSClassFromString(className);
    id propertyValue = [cls ZJM_ObjectWithValue:dic];
    return propertyValue;
}

@end

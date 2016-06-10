//
//  NSObject+ZJM_JsonModel.h
//  TestJsonModel
//
//  Created by JiaMeng.Zheng on 16/5/28.
//  Copyright © 2016年 live.bilibili.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
typedef NS_ENUM(NSInteger, ZJM_ValueType) {
    ZJM_ARRAY = 0,
    ZJM_STRING,
    ZJM_DIC,
    ZJM_OBJ,
    
};
typedef NSDictionary *(^ObjectInModelBlock)();
@interface NSObject (ZJM_JsonModel)
+(id)ZJM_ObjectWithValue:(id)dic;
+(id)ZJM_ObjectWithValue:(id)dic withObjectInModel:(ObjectInModelBlock)DicBlock;
@end

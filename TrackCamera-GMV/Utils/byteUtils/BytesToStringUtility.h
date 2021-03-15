//
//  BytesToStringUtility.h
//  Magic_AM
//
//  Created by qdum_mini_one on 16/2/23.
//  Copyright © 2016年 qdum_mini. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BytesToStringUtility:NSObject

+(NSString*)hexadecimalString:(NSData *)data;

+(NSString*)int10To16String:(int )a;
@end





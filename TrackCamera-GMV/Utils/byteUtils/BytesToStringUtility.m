//
//  BytesToStringUtility.m
//  Magic_AM
//
//  Created by qdum_mini_one on 16/2/23.
//  Copyright © 2016年 qdum_mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BytesToStringUtility.h"
@implementation BytesToStringUtility

+(NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        //Mark-BUG??
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

+(NSString*)int10To16String:(int )a{
    NSString *str = [ [NSString alloc] initWithFormat:@"%x",a];
    
    return str;
}

@end

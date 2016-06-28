//
//  ViewController.m
//  iOS 一些常用公共方法
//
//  Created by MAC on 16/6/28.
//  Copyright © 2016年 Jchao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


+ (long long)fileSizeAtPath:(NSString *)filePath{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) return 0;
    return [[fileManager attributesOfFileSystemForPath:filePath error:nil] fileSize];
}

//  获取文件夹下所有文件大小
+ (long long)folderSizeAtPath:(NSString *)folderPath{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator * fileEnumerator = [[fileManager subpathsAtPath:folderPath] objectEnumerator];
    NSString * fileName;
    long long folerSize = 0;
    while ((fileName = [fileEnumerator nextObject]) != nil) {
        NSString * filepath = [folderPath stringByAppendingPathComponent:fileName];
        folerSize += [self fileSizeAtPath:filepath];
    }
    return folerSize;
}

//  获取字符串(或汉字)首字母
+ (NSString *)firstCharacterWithString:(NSString *)string{
    NSMutableString * str = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString * pingyin = [str capitalizedString];
    return [pingyin substringFromIndex:1];
}


//   将字符串数组按照元素首字母顺序进行排序分组
+ (NSDictionary *)dictionaryOrderByCharacterWithOriginalArray:(NSArray *)array{
    if (array.count == 0) {
        return nil;
    }
    for (id obj in array) {
        if (![obj isKindOfClass:[NSString class]]) {
            return nil;
        }
    }
    UILocalizedIndexedCollation * indexedCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray * objects = [NSMutableArray arrayWithCapacity:indexedCollation.sectionTitles.count];
    //  创建27个分组数组
    for (int i = 0; i < indexedCollation.sectionTitles.count; i++ ) {
        NSMutableArray * obj = [NSMutableArray array];
        [objects addObject:obj];
    }
    NSMutableArray * keys = [NSMutableArray arrayWithCapacity:objects.count];
    //  按字母顺序进行分组
    NSInteger lastIndex = -1;
    for (int i = 0; i < array.count; i++) {
        NSInteger index = [indexedCollation sectionForObject:array[i] collationStringSelector:@selector(uppercaseString)];
        [[objects objectAtIndex:index] addObject:array[i]];
        lastIndex = index;
    }
    //  去掉空数组
    for (int i = 0 ; i < objects.count; i++) {
        NSMutableArray * obj = objects[i];
        if (obj.count == 0) {
            [objects removeObject:obj];
        }
    }
    //  获取索引字母
    for (NSMutableArray * obj in objects) {
        NSString * str = obj[0];
        NSString * key = [self firstCharacterWithString:str];
        [keys addObject:key];
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:objects forKey:keys];
    return dict;
}


//  判断手机号码格式是否正确
+ (BOOL)valiMoblle:(NSString *)mobile{
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11) {
        return NO;
    }else{
        /*  移动号码正则表达式   */
        NSString * CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /*  联通号码正则表达式   */
        NSString * CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5-6]))\\d{8}|(1709)\\d{7}$";
        /*  电信号码正则表达式   */
        NSString * CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate * pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate * pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate * pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else
        {
            return NO;
        }
    }
}

//  判断邮箱格式是否正确
+ (BOOL)isAvailableEmail:(NSString *)email{
    NSString * emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate * emaileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL reg = [emaileTest evaluateWithObject:email];
    return reg;
}

//  将十六进制颜色转换为 UIColor 对象
+ (UIColor *)colorWithHexString:(NSString *)color{
    NSString * cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    //  string should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    //  strip "0X" or "#" if it appears
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6) {
        return [UIColor clearColor];
    }
    //  Separate into r,g,b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //  r
    NSString * rString = [cString substringWithRange:range];
    //  g
    range.location = 2;
    NSString * gString = [cString substringWithRange:range];
    //  b
    range.location = 4;
    NSString * bString = [cString substringWithRange:range];
    //  Scan values
    unsigned int r,g,b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

//  全屏截图
+ (UIImage *)shotScreen{
    UIWindow * windou = [UIApplication sharedApplication].keyWindow;
    UIGraphicsBeginImageContext(windou.bounds.size);
    [windou.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}




@end

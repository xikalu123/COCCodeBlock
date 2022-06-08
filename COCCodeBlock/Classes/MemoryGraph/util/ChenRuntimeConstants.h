//
//  ChenRuntimeConstants.h
//  COCCodeBlock
//
//  Created by chenyuliang on 2022/6/8.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(char, CHENTypeEncoding) {
    CHENTypeEncodingNull             = '\0',
    CHENTypeEncodingUnknown          = '?',
    CHENTypeEncodingChar             = 'c',
    CHENTypeEncodingInt              = 'i',
    CHENTypeEncodingShort            = 's',
    CHENTypeEncodingLong             = 'l',
    CHENTypeEncodingLongLong         = 'q',
    CHENTypeEncodingUnsignedChar     = 'C',
    CHENTypeEncodingUnsignedInt      = 'I',
    CHENTypeEncodingUnsignedShort    = 'S',
    CHENTypeEncodingUnsignedLong     = 'L',
    CHENTypeEncodingUnsignedLongLong = 'Q',
    CHENTypeEncodingFloat            = 'f',
    CHENTypeEncodingDouble           = 'd',
    CHENTypeEncodingLongDouble       = 'D',
    CHENTypeEncodingCBool            = 'B',
    CHENTypeEncodingVoid             = 'v',
    CHENTypeEncodingCString          = '*',
    CHENTypeEncodingObjcObject       = '@',
    CHENTypeEncodingObjcClass        = '#',
    CHENTypeEncodingSelector         = ':',
    CHENTypeEncodingArrayBegin       = '[',
    CHENTypeEncodingArrayEnd         = ']',
    CHENTypeEncodingStructBegin      = '{',
    CHENTypeEncodingStructEnd        = '}',
    CHENTypeEncodingUnionBegin       = '(',
    CHENTypeEncodingUnionEnd         = ')',
    CHENTypeEncodingQuote            = '\"',
    CHENTypeEncodingBitField         = 'b',
    CHENTypeEncodingPointer          = '^',
    CHENTypeEncodingConst            = 'r'
}; //NS_SWIFT_NAME(CHEN.TypeEncoding);
NS_ASSUME_NONNULL_END

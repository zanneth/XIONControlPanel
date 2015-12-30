//
//  NSValue+XIONAdditions.m
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

#import "NSValue+XIONAdditions.h"

@implementation NSValue (XIONAdditions)

- (instancetype)initWithGLKMatrix3:(GLKMatrix3)matrix
{
    return [self initWithBytes:&matrix objCType:@encode(GLKMatrix3)];
}

- (instancetype)initWithGLKMatrix4:(GLKMatrix4)matrix
{
    return [self initWithBytes:&matrix objCType:@encode(GLKMatrix4)];
}

+ (instancetype)valueWithGLKMatrix3:(GLKMatrix3)matrix
{
    return [[[self class] alloc] initWithGLKMatrix3:matrix];
}

+ (instancetype)valueWithGLKMatrix4:(GLKMatrix4)matrix
{
    return [[[self class] alloc] initWithGLKMatrix4:matrix];
}

- (GLKMatrix3)GLKMatrix3Value
{
    GLKMatrix3 mat;
    [self getValue:&mat];
    return mat;
}

- (GLKMatrix4)GLKMatrix4Value
{
    GLKMatrix4 mat;
    [self getValue:&mat];
    return mat;
}

@end

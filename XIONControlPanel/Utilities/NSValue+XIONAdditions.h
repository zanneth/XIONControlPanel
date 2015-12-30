//
//  NSValue+XIONAdditions.h
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface NSValue (XIONAdditions)

- (instancetype)initWithGLKMatrix3:(GLKMatrix3)matrix;
- (instancetype)initWithGLKMatrix4:(GLKMatrix4)matrix;

+ (instancetype)valueWithGLKMatrix3:(GLKMatrix3)matrix;
+ (instancetype)valueWithGLKMatrix4:(GLKMatrix4)matrix;

- (GLKMatrix3)GLKMatrix3Value;
- (GLKMatrix4)GLKMatrix4Value;

@end

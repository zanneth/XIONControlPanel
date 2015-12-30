//
//  HorizontalBlur.vsh
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

attribute vec4  a_position;
varying vec2    v_uv;
varying vec2    v_blurTexCoords[14];

void main()
{
    v_uv = (a_position.xy + 1.0) * 0.5;
    v_blurTexCoords[ 0] = v_uv + vec2(-0.028, 0.0);
    v_blurTexCoords[ 1] = v_uv + vec2(-0.024, 0.0);
    v_blurTexCoords[ 2] = v_uv + vec2(-0.020, 0.0);
    v_blurTexCoords[ 3] = v_uv + vec2(-0.016, 0.0);
    v_blurTexCoords[ 4] = v_uv + vec2(-0.012, 0.0);
    v_blurTexCoords[ 5] = v_uv + vec2(-0.008, 0.0);
    v_blurTexCoords[ 6] = v_uv + vec2(-0.004, 0.0);
    v_blurTexCoords[ 7] = v_uv + vec2( 0.004, 0.0);
    v_blurTexCoords[ 8] = v_uv + vec2( 0.008, 0.0);
    v_blurTexCoords[ 9] = v_uv + vec2( 0.012, 0.0);
    v_blurTexCoords[10] = v_uv + vec2( 0.016, 0.0);
    v_blurTexCoords[11] = v_uv + vec2( 0.020, 0.0);
    v_blurTexCoords[12] = v_uv + vec2( 0.024, 0.0);
    v_blurTexCoords[13] = v_uv + vec2( 0.028, 0.0);

    gl_Position = a_position;
}

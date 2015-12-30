//
//  FirstPass.vsh
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

attribute vec4  a_position;
varying vec2    v_uv;

void main()
{
    v_uv = (a_position.xy + 1.0) * 0.5;
    gl_Position = a_position;
}

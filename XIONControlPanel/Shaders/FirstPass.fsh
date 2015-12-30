//
//  FirstPass.fsh
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

uniform sampler2D   u_colorSampler;
varying vec2        v_uv;

void main()
{
    gl_FragColor = texture2D(u_colorSampler, v_uv);
}

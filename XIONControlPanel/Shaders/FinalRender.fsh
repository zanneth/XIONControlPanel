//
//  FinalRender.fsh
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

uniform sampler2D   u_colorSampler;
uniform sampler2D   u_blurmapSampler;
varying vec2        v_uv;

float saturate(float v)
{
    return clamp(v, 0.0, 1.0);
}

void main()
{
    vec4 color = texture2D(u_colorSampler, v_uv) + texture2D(u_blurmapSampler, v_uv);
    float dist = length(v_uv - vec2(0.5));
    gl_FragColor = saturate(1.0 / (8.0 * (dist + 0.1))) * color;
}





uniform sampler2D colorMap, normalMap, posMap;
uniform float c_phi, n_phi, p_phi, stepwidth;
uniform float kernel[25];
uniform vec2 offset[25];

void main(void)
{
    vec4 sum = vec4(0.0);
    vec2 step = vec2(1. / 512., 1. / 512.); // resolution
    //颜色
    vec4 cval = texture2D(colorMap, gl_TexCoord[0].st);
    //法线
    vec4 nval = texture2D(normalMap, gl_TexCoord[0].st);
    //位置
    vec4 pval = texture2D(posMap, gl_TexCoord[0].st);
    float cum_w = 0.0;
    for (int i = 0; i < 25; i++)
    {
        //遍历滤波区域像素，获取UV
        vec2 uv = gl_TexCoord[0].st + offset[i] * step * stepwidth;

        //目标颜色
        vec4 ctmp = texture2D(colorMap, uv);
        //颜色差值
        vec4 t = cval - ctmp;
        //颜色差值平方
        float dist2 = dot(t, t);
        //计算颜色差值权重值
        float c_w = min(exp(-(dist2) / c_phi), 1.0);

        //法线权值
        vec4 ntmp = texture2D(normalMap, uv);
        t = nval - ntmp;
        dist2 = max(dot(t, t) / (stepwidth * stepwidth), 0.0);
        float n_w = min(exp(-(dist2) / n_phi), 1.0);

        //位置权值
        vec4 ptmp = texture2D(posMap, uv);
        t = pval - ptmp;
        dist2 = dot(t, t);
        float p_w = min(exp(-(dist2) / p_phi), 1.0);

        //总权重值
        float weight = c_w * n_w * p_w;

        sum += ctmp * weight * kernel[i];
        cum_w += weight * kernel[i];
    }
    gl_FragData[0] = sum / cum_w;
}
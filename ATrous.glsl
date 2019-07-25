



uniform sampler2D colorMap, normalMap, posMap;
uniform float c_phi, n_phi, p_phi, stepwidth;
uniform float kernel[25];
uniform vec2 offset[25];

void main(void)
{
    vec4 sum = vec4(0.0);
    vec2 step = vec2(1. / 512., 1. / 512.); // resolution
    //��ɫ
    vec4 cval = texture2D(colorMap, gl_TexCoord[0].st);
    //����
    vec4 nval = texture2D(normalMap, gl_TexCoord[0].st);
    //λ��
    vec4 pval = texture2D(posMap, gl_TexCoord[0].st);
    float cum_w = 0.0;
    for (int i = 0; i < 25; i++)
    {
        //�����˲��������أ���ȡUV
        vec2 uv = gl_TexCoord[0].st + offset[i] * step * stepwidth;

        //Ŀ����ɫ
        vec4 ctmp = texture2D(colorMap, uv);
        //��ɫ��ֵ
        vec4 t = cval - ctmp;
        //��ɫ��ֵƽ��
        float dist2 = dot(t, t);
        //������ɫ��ֵȨ��ֵ
        float c_w = min(exp(-(dist2) / c_phi), 1.0);

        //����Ȩֵ
        vec4 ntmp = texture2D(normalMap, uv);
        t = nval - ntmp;
        dist2 = max(dot(t, t) / (stepwidth * stepwidth), 0.0);
        float n_w = min(exp(-(dist2) / n_phi), 1.0);

        //λ��Ȩֵ
        vec4 ptmp = texture2D(posMap, uv);
        t = pval - ptmp;
        dist2 = dot(t, t);
        float p_w = min(exp(-(dist2) / p_phi), 1.0);

        //��Ȩ��ֵ
        float weight = c_w * n_w * p_w;

        sum += ctmp * weight * kernel[i];
        cum_w += weight * kernel[i];
    }
    gl_FragData[0] = sum / cum_w;
}
vec3 rayTrace( vec2 uv )
{
    vec3 col = vec3( 0.0 );
    
    vec3 ro = vec3( 0.0, 0.0, -150.0 );
    vec3 rd = normalize( vec3( uv, 1.0 ) );
    
    vec4 d;
    
    for( int i = 0; i < 1500; i ++ )
    {
        p += rd * 

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = ( fragCoord * 2.0 - iResolution.xy ) / iResolution.y;

    col = rayTrace( uv );
    
    fragColor = vec4(col, 1.0);
}

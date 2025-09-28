Shader "Unlit/PlasmaShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale("Scale",float)=1
        _TimeScale("Time Scale",float)=1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Greater
            //Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Scale,_TimeScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float3 Plasma(float2 uv)
            {
                uv = uv * _Scale - _Scale / 2;
                float time = _Time.y * _TimeScale;
                float w1 = sin(uv.x + time);
                float w2 = sin(uv.y + time) * 0.5;
                float w3 = sin(uv.x + uv.y + time);

                float r = sin( sqrt(uv.x * uv.x + uv.y * uv.y) + time);

                float finalValue = w1 + w2 + w3 + r;

                float3 finalWave = float3(sin(finalValue * UNITY_PI),cos(finalValue * UNITY_PI), 0);
                return finalWave*0.5+0.5;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed3 plasma = Plasma(i.uv);
                fixed4 col = tex2D(_MainTex, i.uv);
               
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(col.rgb * plasma.rgb,1);
            }
            ENDCG
        }
    }
}

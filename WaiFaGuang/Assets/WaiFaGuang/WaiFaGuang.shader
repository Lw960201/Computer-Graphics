Shader "test/WaiFaGuang"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "back" {}
        _Color( "颜色", Color) = (0,0,0,0)
        _Size( "大小", float) = 0.01
        _QiangDu("强度",float) = 0.5
        _PowQiangDu("pow强度",float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" 
            "IgnoreProjector" = "True"
            "Queue" = "Transparent"
        }
        LOD 100
        //法线外扩
        pass{

            Cull Front
            ZWrite On
            //ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct a2v {
                fixed3 normal : NORMAL;
                fixed4 vertex : POSITION;
                fixed4 posWorld : TEXCOORD0;
            };

            struct v2f {
                fixed3 normal : TEXCOORD0;
                fixed3 viewDir : TEXCOORD1;
                fixed4 pos : SV_POSITION;
            };

            fixed4 _Color;
            float _Size;
            float _QiangDu;
            float _PowQiangDu;

            v2f vert(a2v i) {
                v2f o;
                i.vertex.xyz += i.normal*_Size;
                o.pos = UnityObjectToClipPos(i.vertex);
                //世界空间的n、v
                o.normal = UnityObjectToWorldNormal(i.normal);//i.normal;//
                i.posWorld.xyz = UnityObjectToWorldDir(i.vertex);//mul(unity_ObjectToWorld,i.vertex); //
                o.viewDir =  i.posWorld.xyz - _WorldSpaceCameraPos.xyz;//UnityObjectToViewPos(i.posWorld);//
                return o;
            }

            fixed4 frag(v2f v) : SV_TARGET{
                fixed4 result;
                fixed3 normalDir = normalize(v.normal);
                fixed3 viewDir = normalize(v.viewDir);

                result = _Color;
                result.a = pow(1 - saturate(dot(normalDir,viewDir)), _PowQiangDu);
                result.a *= _QiangDu;
                return result;
            }

            ENDCG
        }

        Pass
        {
            Cull Back
            //Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
}

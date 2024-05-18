Shader "Unlit/CyclingColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { 
			"RenderType" = "Opaque"
			"Queue" = "Geometry"

			"RenderPipeline" = "UniversalPipeline"
		}
        Pass
        {
            Tags
			{
				"LightMode" = "UniversalForward"
			}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 positionOS : Position;
            };

            struct v2f
            {
                float4 positionCS : SV_Position;
				float4 hueShiftColor : COLOR;
            };

			float3 hsv2rgb(float3 inHSV)
			{
				float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				float3 P = abs(frac(inHSV.xxx + K.xyz) * 6.0 - K.www);
				return inHSV.z * lerp(K.xxx, saturate(P - K.xxx), inHSV.y);
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

				float3 hsvColor = float3(0.0f, 1.0f, 1.0f);
				hsvColor.r = (sin(_Time.y) + 1.0f) * 0.5f;
				float3 rgbColor = hsv2rgb(hsvColor);

				o.hueShiftColor = float4(rgbColor, 1.0f);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				return i.hueShiftColor;
            }
            ENDHLSL
        }
    }
}
// This shader adds tessellation in URP
Shader "Example/URPUnlitShaderTessallated"
{
    // The properties block of the Unity shader. In this example this block is empty
    // because the output color is predefined in the fragment shader code.
    Properties
    {
        _Tess("Tessellation", Range(1, 32)) = 20
        _MaxTessDistance("Max Tess Distance", Range(1, 32)) = 20
        _Noise("Noise", 2D) = "gray" {}
        _SandTexture("Sand Texture", 2D) = "white" {} // Ajoutez cette ligne
        _Weight("Displacement Amount", Range(0, 1)) = 0
    }

    // The SubShader block containing the Shader code. 
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }

        Pass
        {
            Tags{ "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"    
            #include "CustomTessellation.hlsl"

            #pragma hull hull
            #pragma domain domain
            #pragma vertex TessellationVertexProgram
            #pragma fragment frag

            sampler2D _Noise;
            sampler2D _SandTexture; // Déclaration de la variable _SandTexture
            float _Weight;

            // pre tesselation vertex program
            ControlPoint TessellationVertexProgram(Attributes v)
            {
                ControlPoint p;

                p.vertex = v.vertex;
                p.uv = v.uv;
                p.normal = v.normal;
                p.color = v.color;

                return p;
            }

            // after tesselation
            Varyings vert(Attributes input)
            {
                Varyings output;

                float4 Noise = tex2Dlod(_Noise, float4(input.uv, 0, 0)); // Removed time dependency

                input.vertex.xyz += normalize(input.normal) * Noise.r * _Weight;
                output.vertex = TransformObjectToHClip(input.vertex.xyz);
                output.color = input.color;
                output.normal = input.normal;
                output.uv = input.uv;

                return output;
            }

            [UNITY_domain("tri")]
            Varyings domain(TessellationFactors factors, OutputPatch<ControlPoint, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
            {
                Attributes v;
                // interpolate the new positions of the tessellated mesh
                Interpolate(vertex)
                Interpolate(uv)
                Interpolate(color)
                Interpolate(normal)

                return vert(v);
            }

            // The fragment shader definition.            
           half4 frag(Varyings IN) : SV_Target
           {
               // Sample the sand texture
               half4 SandColor = tex2D(_SandTexture, IN.uv);

               return SandColor;
           }

            ENDHLSL
        }
    }
}

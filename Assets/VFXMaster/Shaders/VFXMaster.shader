Shader "Miura/VFXMaster"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)] _Culling("Culling Mode", int) = 0
        [KeywordEnum(Off, On)] _ZWrite("ZWrite", int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", int) = 4
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend", int) = 10
        
        _MainTex ("Texture", 2D) = "white" {}
        _MainScrollSpeedX("Main Scroll Speed X", Float) = 0
        _MainScrollSpeedY("Main Scroll Speed Y", Float) = 0
        _GradationMap("Gradation Map", 2D) = "white" {}
        _DitherLevel("Dither Level", Float) = 1.0
        _ScrollMask("Scroll Mask", 2D) = "white" {}
        [Toggle(REVERT_MASK)] _RevertMask("Revert Mask", Float) = 0
        [HDR] _MainColor("Color", Color) = (1, 1, 1, 1)
        [HDR] _MainAddColor("Add Color", Color) = (0, 0, 0, 1)
        
        [Space]
        
        [Toggle(USE_EMISSIVE1)] _UseEmissive1("Use Emissive1", Float) = 0
        _EmissiveTex1("Emissive Texture1", 2D) = "white" {}
        [HDR] _EmissiveColor1("Emissive Color1", Color) = (1, 1, 1, 1)
        [Toggle(USE_EMISSIVE2)] _UseEmissive2("Use Emissive2", Float) = 0
        _EmissiveTex2("Emissive Texture2", 2D) = "white" {}
        [HDR] _EmissiveColor2("Emissive Color2", Color) = (1, 1, 1, 1)
        
        [Space]
        
        [Toggle(USE_NOISE1)] _UseNoise1("Use Noise1", Float) = 0
        _NoiseTex1("Noise Texture1", 2D) = "white" {}
        [HDR] _NoiseColor1("Noise Color1", Color) = (1, 1, 1, 1)
        _NoisePower1("Noise Power1", Float) = 1.0
        [KeywordEnum(Multiply, Add)] _Noise1MixType("Noise1 Mix Type", int) = 0
        [Toggle(USE_NOISE2)] _UseNoise2("Use Noise2", Float) = 0
        _NoiseTex2("Noise Texture2", 2D) = "white" {}
        [HDR] _NoiseColor2("Noise Color2", Color) = (1, 1, 1, 1)
        _NoisePower2("Noise Power2", Float) = 1.0
        [KeywordEnum(Multiply, Add)] _Noise2MixType("Noise2 Mix Type", int) = 0
        
        [Space]
        
        _MaskTex("Mask Texture", 2D) = "white"{}
        _MaskThreshold("Mask Threshold", Range(0, 1.5)) = 1.0
        _SmoothRange("Smooth Range", Float) = 0.1
        
        [Space]
        
        [HDR] _EdgeGrowColor("Edge Grow Color", Color) = (1, 1, 1, 1)
        _EdgeGrowThreshold("Edge Grow Threshold", Float) = 0.2
        
        [Space]
        
        [Toggle(USE_RIM)] _UseRim("Use Rim", Float) = 0
        [HDR] _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimPower("Rim Power", Float) = 1.0
        _RimThreshold("Rim Threshold", Float) = 1.0
        _RimMask("Rim Mask", 2D) = "white" {}
        [Toggle(USE_RIMALPHA)] _UseRimAlpha("Use Rim Alpha Clipping", Float) = 0
        _RimScrollX("Rim Mask Scroll Speed X", Float) = 0.0
        _RimScrollY("Rim Mask Scroll Speed Y", Float) = 0.0
        
        [Space]
        
        [Toggle(USE_EDGESMOOTH)] _UseEdgeSmooth("Use EdgeSmooth", Float) = 0
        _EdgeSmoothPower("EdgeSmooth Power", Float) = 1.0
        _EdgeSmoothThreshold("EdgeSmooth Threshold", Float) = 1.0
        
        [Space]
        
        [Toggle(USE_POLARCOORDINATE)] _UsePolarCoordinate("Use PolarCoordinate", Float) = 0
        
        [Space]
        
        [Toggle(TOON)] _Toon("Toon", Float) = 0
        _ToonPower("Toon Power", Float) = 0.0
        _ToonThreshold("Toon Threshold", Range(0, 1)) = 0.25
        
        [Space]
        
        [Toggle(USE_DISTORTION)] _UseDistortion("Use Distortion", Float) = 0
        [Normal] _DistortionMap("Distortion Normal Map", 2D) = "bamp" {}
        _DistortionStrength("Distortion Strength", Range(-1, 1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        
        ZWrite [_ZWrite]
        Cull [_Culling]
        ZTest [_ZTest]
        Blend [_SrcBlend] [_DstBlend]

        Pass
        {
            Name "Forward"
            
            Tags { "LightMode"="UniversalForward" }
            
            HLSLPROGRAM
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag

            #define PI = 3.1415926535
            
            // 機能切り替え用のシェーダー変数定義
            #pragma shader_feature USE_RIM
            #pragma shader_feature USE_RIMALPHA
            #pragma shader_feature USE_EDGESMOOTH
            #pragma shader_feature USE_POLARCOORDINATE
            #pragma shader_feature REVERT_MASK
            #pragma shader_feature TOON
            #pragma shader_feature USE_DISTORTION
            #pragma shader_feature USE_EMISSIVE1
            #pragma shader_feature USE_EMISSIVE2
            #pragma shader_feature USE_NOISE1
            #pragma shader_feature USE_NOISE2
            #pragma shader_feature _NOISE1MIXTYPE_MULTIPLY _NOISE1MIXTYPE_ADD
            #pragma shader_feature _NOISE2MIXTYPE_MULTIPLY _NOISE2MIXTYPE_ADD
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float4 screenPos : TEXCOORD3;
                float4 color : TEXCOORD4;
            };
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);
            
            TEXTURE2D(_ScrollMask);
            SAMPLER(sampler_ScrollMask);

            TEXTURE2D(_RimMask);
            SAMPLER(sampler_RimMask);

            TEXTURE2D(_DistortionMap);
            SAMPLER(sampler_DistortionMap);

            TEXTURE2D(_GradationMap);
            SAMPLER(sampler_GradationMap);

            TEXTURE2D(_EmissiveTex1);
            SAMPLER(sampler_EmissiveTex1);

            TEXTURE2D(_EmissiveTex2);
            SAMPLER(sampler_EmissiveTex2);

            TEXTURE2D(_NoiseTex1);
            SAMPLER(sampler_NoiseTex1);

            TEXTURE2D(_NoiseTex2);
            SAMPLER(sampler_NoiseTex2);

            TEXTURE2D(_CameraOpaqueTexture);
            SAMPLER(sampler_CameraOpaqueTexture);
            
            float4 _GradiationMap_TexlexSize;
            
            half4 _MainColor;
            half4 _MainAddColor;
            half4 _EdgeGrowColor;
            half4 _RimColor;
            half4 _EmissiveColor1;
            half4 _EmissiveColor2;
            half4 _NoiseColor1;
            half4 _NoiseColor2;

            float _MainScrollSpeedX;
            float _MainScrollSpeedY;
            float _DitherLevel;
            
            float _MaskThreshold;
            float _EdgeGrowThreshold;
            float _SmoothRange;

            float _RimPower;
            float _RimThreshold;
            float _RimScrollX;
            float _RimScrollY;
            
            float _EdgeSmoothPower;
            float _EdgeSmoothThreshold;

            float _ToonPower;
            float _ToonThreshold;

            float _DistortionStrength;
            
            float _NoisePower1;
            float _NoisePower2;

            float _Noise1MixType;
            float _Noise2MixType;
            
            v2f vert (appdata v)
            {
                 v2f o;
                
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.normal = TransformObjectToWorldNormal(v.normal);
                o.uv = v.uv;

                // ワールド座標
                o.worldPos = TransformObjectToWorld(v.vertex);

                // スクリーン座標
                o.screenPos = ComputeScreenPos(o.vertex);

                o.color = v.color;
                
                return o;
            }
            float Mask(float2 uv)
            {
                float mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv).r;
                float l = lerp(0, 1, _MaskThreshold - _SmoothRange);
                
                float finalAlpha = saturate(smoothstep(l, _MaskThreshold, mask));
                
                return finalAlpha;
            }
            float EdgeSmooth(float3 normal, float3 position)
            {
                float3 view = normalize(_WorldSpaceCameraPos - position);
                
                float d = saturate(dot(normal, view));
                d = pow(d, _EdgeSmoothPower);
                d = smoothstep(0.5, _EdgeSmoothThreshold, d);

                return d;
            }
            half4 Rim(float3 normal, float3 position, float3 screen, float2 puv)
            {
                float3 view = normalize(_WorldSpaceCameraPos - position);
                
                float d = saturate(dot(normal, view));
                d = pow(d, _RimPower);
                d = smoothstep(0.5, _RimThreshold, d);

                float2 uv = puv;
                float2 speed = float2(_RimScrollX, _RimScrollY) * _Time.y;
                uv += speed;
                
                float mask = SAMPLE_TEXTURE2D(_RimMask, sampler_RimMask, uv).r;
                
                half3 color = _RimColor * (d * mask);
                float a = d * mask;

                return half4(color, a);
            }
            
            float2 PolarCoordinate(float2 uv)
            {
                const float p2 = 1 / (PI * 2);

                float2 polar = 2 * uv - 1;
                float r = 1 - sqrt(polar.x * polar.x + polar.y * polar.y);
                float theta = atan2(polar.y, polar.x) * p2;

                float2 res;
                float2 speed = float2(_MainScrollSpeedX, _MainScrollSpeedY) * _Time.y;
                
                res.y = r + speed.x;
                res.x = theta + speed.y;
                
                return res;
            }
            half3 Toon(half3 diffuse)
            {
                half3 col = diffuse;
                col = step(_ToonThreshold, col);

                return col;
            }
            half3 Noise1(float2 uv)
            {
                float noise = SAMPLE_TEXTURE2D(_NoiseTex1, sampler_NoiseTex1, uv).r;
                noise = pow(noise, _NoisePower1);
                half3 noiseCol = _NoiseColor1.rgb * noise;

                return noiseCol;
            }
            half3 Noise2(float2 uv)
            {
                float noise = SAMPLE_TEXTURE2D(_NoiseTex2, sampler_NoiseTex2, uv).r;
                noise = pow(noise, _NoisePower2);
                half3 noiseCol = _NoiseColor2.rgb * noise;

                return noiseCol;
            }
            half4 Distortion(float2 uv, float4 screen)
            {
                float2 screenPos = screen.xy / screen.w;
                half4 tex = SAMPLE_TEXTURE2D(_DistortionMap, sampler_DistortionMap, uv);
                half3 normal = UnpackNormal(tex);
                
                float2 distortion = normal.xy * (_DistortionStrength * 0.1);
                float2 screenUV = screenPos + distortion;
                
                half4 screenColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenUV);
                
                return screenColor;
            }
            half4 frag (v2f i) : SV_Target
            {
                float2 subUV = i.uv;
                #ifdef USE_POLARCOORDINATE
                subUV = PolarCoordinate(i.uv);
                #else
                // UVスクロール
                float2 speed = float2(_MainScrollSpeedX, _MainScrollSpeedY) * _Time.y;
                subUV.x += fmod(speed.x, 1.0);
                subUV.y += fmod(speed.y, 1.0);
                #endif
                
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, subUV) * _MainColor;

                col.rgb = saturate(col.rgb + _MainAddColor.rgb);
                
                col.a = Mask(subUV);
                col.a *= i.color.a;

                #ifdef USE_EDGESMOOTH
                col.a *= EdgeSmooth(i.normal, i.worldPos);
                #endif
                
                #ifdef USE_RIM
                half4 rim = Rim(i.normal, i.worldPos, i.screenPos, i.uv);
                col.rgb += rim.rgb;
                    #ifdef USE_RIMALPHA
                        col.a *= rim.a;    
                    #endif
                #endif

                float scrollA = SAMPLE_TEXTURE2D(_ScrollMask, sampler_ScrollMask, i.uv).r;

                #ifdef REVERT_MASK
                col.a *= 1 - scrollA;
                #else
                col.a *= scrollA;
                #endif

                #ifdef USE_EMISSIVE1
                half3 em1 = SAMPLE_TEXTURE2D(_EmissiveTex1, sampler_EmissiveTex1, subUV).rgb * _EmissiveColor1.rgb;
                col.rgb = saturate(col.rgb + em1);
                #endif
                #ifdef USE_EMISSIVE2
                half3 em2 = SAMPLE_TEXTURE2D(_EmissiveTex2, sampler_EmissiveTex2, subUV).rgb * _EmissiveColor2.rgb;
                col.rgb = saturate(col.rgb + em2);
                #endif

                #ifdef USE_NOISE1
                    #ifdef _NOISE1MIXTYPE_ADD
                    col.rgb += Noise1(subUV);
                    #else
                    col.rgb *= Noise1(subUV);
                    #endif
                #endif
                #ifdef USE_NOISE2
                    #ifdef _NOISE2MIXTYPE_ADD
                    col.rgb += Noise2(subUV);
                    #else
                    col.rgb *= Noise2(subUV);
                    #endif
                #endif
                
                #ifdef USE_DISTORTION
                col.rgb = Distortion(subUV, i.screenPos).rgb;
                #endif

                #ifdef TOON
                col.rgb = Toon(col.rgb);
                #endif

                // ディザリング
                // 見栄えがあまり良くなかったため、一時的に無効化
                /*float2 view = i.screenPos.xy / i.screenPos.w;
                float2 screenPix = view.xy / i.screenPos.xy;

                int uvX = (int)fmod(screenPix.x, 4.0f);
                int uvY = (int)fmod(screenPix.y, 4.0f);
                float dither = PATTERN[uvX + uvY * 4];
                
                // ---------------------------------------
                */
                return col;
            }
            ENDHLSL
        }
    }
    CustomEditor "VFXMasterCustomShaderGUI"
}

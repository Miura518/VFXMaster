Shader "Miura/VFXMaster"
{
    Properties
    {
        [Enum(Back, 0, Front, 1, Off, 2)] _Culling("Culling Mode", int) = 2
        [Enum(On, 0, Off, 1)] _ZWrite("ZWrite", int) = 1
        [Enum(Less, 0, LEqual, 1, Equal, 2, GEqual, 3, Greater, 4, NotEqual, 5, Always, 6)] _ZTest("ZTest", int) = 0
        _MainTex ("Texture", 2D) = "white" {}
        _MainScrollSpeedX("Main Scroll Speed X", Float) = 0
        _MainScrollSpeedY("Main Scroll Speed Y", Float) = 0
        _GradationMap("Gradation Map", 2D) = "white" {}
        _DitherLevel("Dither Level", Float) = 1.0
        _ScrollMask("Scroll Mask", 2D) = "white" {}
        [Toggle(REVERT_MASK)] _RevertMask("Revert Mask", Float) = 0
        [HDR] _MainColor("Color", Color) = (1, 1, 1, 1)
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
        _ToonThreshold("Toon Threshold", Float) = 0.0
        [Space]
        [Toggle(USE_DISTORTION)] _UseDistortion("Use Distortion", Float) = 0
        [Normal] _DistortionMap("Distortion Normal Map", 2D) = "bamp" {}
        _DistortionStrength("Distortion Strength", Range(-1, 1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        
        ZWrite [_ZWrite]
        Cull [_Culling]
        ZTest [_ZTest]
        
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define PI = 3.1415926535
            
            // 機能切り替え用のマクロ定義
            #pragma shader_feature USE_RIM
            #pragma shader_feature USE_RIMALPHA
            #pragma shader_feature USE_EDGESMOOTH
            #pragma shader_feature USE_POLARCOORDINATE
            #pragma shader_feature REVERT_MASK
            #pragma shader_feature TOON
            #pragma shader_feature USE_DISTORTION
            
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

            static const int PATTERN[16] =
            {
                0 , 8 , 2 , 10,
                12, 4 , 14, 6 ,
                3 , 11, 1 , 9 ,
                15, 7 , 13, 5
            };
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);
            
            TEXTURE2D(_ScrollMask);
            SAMPLER(sampler_ScrollMask);

            TEXTURE2D(_CameraOpaqueTexture);
            SAMPLER(sampler_CameraOpaqueTexture);

            TEXTURE2D(_RimMask);
            SAMPLER(sampler_RimMask);

            TEXTURE2D(_DistortionMap);
            SAMPLER(sampler_DistortionMap);

            TEXTURE2D(_GradationMap);
            SAMPLER(sampler_GradationMap);
            float4 _GradiationMap_TexlexSize;
            
            half4 _MainColor;
            half4 _EdgeGrowColor;
            half4 _RimColor;

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
            // TODO:試行錯誤必須
            half3 Toon(half3 diffuse)
            {
                half3 col = diffuse;
                half luminance = dot(col, half3(0.299, 0.587, 0.114));

                half steps = 3.0;

                luminance = floor(luminance * steps) / (steps - 1.0);

                col = normalize(col) * luminance;

                return col;
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
                
                #ifdef USE_DISTORTION
                col *= Distortion(subUV, i.screenPos);
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
                
                clip(dither - (1 - col.a));*/
                // ---------------------------------------
                
                return col;
            }
            ENDHLSL
        }
    }
}

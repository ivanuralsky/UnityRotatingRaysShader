Shader "Custom/RotatingRays"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorStart ("Start Color", Color) = (1, 1, 1, 1)
        _ColorEnd ("End Color", Color) = (1, 1, 0, 1)
        _RayLength ("Ray Length", Range(0, 1)) = 0.5
        _BlendMode ("Blend Mode", Range(0, 1)) = 0.5
        _RotationSpeed ("Rotation Speed", Range(0, 10)) = 1
        _GlowIntensity ("Glow Intensity", Range(0, 10)) = 1
        _Distortion ("Distortion Effect", Range(0, 10)) = 1
        _RayCount ("Ray Count", Int) = 10
        _RayTaper ("Ray Taper", Range(0, 1)) = 0.5
        _RayWidthStart ("Ray Width Start", Range(0, 1)) = 0.5
        _RayWidthEnd ("Ray Width End", Range(0, 1)) = 0.5
        _TimeOffset ("Time Offset", Float) = 0.0
        _EdgeSmoothness ("Edge Smoothness", Range(0, 1)) = 0.1
        _StartRadius ("Start Radius", Range(0, 1)) = 0.0
        //_MovementType ("Movement Type", Int) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
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
            float4 _ColorStart;
            float4 _ColorEnd;
            float _RayLength;
            float _BlendMode;
            float _RotationSpeed;
            float _GlowIntensity;
            float _Distortion;
            int _RayCount;
            float _RayTaper;
            float _RayWidthStart;
            float _RayWidthEnd;
            float _TimeOffset;
            float _EdgeSmoothness;
            float _StartRadius;
            int _MovementType;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv - 0.5;

                // Calculate the angle and radius
                float angle = atan2(uv.y, uv.x);
                float radius = length(uv);

                // Apply movement type
                if (_MovementType == 0)
                {
                    // Rotation clockwise
                    angle += _TimeOffset * _RotationSpeed;
                }
                else if (_MovementType == 1)
                {
                    // Rotation counterclockwise
                    angle -= _TimeOffset * _RotationSpeed;
                }
                else if (_MovementType == 2)
                {
                    // Pendulum motion
                    angle += sin(_TimeOffset * _RotationSpeed) * 0.5;
                }
                else if (_MovementType == 3)
                {
                    // Accelerating and decelerating motion
                    float accelDecelSpeed = _RotationSpeed * abs(sin(_TimeOffset));
                    angle += _TimeOffset * accelDecelSpeed;
                }
                else if (_MovementType == 4)
                {
                    // Pulsation
                    float pulse = abs(sin(_TimeOffset * _RotationSpeed));
                    angle += pulse * 0.5;
                }

                // Calculate the ray pattern
                float rayIndex = (angle / (2.0 * UNITY_PI)) * _RayCount;
                float rayPattern = abs(frac(rayIndex) - 0.5) * 2.0;

                // Adjust the width based on the start and end parameters
                float rayWidth = lerp(_RayWidthStart, _RayWidthEnd, (radius - _StartRadius) / (1.0 - _StartRadius));

                // Taper the rays
                rayPattern *= 1.0 - radius * _RayTaper;

                // Adjust the width
                rayPattern *= rayWidth;

                // Smooth the ray edges
                float smoothRay = smoothstep(_RayLength - _EdgeSmoothness, _RayLength + _EdgeSmoothness, rayPattern);

                // Apply gradient color and intensity
                float4 color = lerp(_ColorStart, _ColorEnd, (radius - _StartRadius) / (1.0 - _StartRadius));
                color.rgb *= smoothRay * _GlowIntensity;

                // Blend mode
                color.a *= _BlendMode;

                // Apply increased distortion
                if (_Distortion > 0)
                {
                    float distortion = sin(radius * 10.0 + _TimeOffset * 5.0) * 0.5 * _Distortion;
                    uv.x += distortion;
                    uv.y += distortion;
                }

                float4 tex = tex2D(_MainTex, uv + 0.5);

                // Apply transparency between rays
                tex.a *= smoothRay;

                return tex * color;
            }
            ENDCG
        }
    }
    FallBack "Transparent"
}

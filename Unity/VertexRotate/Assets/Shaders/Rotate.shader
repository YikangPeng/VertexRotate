Shader "Unlit/Rotate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Povit("Povit in ObjectSpace", Vector) = (0,0,0,0)//旋转轴射线上一点，在物体坐标系下
        _Axis("Axis in ObjectSpace", Vector) = (0,0,1,0)//旋转轴向，物体坐标系
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
                float4 color : COLOR;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldnormal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Axis;
            float4 _Povit;
            float _Angle;

            float4 _CharacterPosition;

            v2f vert (appdata v)
            {
                v2f o;      

                //以射线起点为原点的物体顶点向量
                float3 Dir = v.vertex.xyz - _Povit.xyz;
                float3 n = _Axis.xyz;

                float zbias = v.color.z * 100 - _CharacterPosition.z;
                zbias = max(zbias - 1 , 0);
                zbias = min(zbias, 18.84);
                _Angle = zbias;

                //根据角度和轴向构造旋转矩阵
                float3x3 RotationMatrix;
                RotationMatrix[0][0] = n.x * n.x * (1 - cos(_Angle)) + cos(_Angle);
                RotationMatrix[0][1] = n.x * n.y * (1 - cos(_Angle)) + n.z * sin(_Angle);
                RotationMatrix[0][2] = n.x * n.z * (1 - cos(_Angle)) - n.y * sin(_Angle);
                
                RotationMatrix[1][0] = n.x * n.y * (1 - cos(_Angle)) - n.z * sin(_Angle);
                RotationMatrix[1][1] = n.y * n.y * (1 - cos(_Angle)) + cos(_Angle);
                RotationMatrix[1][2] = n.y * n.z * (1 - cos(_Angle)) + n.x * sin(_Angle);
                
                RotationMatrix[2][0] = n.x * n.z * (1 - cos(_Angle)) + n.y * sin(_Angle);
                RotationMatrix[2][1] = n.y * n.z * (1 - cos(_Angle)) - n.x * sin(_Angle);
                RotationMatrix[2][2] = n.z * n.z * (1 - cos(_Angle)) + cos(_Angle);
                
                //旋转向量然后计算计算点坐标
                v.vertex.xyz = mul(RotationMatrix, Dir) + _Povit.xyz;

                o.worldnormal = mul((float3x3)unity_ObjectToWorld, v.normal);
                o.worldnormal = mul(RotationMatrix, o.worldnormal);
                
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                half3 lightDir = _WorldSpaceLightPos0.xyz;
                col.xyz = col.xyz * dot(lightDir, i.worldnormal);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return col;
            }
            ENDCG
        }
    }
}

Shader "Custom/CylindricalCoordinate"
{
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        [MaterialToggle] _canR2C ("Enable Rectangular To Cylindrical", Float) = 1 // 0 is false, 1 is true
        [MaterialToggle] _canC2R ("Enable Cylindrical To Rectangular", Float) = 1 // 0 is false, 1 is true
    }
    SubShader {
        Tags {
            "Queue"="Geometry"
        }
        Pass {
            CGPROGRAM
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                half2 uv   : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                half2 uv   : TEXCOORD0;
            };

            // convert rectangular to cylindrical
            float4 r2c (float4 rec){
                float4 cyl;

                // calculate r of cylindrical coordinate system
                cyl.x = sqrt(rec.x * rec.x + rec.z * rec.z);

                // calculate θ of cylindrical coordinate system
                if(rec.x==0.0 && rec.z==0.0){
                    // θ is 0 because θ is not fixed at a singular point
                    cyl.z = 0.0;
                }else{
                    cyl.z = atan2(rec.z, rec.x);        
                }

                // as it is
                cyl.y = rec.y;      
                cyl.w = rec.w;

                return cyl;
            }

            // convert cylindrical to rectangular
            float4 c2r (float4 cyl){
                float4 rec;

                rec.x = cyl.x * cos(cyl.z);
                rec.y = cyl.y;
                rec.z = cyl.x * sin(cyl.z);
                rec.w = cyl.w;

                return rec;
            }

            uniform sampler2D _MainTex;
            float _canR2C;
            float _canC2R;

            #pragma vertex vert
            #pragma fragment frag

            // vertex shader
            v2f vert (appdata v) {
                v2f o;

                // convert rectangular to cylindrical
                if(_canR2C){
                    v.vertex = r2c(v.vertex);
                }

                // convert cylindrical to rectangular
                if(_canC2R){
                    v.vertex = c2r(v.vertex);
                }

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // fragment shader
            fixed4 frag (v2f i): SV_Target {
                return tex2D(_MainTex, i.uv);
            }

            ENDCG
        }
    }
}
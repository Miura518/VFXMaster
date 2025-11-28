using UnityEditor;
using UnityEngine;

public class VFXMasterCustomShaderGUI : ShaderGUI
{
    bool _showMain = true;
    bool _showEmissive = false;
    bool _showNoise = false;
    bool _showMask = false;
    bool _showRim = false;
    bool _showDistortion = false;
    
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        MaterialProperty _MainTex = FindProperty("_MainTex", props);
        MaterialProperty _MainColor = FindProperty("_MainColor", props);
        MaterialProperty _MainAddColor = FindProperty("_MainAddColor", props);
        MaterialProperty _Culling = FindProperty("_Culling", props);
        MaterialProperty _ZWrite = FindProperty("_ZWrite", props);
        MaterialProperty _ZTest = FindProperty("_ZTest", props);
        MaterialProperty _UsePolarCoordinate = FindProperty("_UsePolarCoordinate", props);
        
        MaterialProperty _MainScrollSpeedX = FindProperty("_MainScrollSpeedX", props);
        MaterialProperty _MainScrollSpeedY = FindProperty("_MainScrollSpeedY", props);
        
        MaterialProperty _UseEmissive1 = FindProperty("_UseEmissive1", props);
        MaterialProperty _EmissiveTex1 = FindProperty("_EmissiveTex1", props);
        MaterialProperty _EmissiveColor1 = FindProperty("_EmissiveColor1", props);
        MaterialProperty _UseEmissive2 = FindProperty("_UseEmissive2", props);
        MaterialProperty _EmissiveTex2 = FindProperty("_EmissiveTex2", props);
        MaterialProperty _EmissiveColor2 = FindProperty("_EmissiveColor2", props);
        
        MaterialProperty _UseNoise1 = FindProperty("_UseNoise1", props);
        MaterialProperty _NoiseTex1 = FindProperty("_NoiseTex1", props);
        MaterialProperty _NoiseColor1 = FindProperty("_NoiseColor1", props);
        MaterialProperty _NoisePower1 = FindProperty("_NoisePower1", props);
        MaterialProperty _Noise1MixType = FindProperty("_Noise1MixType", props);
        
        MaterialProperty _UseNoise2 = FindProperty("_UseNoise2", props);
        MaterialProperty _NoiseTex2 = FindProperty("_NoiseTex2", props);
        MaterialProperty _NoiseColor2 = FindProperty("_NoiseColor2", props);
        MaterialProperty _NoisePower2 = FindProperty("_NoisePower2", props);
        MaterialProperty _Noise2MixType = FindProperty("_Noise2MixType", props);
        
        MaterialProperty _ScrollMask = FindProperty("_ScrollMask", props);
        MaterialProperty _RevertMask = FindProperty("_RevertMask", props);
        MaterialProperty _MaskTex = FindProperty("_MaskTex", props);
        MaterialProperty _MaskThreshold = FindProperty("_MaskThreshold", props);
        MaterialProperty _SmoothRange = FindProperty("_SmoothRange", props);
        MaterialProperty _UseEdgeSmooth = FindProperty("_UseEdgeSmooth", props);
        MaterialProperty _EdgeSmoothPower = FindProperty("_EdgeSmoothPower", props);
        MaterialProperty _EdgeSmoothThreshold = FindProperty("_EdgeSmoothThreshold", props);
        
        MaterialProperty _UseRim = FindProperty("_UseRim", props);
        MaterialProperty _RimColor = FindProperty("_RimColor", props);
        MaterialProperty _RimPower = FindProperty("_RimPower", props);
        MaterialProperty _RimThreshold = FindProperty("_RimThreshold", props);
        MaterialProperty _RimMask = FindProperty("_RimMask", props);
        MaterialProperty _UseRimAlpha = FindProperty("_UseRimAlpha", props);
        MaterialProperty _RimScrollX = FindProperty("_RimScrollX", props);
        MaterialProperty _RimScrollY = FindProperty("_RimScrollY", props);
        
        MaterialProperty _UseDistortion = FindProperty("_UseDistortion", props);
        MaterialProperty _DistortionMap = FindProperty("_DistortionMap", props);
        MaterialProperty _DistortionStrength = FindProperty("_DistortionStrength", props);
        
        GUIStyle boxStyle = new GUIStyle(EditorStyles.helpBox)
        {
            padding = new RectOffset(10, 10, 5, 5),
            margin = new RectOffset(5, 5, 5, 5),
        };
        GUIStyle foldoutStyle = new GUIStyle(EditorStyles.foldout)
        {
            fontSize = 13,
            fontStyle = FontStyle.Bold,
            richText = true,
        };
        
        #region Main
        // Main Settings
        _showMain = EditorGUILayout.Foldout(_showMain, "Main", true, foldoutStyle);
        if (_showMain)
        {
            EditorGUILayout.BeginVertical(boxStyle);
            EditorGUILayout.Space();
            EditorGUI.indentLevel++;
            
            materialEditor.TexturePropertySingleLine(new GUIContent("Main Texture"), _MainTex, _MainColor);
            materialEditor.ShaderProperty( _MainAddColor, new GUIContent("Add Color" ) );
            EditorGUILayout.Space();
            materialEditor.ShaderProperty( _Culling, new GUIContent("Culling Mode" ) );
            materialEditor.ShaderProperty( _ZWrite, new GUIContent("ZWrite Mode" ) );
            materialEditor.ShaderProperty( _ZTest, new GUIContent("ZTest Mode" ) );
            EditorGUILayout.Space();
            materialEditor.ShaderProperty( _MainScrollSpeedX, new GUIContent("Scroll X Speed" ) );
            materialEditor.ShaderProperty( _MainScrollSpeedY, new GUIContent("Scroll Y Speed" ) );
            EditorGUILayout.Space();
            materialEditor.ShaderProperty( _UsePolarCoordinate, new GUIContent("Polar Coordinate" ) );
            
            EditorGUI.indentLevel--;
            EditorGUILayout.EndVertical();
        }
        EditorGUILayout.Space();
        #endregion
        
        #region Emissive
        // Emissive Settings
        _showEmissive = EditorGUILayout.Foldout(_showEmissive, "Emissive", true, foldoutStyle);
        if (_showEmissive)
        {
            EditorGUILayout.BeginVertical(boxStyle);
            EditorGUILayout.Space();
            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty( _UseEmissive1, new GUIContent("Use Emissive1" ) );
            if (_UseEmissive1.floatValue != 0.0f)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("Texture"), _EmissiveTex1, _EmissiveColor1);
            }
            EditorGUILayout.Space();
            materialEditor.ShaderProperty( _UseEmissive2, new GUIContent("Use Emissive2" ) );
            if (_UseEmissive2.floatValue != 0.0f)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("Texture"), _EmissiveTex2, _EmissiveColor2);
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.EndVertical();
        }
        EditorGUILayout.Space();
        #endregion
        
        #region Noise
        // Noise Settings
        _showNoise = EditorGUILayout.Foldout(_showNoise, "Noise", true, foldoutStyle);
        if (_showNoise)
        {
            EditorGUILayout.BeginVertical(boxStyle);
            EditorGUILayout.Space();
            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty( _UseNoise1, new GUIContent("Use Noise" ) );
            if (_UseNoise1.floatValue != 0.0f)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("Texture"), _NoiseTex1, _NoiseColor1);
                materialEditor.ShaderProperty( _NoisePower1, new GUIContent("Power" ) );
                materialEditor.ShaderProperty( _Noise1MixType, new GUIContent("Overlay Type" ) );
            }
            EditorGUILayout.Space();
            materialEditor.ShaderProperty( _UseNoise2, new GUIContent("Use Noise2" ) );
            if (_UseNoise2.floatValue != 0.0f)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("Texture"), _NoiseTex2, _NoiseColor2);
                materialEditor.ShaderProperty( _NoisePower2, new GUIContent("Power" ) );
                materialEditor.ShaderProperty( _Noise2MixType, new GUIContent("Overlay Type" ) );
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.EndVertical();
        }
        EditorGUILayout.Space();
        #endregion
        
        #region Mask
        // Mask Settings
        _showMask = EditorGUILayout.Foldout(_showMask, "Mask", true, foldoutStyle);
        if (_showMask)
        {
            EditorGUILayout.BeginVertical(boxStyle);
            EditorGUILayout.Space();
            EditorGUI.indentLevel++;
            
            materialEditor.TexturePropertySingleLine(new GUIContent("Mask Texture"), _MaskTex);
            materialEditor.ShaderProperty( _MaskThreshold, new GUIContent("Threshold" ) );
            materialEditor.ShaderProperty( _SmoothRange, new GUIContent("Smooth Range" ) );
            EditorGUILayout.Space();
            materialEditor.TexturePropertySingleLine(new GUIContent("Scroll Mask Texture"), _ScrollMask);
            materialEditor.ShaderProperty( _RevertMask, new GUIContent("Revert" ) );
            EditorGUILayout.Space();
            materialEditor.ShaderProperty( _UseEdgeSmooth, new GUIContent("Use Edge Mask" ) );
            if (_UseEdgeSmooth.floatValue != 0.0f)
            {
                materialEditor.ShaderProperty( _EdgeSmoothPower, new GUIContent("Power" ) );
                materialEditor.ShaderProperty( _EdgeSmoothThreshold, new GUIContent("Threshold" ) );
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.EndVertical();
        }
        EditorGUILayout.Space();
        #endregion
        
        #region Rim
        // Rim Settings
        _showRim = EditorGUILayout.Foldout(_showRim, "Rim", true, foldoutStyle);
        if (_showRim)
        {
            EditorGUILayout.BeginVertical(boxStyle);
            EditorGUILayout.Space();
            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty( _UseRim, new GUIContent("Use Rim" ) );
            if (_UseNoise1.floatValue != 0.0f)
            {
                materialEditor.ShaderProperty( _RimColor, new GUIContent("Color" ) );
                materialEditor.ShaderProperty( _RimPower, new GUIContent("Power" ) );
                materialEditor.ShaderProperty( _RimThreshold, new GUIContent("Threshold" ) );
                EditorGUILayout.Space();
                materialEditor.TexturePropertySingleLine(new GUIContent("Mask Texture"), _RimMask);
                materialEditor.ShaderProperty( _UseRimAlpha, new GUIContent("Use Alpha" ) );
                EditorGUILayout.Space();
                materialEditor.ShaderProperty( _RimScrollX, new GUIContent("Scroll X Speed" ) );
                materialEditor.ShaderProperty( _RimScrollY, new GUIContent("Scroll Y Speed" ) );
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.EndVertical();
        }
        EditorGUILayout.Space();
        #endregion
        
        #region Distortion
        // Distortion Settings
        _showDistortion = EditorGUILayout.Foldout(_showDistortion, "Distortion", true, foldoutStyle);
        if (_showDistortion)
        {
            EditorGUILayout.BeginVertical(boxStyle);
            EditorGUILayout.Space();
            EditorGUI.indentLevel++;
            
            materialEditor.ShaderProperty( _UseDistortion, new GUIContent("Use Distortion" ) );
            if (_UseDistortion.floatValue != 0.0f)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("Distortion Map"), _DistortionMap);
                materialEditor.ShaderProperty( _DistortionStrength, new GUIContent("Strength" ) );
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.EndVertical();
        }
        EditorGUILayout.Space();
        #endregion
        
        // End
        materialEditor.EnableInstancingField();
    }
}

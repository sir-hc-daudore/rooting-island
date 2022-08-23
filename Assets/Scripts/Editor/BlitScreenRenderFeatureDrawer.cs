using UnityEditor;

namespace UnityEngine.Rendering.Universal
{
    [CustomPropertyDrawer(typeof (BlitScreenRenderSettings))]
    public class BlitScreenRenderSettingsDrawer : PropertyDrawer
    {
        static class Styles
        {
            public static readonly GUIContent materialLabel = EditorGUIUtility.TrTextContent("Material");
        }

        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            var renderPassEventProperty = property.FindPropertyRelative("renderPassEvent");
            var blitMaterialProperty = property.FindPropertyRelative("blitMaterial");
            var blitMaterialPassIndexProperty = property.FindPropertyRelative("blitMaterialPassIndex");

            EditorGUI.BeginProperty(position, label, property);
            EditorGUILayout.PropertyField(renderPassEventProperty);

            EditorGUI.BeginChangeCheck();
            Material material = 
                EditorGUILayout.ObjectField(
                    Styles.materialLabel,
                    blitMaterialProperty.objectReferenceValue,
                    typeof(Material),
                    allowSceneObjects: false) 
                as Material;
            if (EditorGUI.EndChangeCheck())
                blitMaterialProperty.objectReferenceValue = material;

            DisplayPassPopup(material, blitMaterialPassIndexProperty);

            EditorGUI.EndProperty();
        }

        void DisplayPassPopup(Material material, SerializedProperty materialPassProperty)
        {
            if (material != null)
            {
                int passCount = material.passCount;
                if (passCount == 0)
                    return;

                string[] labels = new string[passCount];
                int[] options = new int[passCount];
                for (int i = 0; i < passCount; ++i)
                {
                    string passName = material.GetPassName(i);
                    if (passName.Length == 0)
                        passName = "Unnamed Pass";

                    labels[i] = string.Format("{0}: {1}", i, passName);
                    options[i] = i;
                }

                EditorGUI.BeginChangeCheck();
                int option = EditorGUILayout.IntPopup("Material Pass", materialPassProperty.intValue, labels, options);
                if (EditorGUI.EndChangeCheck())
                    materialPassProperty.intValue = option;
            }
        }
    }
}

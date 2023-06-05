using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SendData : MonoBehaviour
{
    //目标物体空间
    public Transform targetObj;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 objpos = targetObj.InverseTransformPoint(transform.position);
        Shader.SetGlobalVector("_CharacterPosition", new Vector4(objpos.x, objpos.y, objpos.z, 0.0f));
    }
}

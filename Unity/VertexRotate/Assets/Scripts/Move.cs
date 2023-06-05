using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour
{

    public Camera cameradir;
    public float speed = 0.2f;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float h = Input.GetAxis("Horizontal");//这个代码的意思是 对应键盘上面的左右箭头，当按下左或右箭头时触发

        float v = Input.GetAxis("Vertical"); //对应键盘上面的上下箭头，当按下上或下箭头时触发

        Vector3 move = Vector3.ProjectOnPlane(cameradir.transform.forward, Vector3.up).normalized * v + Vector3.ProjectOnPlane(cameradir.transform.right, Vector3.up).normalized * h;

        transform.position += move * speed;
    }
}

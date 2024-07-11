using UnityEngine;

public class RotateRays : MonoBehaviour
{
    public Material raysMaterial;
    private float timeOffset;

    public enum MovementType
    {
        Clockwise,
        Counterclockwise,
        Pendulum,
        AccelerateDecelerate,
        Pulsation
    }

    public MovementType movementType;

    void Update()
    {
        timeOffset += Time.deltaTime;
        raysMaterial.SetFloat("_TimeOffset", timeOffset);

        switch (movementType)
        {
            case MovementType.Clockwise:
                raysMaterial.SetInt("_MovementType", 0);
                break;
            case MovementType.Counterclockwise:
                raysMaterial.SetInt("_MovementType", 1);
                break;
            case MovementType.Pendulum:
                raysMaterial.SetInt("_MovementType", 2);
                break;
            case MovementType.AccelerateDecelerate:
                raysMaterial.SetInt("_MovementType", 3);
                break;
            case MovementType.Pulsation:
                raysMaterial.SetInt("_MovementType", 4);
                break;
        }
    }
}

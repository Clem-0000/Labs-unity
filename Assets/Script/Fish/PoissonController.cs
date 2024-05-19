using UnityEngine;

public class PoissonController : MonoBehaviour
{
    public float vitesseAvance = 1f;
    public float hauteurFluctuation = 0.5f;
    public float frequenceFluctuation = 1f;
    public float dureeRotation = 1f;
    public float distanceSeuil = 1f;
    public float ajustementProfondeur = 0.5f;

    public Vector3 zoneCentre = Vector3.zero;
    public Vector3 zoneDimensions = new Vector3(10f, 5f, 10f);

    private Collider poissonCollider;

    private bool enRotation = false;
    private float tempsRotation = 0f;
    private Quaternion rotationInitiale;
    private Quaternion rotationFinale;

    void Start()
    {
        poissonCollider = GetComponent<Collider>();
    }

    void Update()
    {
        if (enRotation)
        {
            EffectuerRotation();
        }
        else
        {
            VerifierProximiteLimites();
            Avancer();
        }
    }

    void Avancer()
    {
        transform.Translate(Vector3.up * vitesseAvance * Time.deltaTime);
    }


    void VerifierProximiteLimites()
    {
        Vector3 positionRelative = transform.position - zoneCentre;
        Vector3 demiDimensions = zoneDimensions / 2;

        Vector3 poissonExtents = poissonCollider.bounds.extents;

        bool procheDeLaLimite = false;
        bool procheLimiteVerticale = false;

        if (Mathf.Abs(positionRelative.x) > demiDimensions.x - poissonExtents.x - distanceSeuil)
        {
            procheDeLaLimite = true;
        }

        if (Mathf.Abs(positionRelative.z) > demiDimensions.z - poissonExtents.z - distanceSeuil)
        {
            procheDeLaLimite = true;
        }

        if (Mathf.Abs(positionRelative.y) > demiDimensions.y - poissonExtents.y - distanceSeuil)
        {
            procheLimiteVerticale = true;
        }

        if (procheDeLaLimite)
        {
            vitesseAvance = Mathf.Lerp(vitesseAvance, 0f, Time.deltaTime / dureeRotation);

            Vector3 directionMouvement = transform.forward;
            float angleRotation = Vector3.SignedAngle(directionMouvement, positionRelative.normalized, Vector3.up);

            rotationInitiale = transform.rotation;
            rotationFinale = Quaternion.Euler(transform.eulerAngles + new Vector3(0, angleRotation, 0));
            enRotation = true;
            tempsRotation = 0f;
        }
        else if (procheLimiteVerticale)
        {
            float direction = positionRelative.y > 0 ? -1 : 1;
            transform.position += new Vector3(0, direction * ajustementProfondeur, 0);
        }
        else
        {
            vitesseAvance = 0.4f;
        }
    }

    void EffectuerRotation()
    {
        tempsRotation += Time.deltaTime / dureeRotation;
        transform.rotation = Quaternion.Lerp(rotationInitiale, rotationFinale, tempsRotation);

        if (tempsRotation >= 1f)
        {
            enRotation = false;
        }
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawWireCube(zoneCentre, zoneDimensions);
    }
}

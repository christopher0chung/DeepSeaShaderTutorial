using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asset_Chunk {

    public Vector3 originPoint;
    public int index;

    #region Private Variables
    private GameObject _gO;
    private MeshRenderer _mR;
    private MeshFilter _mF;

    private Mesh _mesh;

    private Vector3[] _vertices;
    private int[] _triangles;
    private Vector2[] _uvs;
    private Vector3[] _normals;
    #endregion

    public Asset_Chunk(Vector3 origin, int index)
    {
        originPoint = origin;

        _Initialize(index);
        _CalculateVertsAndUVs();
        _CalculateTris();
        _CalculateNorms();
        _ApplyCalculations();
    }

    #region Internal Functions
    private void _Initialize(int index)
    {
        // Initialize variables and establish references

        _gO = new GameObject();
        _gO.name = "Chunk_" + index;

        _mR = _gO.AddComponent<MeshRenderer>();
        _mF = _gO.AddComponent<MeshFilter>();

        _mesh = new Mesh();
        _mesh.name = "Mesh_" + index;
    }

    private void _CalculateVertsAndUVs()
    {
        List<Vector3> _tempVerts = new List<Vector3>();
        List<Vector2> _tempUVs = new List<Vector2>();

        // Build mesh
        // Calculates UVs at the same time since each vert is being accessed already
        // A chunk is 8x8 Unity units
        // Uses origin offset (originPoint) instead of transform because colliders and other components were not needed on each chunk
        // Blended octives on non-integer intervals to avoid returning 0 values from Perlin noise
        // Linear x-z facing UVs; not intended to be used by shader

        for (int i = 0; i <= 8; i++)
        {
            for (int j = 0; j <= 8; j++)
            {
                float X = (float)(originPoint.x + j);
                float Z = (float)(originPoint.z + i);

                Vector3 pos = new Vector3(X, 
                    originPoint.y + 10 * Perlin.Noise(X / 3.35f, Z / 3.35f) * Perlin.Noise(X/16.23f, Z/50.23f), 
                    Z);

                _tempVerts.Add(pos);
                _tempUVs.Add(new Vector2(
                    (float)i / 8, 
                    (float)j / 8));
            }
        }

        _vertices = new Vector3[_tempVerts.Count];
        for (int i = 0; i < _vertices.Length; i++)
        {
            _vertices[i] = _tempVerts[i];
        }

        _uvs = new Vector2[_tempUVs.Count];
        for (int i = 0; i < _uvs.Length; i++)
        {
            _uvs[i] = _tempUVs[i];
        }
    }

    private void _CalculateTris()
    {
        // Calculates quads by doing two tris per region

        List<int> _tempTris = new List<int>();

        for (int z = 0; z < 8; z++)
        {
            for (int x = 0; x < 8; x++)
            {
                _tempTris.Add(x + z * 9);
                _tempTris.Add(x + z * 9 + 10);
                _tempTris.Add(x + z * 9 + 1);

                _tempTris.Add(x + z * 9);
                _tempTris.Add(x + z * 9 + 9);
                _tempTris.Add(x + z * 9 + 10);
            }
        }

        _triangles = new int[_tempTris.Count];
        for (int i = 0; i < _triangles.Length; i++)
        {
            _triangles[i] = _tempTris[i];
        }
    }

    private void _CalculateNorms()
    {
        // Using Unity's normal calculation
        // Depricated
        // Adequate given intended shader

        _normals = new Vector3[_vertices.Length];
    }

    private void _ApplyCalculations()
    {
        // Required final step
        
        _mesh.vertices = _vertices;
        _mesh.triangles = _triangles;
        _mesh.uv = _uvs;
        _mesh.normals = _normals;

        _mF.mesh = _mesh;

        _mesh.RecalculateNormals();

        _mR.material = Resources.Load<Material>("Terrain");
    }
    #endregion
}
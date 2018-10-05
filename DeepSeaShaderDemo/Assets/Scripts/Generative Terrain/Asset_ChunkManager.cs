using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asset_ChunkManager : MonoBehaviour {

    public List<Asset_Chunk> myChunk;

	void Start () {
        myChunk = new List<Asset_Chunk>();

        for (int j = -10; j < 10; j++)
        {
            for (int i = -10; i < 10; i++)
            {
                Vector3 origin = new Vector3(i * 8, -15f, j * 8);
                myChunk.Add(new Asset_Chunk(origin, j * 20 + i));
            }
        }
	}

}

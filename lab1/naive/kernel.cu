/******************************************************************************
 *cr
 *cr            (C) Copyright 2010 The Board of Trustees of the
 *cr                        University of Illinois
 *cr                         All Rights Reserved
 *cr
 ******************************************************************************/

#define BLOCK_SIZE 512

__global__ void reduction(float *out, float *in, unsigned size)
{
    /********************************************************************
    Load a segment of the input vector into shared memory
    Traverse the reduction tree
    Write the computed sum to the output vector at the correct index
    ********************************************************************/
    __shared__ float partialSum[2*BLOCK_SIZE];
    unsigned int t = threadIdx.x;
    unsigned int start = 2*blockIdx.x*blockDim.x;
    partialSum[t] = in[start + t];
    partialSum[blockDim.x + t] = in[start + blockDim.x + t];
    for (unsigned int stride = 1; stride <= blockDim.x; stride *= 2)
    {
      __syncthreads();
      if (t%stride == 0 && 2*t + start + stride < size)
        partialSum[2*t]+=partialSum[2*t+stride];
    }
    // INSERT KERNEL CODE HERE
    if (t == 0)
      out[blockIdx.x] = partialSum[0];
}




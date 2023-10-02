#ifndef NCO_LUT_H_
#define NCO_LUT_H_

#include <ap_fixed.h>
#include <complex>
#include "utils.h"

/*
LUT based NCO implementation
input: phase_in
output: cos(phase_in*pi/2) + j*sin(phase_in*pi/2)

For DOUBLE_SIMULATION, use -DDOUBLE_SIMULATION
*/

#ifdef DOUBLE_SIMULATION
typedef double PHASE_TR;
typedef std::complex<double> SIG_OUT_TC;
#else
typedef ap_ufixed<19, 2> PHASE_TR;
typedef std::complex<ap_fixed<18, 1, AP_TRN, AP_SAT>> SIG_OUT_TC;
#endif
void nco_lut_hls(PHASE_TR phase_in, SIG_OUT_TC& cossin);

template<typename PHASE_TR, typename SIG_OUT_TC, int LUT_LEN = 512>
SIG_OUT_TC nco_lut(PHASE_TR phase_in){
    #ifdef DOUBLE_SIMULATION
    static const double PI_C = 3.141592653589793238;
    // create datatype of signal values
    typedef double  SIG_OUT_TR;

    // create datatype for index.
    // LUT_LEN entries in sin table + 4 quadrants
    typedef unsigned int INDEX_TR;
    typedef unsigned int INDEX_LUT_TR;
    typedef unsigned int QUAD_TR;
    #else
    // create datatype of signal values
    typedef utils::base_type_t<SIG_OUT_TC> SIG_OUT_TR;
    // create datatype for index.
    // LUT_LEN entries in sin table + 4 quadrants
    typedef ap_uint<utils::ceil_log2(LUT_LEN) + 2> INDEX_TR;
    // LUT_LEN entries in sin table, +1 is to represent 512
    typedef ap_uint<utils::ceil_log2(LUT_LEN) + 1> INDEX_LUT_TR;

    const INDEX_LUT_TR index512 = 512;
    typedef ap_uint<2> QUAD_TR;
    #endif

    // read a lut from an external file.
    // the lut contains the sin value from 0 to pi/2
    SIG_OUT_TR sinlut[LUT_LEN] = {
        #include "./sin0_90.h"
    };

    //indexing the value in lut
    INDEX_TR index;

    SIG_OUT_TR sin_out_tmp;
    SIG_OUT_TR cos_out_tmp;
    
    INDEX_LUT_TR sin_index;
    INDEX_LUT_TR cos_index;

    QUAD_TR quad;

    #ifdef DOUBLE_SIMULATION
    #include <cmath>
    double phase_lsb = PI_C/2/LUT_LEN;
    phase_in = phase_in * PI_C / 2;
    phase_in = std::fmod(phase_in, (2*PI_C));
    index = (int)(0.5 + phase_in / phase_lsb); // c++ round double to int
    // the 11 lsb consists of 2-bit quad and 9-bit entry index.
    // when phase_in is very close to 2pi, index is 2048, which overflows the 2-bit quad
    index = index << 21; 
    index = index >> 21; 
    sin_index = index % LUT_LEN;
    cos_index = LUT_LEN - sin_index;
    quad = index >> 9;
    switch (quad)
    {
    case 0:
        sin_out_tmp = sinlut[sin_index];
        cos_out_tmp = cos_index == LUT_LEN? 1:sinlut[cos_index];
        break;
    case 1:
        sin_out_tmp = cos_index == LUT_LEN? 1:sinlut[cos_index];
        cos_out_tmp = -sinlut[sin_index];
        break;
    case 2:
        sin_out_tmp = -sinlut[sin_index];
        cos_out_tmp = cos_index == LUT_LEN? -1:-sinlut[cos_index];
        break;
    case 3:
        sin_out_tmp = cos_index == LUT_LEN? -1:-sinlut[cos_index];
        cos_out_tmp = sinlut[sin_index];
        break;
    default:
        #ifndef __SYNTHESIS__
            printf("error: quad is %d\n", quad);
            exit(-1);
        #endif
    }
    #else //HLS
    index = phase_in.range(PHASE_TR::width-1, PHASE_TR::width-INDEX_TR::width);
    sin_index = index.range(INDEX_TR::width-3, 0);
    cos_index = index512 - sin_index;
    quad = index.range(INDEX_TR::width-1, INDEX_TR::width-2);

    switch (quad)
    {
    case 0:
        sin_out_tmp = sinlut[sin_index];
        cos_out_tmp = (cos_index == index512) ? (SIG_OUT_TR)1:sinlut[cos_index];
        break;
    case 1:
        sin_out_tmp = (cos_index == index512) ? (SIG_OUT_TR)1:sinlut[cos_index];
        cos_out_tmp = -sinlut[sin_index];
        break;
    case 2:
        sin_out_tmp = -sinlut[sin_index];
        cos_out_tmp = (cos_index == index512) ? (SIG_OUT_TR)(-1):(SIG_OUT_TR)(-sinlut[cos_index]);
        break;
    case 3:
        sin_out_tmp = (cos_index == index512) ? (SIG_OUT_TR)(-1):(SIG_OUT_TR)(-sinlut[cos_index]);
        cos_out_tmp = sinlut[sin_index];
        break;
    default:
        #ifndef __SYNTHESIS__
            printf("error: quad is %d\n", quad.to_int());
            exit(-1);
        #endif
		sin_out_tmp = sinlut[sin_index];
		cos_out_tmp = (cos_index == index512) ? (SIG_OUT_TR)1:sinlut[cos_index];
    } 
    #endif
    return SIG_OUT_TC(cos_out_tmp, sin_out_tmp);
}
#endif

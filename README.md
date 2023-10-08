# DAFIP
Digital ASIC FPGA IP examples
- [DAFIP](#dafip)
- [Overview](#overview)
- [IIR implementation](#iir-implementation)
  * [Implementation structure](#implementation-structure)
  * [Testbench](#testbench)
  * [Calculate theoritical quantization error](#calculate-theoritical-quantization-error)
- [Gray and binary number convertion](#gray-and-binary-number-convertion)
  * [Background](#background)
  * [Binary to gray](#binary-to-gray)
  * [Gray to binary](#gray-to-binary)
- [QAM modulation](#qam-modulation)
  * [non-normalized QAM](#nonnormalized-qam)
  * [normalized QAM](#normalized-qam)
  * [Demodulation](#demodulation)
  * [Data precision v.s. MSE](#data-precision-vs-mse)
- [LUT-based NCO](#numerically-controlled-oscillator)
  * [SNR](#double-precision-model-and-snr)
  * [Error correction](#error-correction)
- [Polyphase filter](#polyphase-filter)
  * [Polyphase representation](#re-represent-z-transform-of-a-filter-in-case-of-downsampling)
  * [Proof of equivalent systems](#proof-of-equivalent-systems)
# Overview
| IP                  | Implementation | Verification | Documentation | Category |
|---------------------|----------------|--------------|---------------|----------|
| [IIR](https://github.com/HaogeL/DAFIP/tree/main/IIR)|:white_check_mark:|:white_check_mark:|:white_check_mark:| DSP      |
| [AsyncFIFO](https://github.com/HaogeL/DAFIP/tree/main/AsyncFIFO)|:white_check_mark:|:x:|:x:| CDC      |
| [SyncFIFO](https://github.com/HaogeL/DAFIP/tree/main/SyncFIFO)|:white_check_mark:|:x:|:x:| Common   |
| [RoundRobinArbiter](https://github.com/HaogeL/DAFIP/tree/main/RoundRobinArbiter)|:white_check_mark:|:x:|:x:| Common   |
| [FrequencyDivider](https://github.com/HaogeL/DAFIP/tree/main/FrequencyDivider/3)|:white_check_mark:|:x:|:x:| Common   |
| [Multi-based divider](https://github.com/HaogeL/multiplication_based_divider/blob/master/readme/readme.pdf)|:white_check_mark:|:x:|:white_check_mark:| DSP      |
| [FSMTemplate](https://github.com/HaogeL/DAFIP/tree/main/FSMTemplate)|:white_check_mark:|:x:|:x: | Common   |
| [GrayBinConversion](https://github.com/HaogeL/DAFIP/tree/main/GrayBin)|:white_check_mark:|:white_check_mark:|:white_check_mark:| Common   |
| [FIR](https://github.com/HaogeL/DAFIP/tree/main/FIR)|:white_check_mark:|:white_check_mark:|:white_check_mark:| DSP   |
| [QAMMOD](https://github.com/HaogeL/DAFIP/tree/main/QamMod)|:white_check_mark:|:white_check_mark:|:white_check_mark:| DSP   |
| [NCO](https://github.com/HaogeL/DAFIP/tree/main/NCO_LUT)|:white_check_mark:|:white_check_mark:|:white_check_mark:| DSP   |
| [Polyphase_fir](https://github.com/HaogeL/DAFIP/tree/main/polyphase_filter)|:white_check_mark:|:white_check_mark:|:white_check_mark:| DSP   |
# IIR implementation
This IIR implementation is an example of first-order IIR filer with testbench to check the simulation results. Key features of the provided IIR are:
- Difference equation is $$y[n] = ax[n] + (1-a)y[n-1]$$, where a = 2^(-A). In the example, A is 3 and division operation is realized by arithmetic shift.
- Data type of input and output is `ap_fixed<16,2>`
- Theoretical quantization error falls in the range of (-0.000031,0.000076). Random simulation quantization error falls in the range of (-0.000019, 0.000066). Check Section [Calculate theoritical quantization error](#Calculate-theoritical-quantization-error) for the theorithical proof.
## Implementation structure
![IIR structure](./IIR/README/IIRExampleStructure.png "IIR structure")*IIR structure*
## Testbench
### Get reference input and output
Testbench stimuli and reference ouput are obtained from Matlab scripts`./matlab/get_matlab_reference_testdata_rand.m` and `./matlab/get_matlab_reference_testdata_sin.m`. \
The same IIR filter in Matlab is realized by Matlab [1-D filter function](https://www.mathworks.com/help/matlab/ref/filter.html?s_tid=doc_ta).

![SinTestData](./IIR/README/ReferenceInputOutput.png "Matlab testdata")

Testdata is stored in binary file `./testData/testdata.bin` and later read by C testbench
### Run C testbench
Run tcl file to create Vitis_hls project, run C simulation and RTL simulation
```
cd ./vitis_hls
vitis_hls -f run_hls.tcl
```
C testbench reads testdata generated from the previous step,  drives the IIR with stimuli, and compares DUT and Matlab reference output with quantization error boundary. The DUT output will also be stored in `./vitis_hls/proj/solution/csim/build/dut_output.bin` for further plot.
### Check DUT output in Matlab
`./matlab/check_sim_result.m` reads testdata.bin and dut_output.bin, and compare the results with theoretical quantization error bound curve. Given the IIR parameter, the upper bound is

$$
\sum_{i=1}^{A-1}-2^{-(fwidth+A+1+i)} * 2^{A}*(1-\frac{2^{A}-1}{2^{A}})^{n+1} + \sum_{i=1}^{A}-2^{-(fwidth+i)}
$$

and lower bound is

$$
-2^{-(fwidth+A+1)} * 2^{A}*(1-\frac{2^{A}-1}{2^{A}})^{n+1}
$$

,where `A` is shift distance and `fwidth` is the fraction width of data type.
The figure below shows that simulation error is inside of the boundary.
![Quantization err](./IIR/README/Quantization_error100.png "QuantizationError100points")\
Note that the actual simulation error should be much better than theoretical boundary. This is because the error on the boundary can only be achieved when the maximum quantization error is introduced every time when data is quantized to a smaller precision, which explains, in the figure below, the acutal quantization error occupies only ~70% of the error boundary.
![Quantization err](./IIR/README/Quantization_error_full.png "QuantizationError100_full")
## Calculate theoritical quantization error
Quantization error can be considered as an `unit step input` with varying range. Variable `diff` use the rounding method of `AP_RND`, which is  equvilent to introduce an error after the shift operator in the structure, shown as the `quantization error` in the figure below

![IIRStructureWithQuanErr](./IIR/README/IIRStructureWithQuanErr.png "IIR")*IIR Structure with quantization error*

The data type of `diff` variable is `ap_fixed<17,2>`, and one of the operands of the previous shift operation is `ap_fixed<18,2>`. Therefore when the result is converted to `diff`, HLS rounds the value to the nearest representable value of `ap_fixed<17,2>`, which means the added quantization error ranges from $-20^{-19}-20^{-20}$ to $2^{-18}$ (denoted as $quan_{range}$). Then the difference equation with the added quantization error can be rewriten as

$$
\begin{align}
y_{err}[n] &= ax[n] + (1-a)y_{err}[n-1] \\ 
&= a(x[n]-y_{err}[n-1]) + qan_{err} + y_{err}[n-1] \\
y_{err}[n] &= y[n] + err[n]
\end{align}
$$

and the original difference equation shows that $$y[n] = a(x[n]-y[n-1]) + y[n-1]$$, so $err[n]$ can be expressed as a function of $quan_{err}$ $$err[n] = -a*err[n-1]+err[n-1]+quan_{err}$$ The transfer function of the difference equaltion above is $$\frac{E}{Q_{err}} = \frac{1}{1-Z^{-1}(1-a))}$$, where $a=2^{-A}$ which is $1/8$ in this case. As mentioned in the beginning of this section, $Q_{err}$ is equvialent to `unit step` function with varying amplitude of $quan_{range}$, therefore $E$ in the above equation can be rewriten as the follow. $$E = \frac{1}{1-\frac{7}{8}Z^{-1}}\frac{quan_{range}}{1-Z^{-1}}$$ In the time domain, err[n] can be rewritten: $$err[n] = 8quan_{err}(1-(\frac{7}{8})^{n+1})$$. By applying lower and upper bound of $quan_{range}$, the error boundary of variable `y_reg_` can be derived.

# Gray and binary number convertion
This repo provides IP example of gray-code to binary-code and binary-code to gray-code conversion. Binary-to-gray conversion is simple. Implementation of gray-to-binary is straightforward as well. However, for strict timing constraints, optimizing gray-to-binary conversion can be a little bit complicated.
## Background
Visit https://en.wikipedia.org/wiki/Gray_code
## Binary to gray
Binary-to-gray is simple and easy, and there is nothing to optimize. All **xor** operations of each bit-pair can be performed in parallel. HLS code is as simple as below
```C
template <class DATA_T> 
DATA_T bin2gray(DATA_T bin) {
  DATA_T gray = bin ^ (bin >> 1);
  return gray;
}
```

Steps to run the implementation of binary-to-gray conversion are
```
cd <repo-path>/GrayBin/vitis_hls
vitis_hls -f run_hls_bin2gray
vitis_hls -p bin2gray
```
## Gray to binary
Gray-code to binary-code conversion is not difficult: in a word, given N-bit input (**gray**), each bit of binary output, **bin[n]**, can be recursively xor-ed from **bin[n+1]** and **gray[n]**, and **bin[MSB]** is same as **gray[MSB]**. Therefore, the simplest implementation of gray-to-binary conversion is nothing but an **xor chain**, which is very similar to ripple carry adders, i.e. the previous output of **xor** is the current input of **xor**. The cirtical path is always the longest path of the chain, which yields **bin[LSB]**. Run the following steps to see the implementation of this kind of non-optimized gray-to-binary conversion.
```
cd <repo-path>/GrayBin/vitis_hls
vitis_hls -f run_hls_gray2bin
vitis_hls -p gray2bin
```
### Optimize timing: trade area for timing
Because xor operation is **commutative** and **associative**, we can xor many different bits in parallel. Implementation found in function [gray2bin_paral](https://github.com/HaogeL/DAFIP/blob/main/GrayBin/vitis_hls/gray_bin.h#L63) utilizes the idea of [parallel prefix algorithms](https://www.chessprogramming.org/Parallel_Prefix_Algorithms). The delay for N-bit gray-to-bincary convertion roughly equals to $ceil(log_{2}{N})$ times of the propagation dealy of an **xor** operation. In the provided example, C synthesis results of optimized and non-optimized gray-to-binary conversions are compared in the table below with ap_vld as port-level protocal and ap_ctrl_hs as block-level protocal.
```text
+----------------+-------+---------+--------+---------+----------+----+----+
|     Modules    |       | Latency | Latency|         |          |    |    |
|     & Loops    | Slack | (cycles)|  (ns)  | Interval| Pipelined| FF | LUT|
+----------------+-------+---------+--------+---------+----------+----+----+
|+ gray2bin_hls  |  -0.95|        1|   1.952|        1|       yes|  34|  64|
+----------------+-------+---------+--------+---------+----------+----+----+

+----------------------+------+---------+--------+---------+----------+---+-----+
|        Modules       |      | Latency | Latency|         |          |   |     |
|        & Loops       | Slack| (cycles)|  (ns)  | Interval| Pipelined| FF|  LUT|
+----------------------+------+---------+--------+---------+----------+---+-----+
|+ gray2bin_paral_hls  |  0.16|        1|   1.000|        1|       yes| 58|  162|
+----------------------+------+---------+--------+---------+----------+---+-----+
```
# QAM modulation
HLS desgin [QamMod directory](https://github.com/HaogeL/DAFIP/tree/main/QamMod/vitis_hls) demonstrates 4, 16, 64, 256 QAM modulation examples with binary symbol order. Their implementations are all derived from [QamMod.h](https://github.com/HaogeL/DAFIP/blob/main/QamMod/vitis_hls/QamMod.h), thus it is easy to expand to higher modulation formats, such as 1K QAM. 

## non-normalized QAM
For non-normalized QAM modulation, symbol space is 2, and symbol order of 16-QAM as an example is shown as figure below. By using [bin2gray converter](https://github.com/HaogeL/DAFIP/blob/main/GrayBin/vitis_hls/gray_bin.cpp), gray-code ordering is easily achieved. 

![16-QAM](./QamMod/README/QAM16.png "QAM16")*QAM16 example*

## normalized QAM
Based on non-normalized QAM modulation, fixed-point numbers are used to represent constellation, and the average power is normalized to 1. As a comparison of the figure above, normalized 16-QAM constellation is plotted below.
![16-QAM](./QamMod/README/QAM16_normalized.png "Normalized QAM16")*Normalized QAM16 example*

FPGA resource comsumption for 4-, 16-, 64-, 256- QAM are listed below, with constellation is represented by **std::complex<ap_fixed<20, 2>>**, in which port-level and block-level are removed and therefore they are considered as combinational logic. For device xcvu9p-flga2104-2-i, their speed, with constraint of 1 ns, are shown in the table as well.
| 4- QAM                                                                      | 16- QAM                                                                     | 64- QAM                                                                    | 256- QAM                                                                    |
|-----------------------------------------------------------------------------|-----------------------------------------------------------------------------|----------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| LUT:    2; Others: 0                                                         | LUT:    4; Others: 0                                                         | LUT:    12; Others: 0                                                       | LUT:    34; Others: 0                                                        |
| Max path delay: 0.038ns  (logic 0.038ns (100.000%)  route 0.000ns (0.000%)) | Max path delay: 0.038ns  (logic 0.038ns (100.000%)  route 0.000ns (0.000%)) | Max path delay: 0.249ns  (logic 0.229ns (91.968%)  route 0.020ns (8.032%)) | MAX path delay: 0.593ns  (logic 0.328ns (55.312%)  route 0.265ns (44.688%)) |

## Demodulation
Demodulation algorithm is reverse process of QAM modulation, which is implemented in [QamMod.h](https://github.com/HaogeL/DAFIP/blob/main/QamMod/vitis_hls/QamMod.h).

## Data precision v.s. MSE
All the examples of normalized QAM modulations use **std::complex<ap_fixed<20, 2>>** to represent constellations, which is not identical to ideal double datetype. Define the MSE as 
$$MSE = \frac{1}{M\cdot pow_{avg}}\sum_{i=1}^{M}(|cst_{ideal}-cst_{hls}|^{2})$$
, where M is the size of constellation, $cst_{ideal}$ and $cst_{hls}$ are ideal and fixed-point constellation outputs, respectively, $M$ is modulation size, and $pow_{avg}$ is the average power of constellation.

As an example, steps to check MSE of 256 QAM follows below. 
```bash
cd QamMod/vitis_hls
vitis_hls -f run_hls_Qam256_normalized.tcl
cd ../matlab && matlab
>> CheckQamResult(256, 1)
For normolized256QAM
average power of HLS QAM output is 0.999947576929117
average power of ideal QAM output is 1.000000000000000
quantization mse -91.630037 db
```
The following figure shows decreasing MSE when more fractional bits are used to represent constellations.
![MSEvsFrac](./QamMod/README/fractionalBitsVsMse.png "fractional bits v.s. MSE") 

# FIR

## Normal FIR with real input signal
```bash
# generate test data and coefficients from Matlab
cd FIR/matlab
matlab -nodesktop -nojvm -r "run('getTestData.m'); exit"
# run vitis model, vitis project is located in the directory named proj
cd ../vitis_hls
vitis_hls -f run_hls.tcl
# run matlab script to check the quality of results
cd ../matlab
matlab -nodesktop -r "run('checkDutResult.m');"
# type exit to quit Matlab CLI
```

## Complex FIR with complex input signal and coefficients
```bash
# generate test data and coefficients from Matlab
cd FIR/matlab
matlab -nodesktop -nojvm -r "run('getTestData_cplx.m'); exit"
# run vitis model, vitis project is located in the directory named proj_cplx
cd ../vitis_hls
vitis_hls -f run_hls_fir_cplx.tcl
# run matlab script to check the quality of results
cd ../matlab
matlab -nodesktop -r "run('checkDutResult_cplx.m');"
# type exit to quit Matlab CLI
```

# Numerically controlled oscillator
Two Matlab scripts are used to generate stimulus, run HLS module, and check the quality of DUT output. **check_dut_output_double.m** runs double representation of NCO and **check_dut_output_fixed.m** run fixed point number representation of NCO. In the NCO implementation, a LUT containing 512 sinusoid values, ranging from $0$ to $\pi/2-\pi/2/512$, are pre-generated and stored in ROM in silicon. At the end of the two Matlab scripts, the SNR are calculated, using Matlab build-in **sin()** and **cos()** functions. 

## Double-precision model and SNR
For double-number model, the SNR is derived as the follows.

Assume sine or coine from $0$ to $2\pi$ is the signal NCO wants to generate. The phase resolution ($ph_{lsb}$) is $\pi/2/512$ in the provided example, which means the distribution of phase error is a uniform distribution, from $\frac{-ph_{lsb}}{2}$ to $\frac{ph_{lsb}}{2}$ with probability of $\frac{1}{ph_{lsb}}$. Therefore, the error can be expressed as 

$$
Err = sig' * Err_{ph}
$$

and

$$
Err^2_{ph} = \int_{\frac{-ph_{lsb}}{2}}^{\frac{ph_{lsb}}{2}} e^2\frac{1}{ph_{lsb}}de
=\frac{ph_{lsb}^{2}}{12}
$$

, where $sig'$ is the derivative of signal and $Err_{ph}$ is phase error. If sine wave is applied, $Err$ power can be expressed as

$$
P_{err} = \frac{1}{2\pi}\int_{0}^{2\pi}cos^2(x)Err^2_{ph} = \frac{ph_{lsb}^{2}}{24}
$$

The SNR of double precision model is

$$
10log_{10}(\frac{P_{sig}}{P_{err}}) = 10log_{10}(\frac{12}{ph_{lsb}^{2}})
$$

The phase resolution ($ph^{2}_{lsb}$) depends on the number of entries in the pre-calculated LUT, and it can be expressed as $\frac{\pi}{2}/2^{N}$. 

By summarizing above, the final SNR is

$$
SNR = 10*log_{10}(\frac{48}{\pi^{2}}2^{2N}) = 6.8694 +6.02N
$$

In this example, N is 9. The theoretical SNR is 61.0494, and the simulated SNR is 61.0548 

![NCO_double](./NCO_LUT/matlab/double_precision_model_simulation.jpg "Double precision model simulation") \
*Double precision model simulation*

If NCO output is quantized to fixed point data, 18 bits in the provided example, the SNR decreases to 55.034 dB.


![NCO_fixed](./NCO_LUT/matlab/fixed_precision_model_simulation.jpg "Fixed precision model simulation") \
*Fixed-point precision model simulation*

## Error correction
The most contribution to the noise is cased by the phase noise during quantization. The phase noise can be easily obtained and the output error can be compensated by using the product of phase noise and derivative at the selected phase.

# Polyphase filter
## Re-represent Z-transform of a filter, in case of downsampling
<p align="center">
<img src="./polyphase_filter/downsample_system.png" width="400" height="60"> <bar>
</p>
<div align="center">
 <i>downsample system</i>
</div>
 
Figure above shows the downsampling system, where H(z) is a low-pass filter. However, from HW implementation perspective, it is not efficient. Becuase H(z) is running at original frequency, but downsampling module would discard $\frac{M-1}{M}$ filtered samples. Ployphase filter is designed to tackle this problem.

The Z-transform of digital signal $h[n]$ is 

$$H(z) = \sum_{n=-\infty}^{\infty}h[n]z^{-n}$$

This can be rewritten as 

$$
\begin{align}
H(z) &= \sum_{i=-\infty}^{\infty}\sum_{j=0}^{M-1}h[iM+j]z^{-(iM+j)}\\
&=\sum_{j=0}^{M-1}z^{-j}\sum_{i=-\infty}^{\infty}h[iM+j]z^{-iM}
\end{align}
$$

Note that $h[iM+j] (j\in[0,M-1])$ is the downsampled sequence with j shift. It has Z-transform 

$$D_{j}(z) = \sum_{i=-\infty}^{\infty}h[iM+j]z^{-i}$$ 

$H(z)$ can be rewritten as $$\sum_{j=0}^{M-1}z^{-j}E_{j}(z^{M})$$.
Therefore, Z-transform of a filter can be drawn in the following form

<p align="center">
<img src="./polyphase_filter/polyphase_filter.png" width="400" height="400"> <bar>
</p>
<div align="center">
 <i>polyphase_filter</i>
</div>


Figure below shows downsampling system, where H(z) is replaced by its polyphase form.

<p align="center">
<img src="./polyphase_filter/replaceHz.png" width="400" height="400"> <bar>
</p>
<div align="center">
 <i>Replace H(z) in downsample system</i>
</div>
 
Shown in the following section, the above structure is equivalent to the structure below, where signals are downsampled first.

<p align="center">
<img src="./polyphase_filter/equivalentSystem.png" width="400" height="400"> <bar>
</p>
<div align="center">
 <i>Equivalent downsample system</i>
</div>
 
Matlab script [**demo_polyphase_filter.m**](https://github.com/HaogeL/DAFIP/tree/main/polyphase_filter/matlab/demo_polyphase_filter.m) shows the above two systems have the same output results.
## Proof of equivalent systems
In the figure below, y1[n] is equal to y2[n].
<p align="center">
<img src="./polyphase_filter/identicalSystem.png" width="400" height="100"> <bar>
</p>
<div align="center">
 <i>identical systems, y1[n] = y2[n]</i>
</div>
 
In frequency domain, the Fourier transform of X'[n] is $X_{1}(\omega) = X(\omega)E_{0}(M\omega)$

$$
\begin{align}
Y1(\omega) &= \frac{1}{M}\sum_{M-1}^{i=0}X_{1}(\frac{\omega}{M}-\frac{2\pi i}{M})\\
&=\frac{1}{M}\sum_{i=0}^{M-1}X(\frac{\omega}{M}-\frac{2\pi i}{M})E_{0}(\omega-2\pi i)\\
&=E_{0}(\omega)\frac{1}{M}\sum_{i=0}^{M-1}X(\frac{\omega}{M}-\frac{2\pi i}{M})\\
&=E_{0}(\omega)X_{2}(\omega)
\end{align}
$$

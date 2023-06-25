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
Because xor operation is **commutative** and **associative**, we can xor many different bits in parallel. Implementation found in function [**gray2bin_paral**]{link} utilizes the idea of [parallel prefix algorithms](https://www.chessprogramming.org/Parallel_Prefix_Algorithms). The delay for N-bit gray-to-bincary convertion roughly equals to $ceil(log_{2}{N})$ times of the propagation dealy of an **xor** operation. In the provided example, C synthesis results of optimized and non-optimized gray-to-binary conversions are compared in the table below.
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

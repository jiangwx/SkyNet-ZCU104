# SkyNet
This is a repository for SkyNet, a lightweight DNN specialized in object detection. The original [SkyNet](https://github.com/TomG008/SkyNet) is implemented on Ultra96.
I transplant the project to ZCU104 and add dynamic voltage and frequency (DVFS) support to it.

---

# FPGA
## Platform
[Xilinx ZCU104](https://www.xilinx.com/products/boards-and-kits/zcu104.html)
## Software prerequisites
[Vivado Design Suite - HLx Editions](https://www.xilinx.com/products/design-tools/vivado.html#overview)
## Directly run the demo on the FPGA

This example allows you to directly try our bitstream and weights by running over 16 test images, stored in test_images from 0.jpg to 15.jpg.
The images are processed with a batch size of 4.
The host code (SkyNet.py) runs on the embedded ARM core.
It first loads the weight file (SkyNet.bin), and then loads the binary file (SkyNet.bit) to configure the FPGA program logic.
Then it activates the SkyNet IP to execute the inference of input images, and outputs the coordinates of detected bounding boxes.
Finally it shows the total execution time (s) and energy consumption (J).

To run the demo:
```
$ cd ./FPGA/Deploy/
$ sudo python3 SkyNet.py --frequency 330 --voltage 750
```

You should be able to see outputs like:

```
**** Running SkyNet
Allocating memory done
Parameters loading done
Bitstream loaded

**** Start to detect
['0.jpg', '1.jpg', '2.jpg', '3.jpg']
[307, 377, 135, 238]
[290, 311, 129, 171]
[557, 573, 232, 255]
[240, 261, 159, 215]
...
**** Detection finished

Total time: ... s
Total energy: ... J
```

## Build the bitstream and weights from scratch

In this work, the SkyNet FPGA implementation is written in C code.
To deploy the SkyNet on FPGA, we go through three major steps:

1. **Vivado HLS:** the C code is synthesized by Vivado High Level Synthesis (HLS) tool to generate RTL (Verilog code) code, and exported as an HLS IP.
2. **Vivado:** the exported Verilog code is synthesized by Vivado to generate bitstream for FPGA configuration.
3. **Host:** upload the generated bitstream file (.bit), the hardware description file (.hwh), and the weight file (.bin) generated by Vivado HLS to FPGA, and finish the host code running in the embedded ARM core (in Python or C).


### 1. Vivado HLS
The C source code of SkyNet can be found in ./FPGA/HLS/ folder.
There are typically four steps:

1. C code simulation
2. C code synthesis
3. C and Verilog co-simulation
4. Export RTL (Verilog/VHDL)

You may go through the Vivado HLS flow by running:
```
$ cd ./FPGA/HLS/
$ vivado_hls -f script.tcl
```

The C code simulation takes roughly 20 minutes;
the C code synthesis takes roughly 40 minutes;
the C and Verilog co-simulation takes hours so it is commented in this script;
the RTL exportation takes 2 minutes.
You may comment/uncomment the corresponding commands in script.tcl based on your necessity.

The output of this step is an exported HLS IP, written in Verilog.

### 2. Vivado
In this step we integrate the generated HLS IP into the whole system, and generate the bitstream (.bit) and the hardware configuration file (.hwh).

You may go through the Vivado flow by running:
```
$ cd ./FPGA/RTL/
$ vivado -mode batch -source script.tcl -tclargs SkyNet . ../HLS/
```

In this configuration, the Zynq processor works under 300MHz.
Two high performance AXI buses from Zynq are connected to the m_axi ports of HLS IP, INPUT and OUTPUT respectively.
(After running this script, the generation of bitstream (.bit) is not completed even though the script shows to be terminated. It takes 40 minutes to an hour for bitstream generation, and you may observe the progress in vivado GUI.)


### 3. Host
After generating the bitstream, the final step is to finish the host code running in the processing system, in this case the embedded ARM core. Usually it is written in C, but in Ultra96 and Pynq Series, it allows us to write in Python. In this example we use Python.

First, find the following three files to upload to the board (default name and path):

1. **SkyNet_wrapper.bit** ($Path\_To\_Your\_RTL\_Project/$Project\_Name/$Project\_Name.runs/impl\_1)
2. **SkyNet.hwh** ($Path\_To\_Your\_RTL\_Project/$Project\_Name/$Project\_Name.srcs/sources\_1/bd/design\_1/hw\_handoff)
3. **weights_fixed.bin**, generated by Vivado HLS after reordering and transforming to fixed point ($Path\_to\_your\_HLS\_project/$Project\_name/solution1/csim/build)

Remember to rename the .bit and .hwh file to SkyNet.bit and SkyNet.hwh, or anything but need to be the same.

Second, in the Python host file, allocate memory for weights, off-chip buffers, load parameters, download the overlay (.bit) to program the FPGA logic and specify the IP addresses. You may refer to the SkyNet.py in the ./FPGA/Deploy. 

You are ready to go, good luck!



---

# References
If you find SkyNet useful, please cite the [SkyNet paper](https://arxiv.org/abs/1906.10327):
```
@article{zhang2019skynet,
  title={SkyNet: A Champion Design for {DAC-SDC} on Low Power Object Detection},
  author={Zhang, Xiaofan and Hao, Cong and Lu, Haoming and Li, Jiachen and Li, Yuhong and Fan, Yuchen and Rupnow, Kyle and Xiong, Jinjun and Huang, Thomas and Shi, Honghui and Hwu, Wen-mei and Chen, Deming},
  journal={arXiv preprint arXiv:1906.10327},
  year={2019}
}
```
More details regarding the SkyNet design motivations and SkyNet FPGA accelerator design can be found in our [ICML'19 workshop paper](https://arxiv.org/abs/1905.08369) and the [DAC'19 paper](https://arxiv.org/abs/1904.04421), respectively.
```
@article{zhang2019bi,
  title={A Bi-Directional Co-Design Approach to Enable Deep Learning on {IoT} Devices},
  author={Zhang, Xiaofan and Hao, Cong and Li, Yuhong and Chen, Yao and Xiong, Jinjun and Hwu, Wen-mei and Chen, Deming},
  journal={arXiv preprint arXiv:1905.08369},
  year={2019}
}
```
```
@inproceedings{hao2019fpga,
  title={{FPGA/DNN} Co-Design: An Efficient Design Methodology for {IoT} Intelligence on the Edge},
  author={Hao, Cong and Zhang, Xiaofan and Li, Yuhong and Huang, Sitao and Xiong, Jinjun and Rupnow, Kyle and Hwu, Wen-mei and Chen, Deming},
  booktitle={Proceedings of the 56th Annual Design Automation Conference},
  pages={206},
  year={2019},
  organization={ACM}
}
```

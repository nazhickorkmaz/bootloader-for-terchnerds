# bootloader-for-terchnerds
A professional 2-stage x86 bootloader written in Assembly, featuring a mini-shell, hardware detection (CPUID), and E820 memory mapping 


 # 16-Bit Legacy Bootloader

A professional-grade, dual-stage bootloader written in **x86 Assembly**. This project demonstrates the low-level transition from BIOS hand-off to a functional Stage 2 shell

## Features
- **Two-Stage Architecture:** A tiny Stage 1 (512 bytes) handles the initial boot, which then loads a more capable Stage 2 from the disk
- **FAT12 Compatibility:** Includes a full BIOS Parameter Block (BPB) to ensure compatibility with various BIOS implementations.
- **System Discovery:** Automatically detects **CPU Vendor ID** (via CPUID) and **Conventional Memory size**
- **Interactive Shell:** A built-in CLI that supports basic commands like `HELP` and `INFO`
- **Robust Disk Loading:** Implements a retry-logic for disk reads to handle potential hardware/emulation hiccups

* `boot.asm`: The Master Boot Record (MBR) - Stage 1
* `stage2.asm`: The extended bootloader logic and Shell - Stage 2
* `Makefile`: Automated build script for NASM and QEMU
* `LICENSE`: MIT License

To compile and test this bootloader, you will need `nasm` and `qemu` installed on your system

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/nazhickorkmaz/bootloader-for-terchnerds.git](https://github.com/nazhickorkmaz/bootloader-for-terchnerds.git)
   cd bootloader-for-terchnerds

enjoy :P

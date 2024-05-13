# CoVeriS: : RISC-V Codesign TutorialS

This repository has the code for the accompanying tutorial series.
- [HW-SW co-design in the RISC-V Ecosystem [Part 1]](https://debjyoti0891.github.io/mlir/part1)
- [HW-SW co-design in the RISC-V Ecosystem [Part 2]: MLIR to LLVM](https://debjyoti0891.github.io/mlir/part2)
- [HW-SW co-design in the RISC-V Ecosystem: Adding custom instructions to LLVM [Part 3]](https://debjyoti0891.github.io/mlir/part3)
- [HW-SW co-design in the RISC-V Ecosystem: Adding custom instructions to Spike [Part 4]](https://debjyoti0891.github.io/mlir/part4)


## External Dependencies
- [llvm-project] : This would be used to define the MLIR passes, adding custom LLVM intrinsics and custom RISC-V instructions support.
- [riscv-opcodes] : This would be used to define the opcodes for the new custom instructions.
- [riscv-isa-sim] : We define the implementation of the custom instruction in this instruction set simulator.

The code has been tested on *Mac Studio [Apple M1 Ultra]*, running *macOS 13.0*.

## Initial repository setup
The external dependencies are setup as git submodules.
```
git clone https://github.com/debjyoti0891/CoVeriS.git
git submodule update --init --recursive
```

## Setup python environment
```
python3.12 -m venv coveris_env
source coveris_env/bin/activate
pip3 install -r requirements.txt
```
## Build LLVM project

This project uses llvm18. We directly apply the [patch](./patches/patch_llvm) to add support for the intrinsics
in the LLVM RISCV backend and MLIR.

```
cd llvm-project
git apply ../patches/patch_llvm

mkdir build
cd build
cmake -G "Unix Makefiles" \
-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;mlir;lld" \
-DCMAKE_BUILD_TYPE=Release \
-DLLVM_ENABLE_ASSERTIONS=On \
-DLLVM_TARGETS_TO_BUILD="RISCV;AArch64;host" \
-DCMAKE_INSTALL_PREFIX=./../llvm_install  \
-DLLVM_INCLUDE_TOOLS=ON   \
-DLLVM_INCLUDE_TESTS=ON   \
-DMLIR_INCLUDE_TESTS=ON   \
-DMLIR_ENABLE_BINDINGS_PYTHON=ON \
-DLLVM_ENABLE_ASSERTIONS=On \
-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
../llvm

make -j
```

To check the availability of the newly defined pass, we can used `mlir-opt`
```shell
> ./bin/mlir-opt --help | grep -i riscv
249:      --convert-arith-to-riscvnn                             -   Convert math dialect operations to LLVM RISCV intrinsics for NN
```

To try an example of lowering, we can use the [Makefile](./examples/Makefile). Edit the variables at the top to
point to the right directories.

```
cd examples
make lower TARGET=benchmark
```
This lowers the `benchmark.mlir` into the equivalent MLIR in LLVM dialect.

## Build RISC-V ISA Simulator (Spike)
We directly apply the [patch](./patches/patch_riscv_isa_sim) to add support for the new instructions in the simulator.
We call the extension (`xnn`), which would be referenced when we specify the architecture string during simulation.

```
cd riscv-isa-sim
git apply ../patches/patch_riscv_isa_sim
mkdir build
cd build
../configure
make -j

./spike --help
```


### References
- [RISC-V ISA Sim](https://github.com/riscv-software-src/riscv-isa-sim)

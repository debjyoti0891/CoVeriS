# Variables
LLVM_BUILD_DIR :=  <your directory here>/llvm-project/llvm_install
LLVM_BIN_DIR := $(LLVM_BUILD_DIR)/bin
LLVM_LIB_DIR := $(LLVM_BUILD_DIR)/lib
SPIKE_BUILD := <your directory here>/riscv-isa-sim/build

CC := $(LLVM_BIN_DIR)/clang
LD := $(LLVM_BIN_DIR)/clang
LLC := $(LLVM_BIN_DIR)/llc
OBJDUMP := $(LLVM_BIN_DIR)/llvm-objdump
MLIR_TRANSLATE := $(LLVM_BIN_DIR)/mlir-translate
MLIR_OPT := $(LLVM_BIN_DIR)/mlir-opt
SPIKE := $(SPIKE_BUILD)/spike

DUMP_INST = true

# Flags
SPIKE_FLAGS :=

ifeq ($(DUMP_INST),true)
    SPIKE_FLAGS = --log-commits --log=$(TARGET).log
endif
ASFLAGS := -target riscv64 -march=rv64imaf_xnn -mabi=lp64f

CFLAGS := -target riscv64 -march=rv64imaf -mabi=lp64f -Xclang -target-feature -Xclang +xnn -I/usr/include \
	-mcmodel=medany \
      -fno-builtin-printf -fno-plt -fno-pic -fno-exceptions\
      -fno-stack-protector
LDFLAGS := -L$(LLVM_LIB_DIR) -Wl,-rpath,$(LLVM_LIB_DIR)

MLIR_TRANSLATE_FLAGS := -mlir-to-llvmir -split-input-file -verify-diagnostics

# Targets
TARGET := my_program
SRC := test.c
OBJ := $(SRC:.c=.o)

# Rules
all: $(TARGET)
.PRECIOUS: %.bc %.ll %.elf %.s



# # Apply the target-specific variable to override the pattern rule
# extension_override: ; @true
lower: $(TARGET).mlir
	$(MLIR_OPT) -pass-pipeline="builtin.module(func.func(convert-arith-to-riscvnn,convert-arith-to-llvm,convert-math-to-llvm),convert-func-to-llvm,convert-vector-to-llvm)" $< > $(TARGET)_llvm.mlir

%.ll: %.mlir
		$(MLIR_TRANSLATE) $(MLIR_TRANSLATE_FLAGS)  $< -o $@

%.ll: %.c
		$(CC) $(CFLAGS) -emit-llvm  -c -S $< -o $@

%.s: %.ll
		$(LLC) -march=riscv64 -mattr=+f,+xnn -target-abi=lp64 -O2 -filetype=asm  $< -o $@

# CFLAGS_N = -target riscv64-unknown-elf -march=rv64imafdc_xnn -mabi=lp64f -nostdlib -ffreestanding -fno-builtin -O2
# LDFLAGS_N = -target riscv64-unknown-elf -nostdlib -ffreestanding -fno-builtin -O2

%.o: %.s
	$(CC) $(ASFLAGS) -I./ -I./common -c $< -o $@
# https://www.mobilefish.com/developer/riscv/riscv_quickguide_build_riscv_gnu_toolchain.html
# https://stackoverflow.com/questions/68580399/using-clang-to-compile-for-risc-v
# https://stackoverflow.com/questions/31390127/how-can-i-compile-c-code-to-get-a-bare-metal-skeleton-of-a-minimal-risc-v-assemb

spike_lib.a: common/lib.o common/macro.o     common/regs.o     common/startup.o  common/syscalls.o common/trap.o
	$(LLVM_BIN_DIR)/llvm-ar rcv $@ $^
	$(LLVM_BIN_DIR)/llvm-ranlib $@

%.elf: %.s spike_lib.a common/riscv.ld

	$(CC) -target riscv64-unknown-elf \
		-march=rv64imaf_xnn -mabi=lp64f \
		-static \
		-Tcommon/riscv.ld \
		-nostdlib -nostartfiles \
		--sysroot="/Users/Shared/bhatta53/homebrew/opt/riscv-gnu-toolchain/riscv64-unknown-elf/" --gcc-toolchain="/Users/Shared/bhatta53/homebrew/opt/riscv-gnu-toolchain/"  \
		$(filter-out %.ld,$^) -o $@

%.objdump: %.elf
		$(OBJDUMP) --mattr=+xnn,+f -S $< > $@

%.objdump: %.o
		$(OBJDUMP) --mattr=+xnn,+f -S $< > $@
%.o: %.c
		$(CC) $(CFLAGS) -c  $< -o $@

run: $(TARGET).elf
	$(SPIKE) --isa=rv64gc_xnn $(SPIKE_FLAGS) $(TARGET).elf


clean:
		rm -f $(OBJ) $(TARGET) *.ll *.s *.objdump *.bc *.o *.elf spike_lib.a common/*.o

distclean: clean
	rm -f *.log


.PHONY: all clean extension_override distclean

include Makefile.course

# Optional assembler tools, not needed by the weekly checked-in test vectors.
CROSS ?= riscv64-unknown-elf-
PROGRAM ?= arithmetic
.PHONY: program clean
program:
	mkdir -p build/programs
	$(CROSS)gcc -march=rv32i -mabi=ilp32 -nostdlib -Wl,-T,programs/linker.ld -o build/programs/$(PROGRAM).elf programs/$(PROGRAM).S
	$(CROSS)objcopy -O binary build/programs/$(PROGRAM).elf build/programs/$(PROGRAM).bin
	$(PYTHON) scripts/bin_to_mem.py build/programs/$(PROGRAM).bin build/programs/$(PROGRAM).hex --format words --depth 256
clean:
	$(PYTHON) -c "import pathlib,shutil; p=pathlib.Path('build'); shutil.rmtree(p) if p.is_dir() else None"

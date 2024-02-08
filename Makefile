# Verilator Target
VFLAGS = -O3 --x-assign fast --x-initial fast --noassert
SDL_CFLAGS = `sdl2-config --cflags`
SDL_LDFLAGS = `sdl2-config --libs`


top: Vtop.mk
	make -C ./obj_dir -f $<


Vtop.mk: ./src/isa.sv \
         ./src/core/core_alu.sv \
         ./src/core/core_control.sv \
         ./src/core/core.sv \
         ./src/grid.sv \
         ./src/control.sv \
         ./targets/verilator/verilator.sv
	verilator ${VFLAGS} \
		-cc $^ --exe ./targets/verilator/main.cc \
		             ./targets/verilator/sdl.cc \
		             ./targets/verilator/simulation.cc \
		-o $(basename $@) \
		-CFLAGS "${SDL_CFLAGS}" \
		-LDFLAGS "${SDL_LDFLAGS}" \
		-top-module top --threads 8


simulation: top

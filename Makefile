# Verilator Target
VFLAGS = -O3 --x-assign fast --x-initial fast --noassert
SDL_CFLAGS = `sdl2-config --cflags`
SDL_LDFLAGS = `sdl2-config --libs`

top: Vtop.mk
	make -C ./obj_dir -f $<

Vtop.mk: targets/verilator/verilator.sv
	verilator ${VFLAGS} -I./src\
		-cc $< --exe ./targets/verilator/main.cc \
		             ./targets/verilator/sdl.cc \
		             ./targets/verilator/simulation.cc -o $(basename $@) \
		-CFLAGS "${SDL_CFLAGS}" -LDFLAGS "${SDL_LDFLAGS}" -top-module top --threads 8
simulation: top

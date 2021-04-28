# Make sure that wasm and wlink are available in the path. Otherwise this make script will fail.

all: vsb_qemm.com

vsb_qemm.com:
	wasm vsb_qemm.asm
	wlink sys dos com file vsb_qemm.o

clean:
	rm -f vsb_qemm.o
	rm -f vsb_qemm.com

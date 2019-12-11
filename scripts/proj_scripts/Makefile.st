build=Debug

all:
	bear make -C $(build) -j12 all

flags:
	make -C $(build)

clean:
	cd Debug && rm -rf *.bin *.elf *.hex

.PHONY: all clean

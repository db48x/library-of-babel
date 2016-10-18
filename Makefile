include $(wildcard *.deps)

library.png: library.scad
	openscad -m make -o $@ -d $@.deps --camera 1.90,4.72,5.65,38.90,0.00,338.10,292.71 --projection=o --render --imgsize=1920,1080 --colorscheme="Tomorrow Night" $^

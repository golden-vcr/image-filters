all: ./bin/linux/imf

./opencv-linux/lib/libopencv_core.a:
	./install-opencv.sh

./obj/%.o: ./opencv-linux/lib/libopencv_core.a ./src/%.cpp
	mkdir -p ./obj
	$(CXX) \
		-c \
		-I./include \
		-I./opencv-linux/include/opencv4 \
		-o $@ \
		./src/$(basename $(notdir $@)).cpp

./lib/linux/image-filters.a: ./obj/remove_background.o
	mkdir -p $(dir $@)
	./link-linux-lib.sh $@ | $(AR) -M

./bin/linux/imf: ./obj/main.o ./lib/linux/image-filters.a
	mkdir -p $(dir $@)
	$(CXX) \
		./obj/main.o \
		-I./include \
		-L./lib/linux \
		-l:image-filters.a \
		-o $@

clean:
	rm -rf ./bin
	rm -rf ./lib
	rm -rf ./obj

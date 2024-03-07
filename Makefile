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
	(echo CREATE $@; \
	 echo ADDMOD ./obj/remove_background.o; \
	 echo ADDLIB ./opencv-linux/lib/opencv4/3rdparty/libIlmImf.a; \
	 echo ADDLIB ./opencv-linux/lib/opencv4/3rdparty/libippicv.a; \
	 echo ADDLIB ./opencv-linux/lib/opencv4/3rdparty/libippiw.a; \
	 echo ADDLIB ./opencv-linux/lib/opencv4/3rdparty/libittnotify.a; \
	 echo ADDLIB ./opencv-linux/lib/opencv4/3rdparty/liblibjpeg-turbo.a; \
	 echo ADDLIB ./opencv-linux/lib/opencv4/3rdparty/liblibopenjp2.a; \
	 echo ADDLIB ./opencv-linux/lib/opencv4/3rdparty/liblibpng.a; \
	 echo ADDLIB ./opencv-linux/lib/opencv4/3rdparty/liblibtiff.a; \
	 echo ADDLIB ./opencv-linux/lib/opencv4/3rdparty/liblibwebp.a; \
	 echo ADDLIB ./opencv-linux/lib/opencv4/3rdparty/libzlib.a; \
	 echo ADDLIB ./opencv-linux/lib/libopencv_core.a; \
	 echo ADDLIB ./opencv-linux/lib/libopencv_imgcodecs.a; \
	 echo ADDLIB ./opencv-linux/lib/libopencv_imgproc.a; \
	 echo SAVE; \
	 echo END; \
	) | $(AR) -M	

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

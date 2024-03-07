all: ./bin/linux/imf

./obj/%.o: ./src/%.cpp
	mkdir -p ./obj
	$(CXX) -I./include -c -o $@ ./src/$(basename $(notdir $@)).cpp

./lib/linux/image-filters.a: ./obj/remove_background.o
	mkdir -p $(dir $@)
	ar rvs $@ ./obj/remove_background.o

./bin/linux/imf: ./obj/main.o ./lib/linux/image-filters.a
	mkdir -p $(dir $@)
	$(CXX) ./obj/main.o -I./include -L./lib/linux -l:image-filters.a -o $@

clean:
	rm -rf ./bin
	rm -rf ./lib
	rm -rf ./obj

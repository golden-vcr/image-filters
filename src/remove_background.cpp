#include "image-filters.h"

#include "opencv2/imgcodecs.hpp"
#include "opencv2/imgproc.hpp"

#include <cstdio>

void imf_remove_background()
{
	static const cv::Mat m;
	
	printf("Address of static cv::Mat is %p.\n", &m);
	printf("Background removed, I guess.\n");
}

#include "image-filters.h"

#include "opencv2/imgcodecs.hpp"
#include "opencv2/imgproc.hpp"

#include <stdio.h>
#include <string.h>
#include <vector>

#define min(x, y) (x < y ? x : y)

static cv::Scalar sample_color(const cv::Mat& im, const cv::Rect& rect)
{
	const cv::Mat corner = im(rect);
	return cv::mean(corner);
}

static bool accept_corner(const cv::Scalar& sample, const cv::Scalar& a, const cv::Scalar& b, const cv::Scalar& c)
{
	static const float dist_sq_threshold = 500.0f;

	int num_similar = 0;
	for (int i = 0; i < 3; i++)
	{
		const cv::Scalar& other = i == 0 ? a : (i == 1 ? b : c);
		const cv::Scalar d = other - sample;
		const float dist_sq = d[0] * d[0] + d[1] * d[1] + d[2] * d[2];
		if (dist_sq < dist_sq_threshold)
		{
			num_similar++;
		}
	}
	return num_similar > 1;
}

static cv::Scalar compute_background_color(const cv::Mat& im)
{
	// Compute a size for the sample we want to take from each corner
	const cv::Size size = im.size();
	const int s = min(size.width, size.height) / 32;

	// Build four crop regions, one for each corner
	const cv::Rect top_left(0, 0, s, s);
	const cv::Rect bottom_left(0, size.height - s, s, s);
	const cv::Rect top_right(size.width - s, 0, s, s);
	const cv::Rect bottom_right(size.width - s, size.height - s, s, s);

	// Compute the average color of each of those corners
	const cv::Scalar top_left_color = sample_color(im, top_left);
	const cv::Scalar bottom_left_color = sample_color(im, bottom_left);
	const cv::Scalar top_right_color = sample_color(im, top_right);
	const cv::Scalar bottom_right_color = sample_color(im, bottom_right);

	// Compare our four color corners to each other to determine which of those colors
	// are consistent: this helps us to determine if the background color is present in
	// all corners or if the subject occludes the background in one or more corners
	// (meaning that swatch should be discarded)
	cv::Scalar samples[4];
	int num_samples = 0;
	if (accept_corner(top_left_color, bottom_left_color, top_right_color, bottom_left_color))
	{
		samples[num_samples++] = top_left_color;
	}
	if (accept_corner(bottom_left_color, top_left_color, top_right_color, bottom_left_color))
	{
		samples[num_samples++] = bottom_left_color;
	}
	if (accept_corner(top_right_color, top_left_color, bottom_left_color, bottom_left_color))
	{
		samples[num_samples++] = top_right_color;
	}
	if (accept_corner(bottom_left_color, top_left_color, bottom_left_color, top_right_color))
	{
		samples[num_samples++] = bottom_left_color;
	}

	// If we found no matching colors across all four corners, simply fall back to the
	// average color in the top-left corner
	if (num_samples == 0)
	{
		return top_left_color;
	}

	// Otherwise, we should have two or more colors that are all fairly similar: average
	// those swatches to arrive at a sensible mean that describes our overall background
	// color
	cv::Scalar mean(0.0f, 0.0f, 0.0f, 0.0f);
	for (int i = 0; i < num_samples; i++)
	{
		mean += samples[0];
	}
	mean /= num_samples;
	return mean;
}

void imf_remove_background(const char* infile, const char* outfile, char* out_bgcolor)
{
	// Load our input image
	const cv::Mat im = cv::imread(infile);

	// Compute the mean background color of this image, and write it to the out_bgcolor
	// buffer (assumed to be at least 8 bytes in length) as a hex RGB value
	const cv::Scalar bgcolor = compute_background_color(im);
	sprintf(out_bgcolor, "#%02x%02x%02x", static_cast<int>(bgcolor[2]), static_cast<int>(bgcolor[1]), static_cast<int>(bgcolor[0]));

	// Take an absolute difference to get the absolute value of the difference to the
	// background color for each pixel
	cv::Mat diff;
	cv::absdiff(im, bgcolor, diff);

	// Blur the image slightly to filter out surface noise
	cv::GaussianBlur(diff, diff, cv::Size(7, 7), 0);

	// Convert the image to grayscale so we're only dealing with a single channel
	cv::Mat mask;
	cv::cvtColor(diff, mask, cv::COLOR_BGR2GRAY);

	// Crunch the blacks so that any regions that are similar enough to the background
	// color get clipped at zero, then blow out the whites to ensure that all other
	// parts of the image (i.e. the subject) quickly reach full intensity
	mask -= 22;
	mask *= 96;

	// Create a copy of our mask, expand it a bit, then blur it to create a soft glow
	cv::Mat mask_glow;
	const cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(3, 3));
	const cv::Point anchor(-1, -1);
	cv::dilate(mask, mask_glow, kernel, anchor, 5);
	cv::GaussianBlur(mask_glow, mask_glow, cv::Size(107, 107), 0);

	// Combine the outer glow with our original mask
	mask_glow /= 2;
	mask += mask_glow;

	// Append the mask as an alpha channel for the original RGB image, giving us a
	// result image with a transparent background
	cv::Mat channels[4];
	cv::split(im, channels);
	channels[3] = mask;
	cv::Mat result;
	cv::merge(channels, 4, result);

	// Write the output file and exit successfully
	std::vector<int> params;
	const char* ext = strrchr(outfile, '.');
	if (ext != nullptr)
	{
		if (strcmp(ext, ".jpg") == 0 || strcmp(ext, ".jpeg") == 0)
		{
			params.push_back(cv::IMWRITE_JPEG_QUALITY);
			params.push_back(70);
		}
		else if (strcmp(ext, ".png") == 0)
		{
			params.push_back(cv::IMWRITE_PNG_COMPRESSION);
			params.push_back(4);
		}
		else if (strcmp(ext, ".webp") == 0) 
		{
			params.push_back(cv::IMWRITE_WEBP_QUALITY);
			params.push_back(70);			
		}
	}
	cv::imwrite(outfile, result, params);
}

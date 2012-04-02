/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <ApplicationServices/ApplicationServices.h>
#include <stdlib.h>
#include <time.h>
#include "qcms.h"
#include "lcms2.h"
#include <cairo.h>

#define BITMAP_INFO (kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast)

int main(int argc, char **argv)
{
  if (argc != 6) {
    printf("USAGE: INPUT_ICC OUTPUT_ICC IN_IMG OUT_IMG CMS_ID\n");
    printf("CMS_ID: 0=qcms\n");
    printf("CMS_ID: 1=lcms\n");
    return -1;
  }

	char *input_path = argv[1];
	char *output_path = argv[2];
	char *input_image = argv[3];
	char *output_image = argv[4];
	int cms = atoi(argv[5]);

	cairo_surface_t *s = cairo_image_surface_create_from_png(input_image);

  qcms_profile *input_profile, *output_profile;
  cmsHPROFILE linput_profile, loutput_profile;
  cmsHTRANSFORM transformFixed;

  CGColorSpaceRef cg_output_profile, cg_input_profile;

  clock_t cms_start = clock();
  if (cms == 0) {
	  qcms_enable_iccv4();
	  input_profile = qcms_profile_from_path(input_path);
	  output_profile = qcms_profile_from_path(output_path);
    if (!input_profile) {
      printf("Could not parse in_profile '%s'\n", input_path);
      return -1;
    }
    if (!output_profile) {
      printf("Could not parse output_profile '%s'\n", output_path);
      return -1;
    }
	  qcms_profile_precache_output_transform(output_profile);
  } else if (cms == 1) {
    linput_profile = cmsOpenProfileFromFile(input_path, "r");
    loutput_profile = cmsOpenProfileFromFile(output_path, "r");
  } else if (cms == 2) {
    CGDataProviderRef input_file = CGDataProviderCreateWithFilename(input_path);
    CGDataProviderRef output_file = CGDataProviderCreateWithFilename(output_path);
    CGFloat range[] = {0, 1., 0, 1., 0, 1.};
    cg_output_profile = CGColorSpaceCreateICCBased(3, range, output_file, NULL);
    cg_input_profile = CGColorSpaceCreateICCBased(3, range, input_file, NULL);
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    if( !cg_output_profile || !cg_output_profile ) {
      printf("Could not create CGColorSpace");
      return -1;
    }
  } else {
    printf("cms type not supported");
    return -1;
  }

	unsigned char *data = cairo_image_surface_get_data(s);
  int width = cairo_image_surface_get_stride(s);
  int height = cairo_image_surface_get_height(s);
	int length = cairo_image_surface_get_height(s) * cairo_image_surface_get_stride(s);
  unsigned char *temp = malloc(length*4);
  int i = 0;
  for (i=0; i<length; i+=4) {
     // A R G B
     // B G R A - > R G B A
     unsigned char a, b, r, g;
     b = data[i];
     g = data[i+1];
     r = data[i+2];
     a = data[i+3];
     temp[i] = r;
     temp[i+1] = g;
     temp[i+2] = b;
     temp[i+3] = a;
  }

	CGDataProviderRef dp;
  CGImageRef ref;
  CGContextRef cin, cout;
  CGRect rect = {{0,0},{width, height}};

  if (cms == 2) {
    dp = CGDataProviderCreateWithData(NULL, temp, height * width * 4, NULL);
    ref = CGImageCreate(width, height, 8, 32, width * 4, cg_input_profile,
                        BITMAP_INFO, dp, NULL, 1, kCGRenderingIntentDefault);
    if( !ref ) {
      printf("CGImageCreate failed\n");
      return -1;
    }
    cin = CGBitmapContextCreate(NULL, width, height,
      8, 4*width, cg_input_profile, BITMAP_INFO);
    cout = CGBitmapContextCreate(temp, width, height,
      8, 4*width, cg_output_profile, BITMAP_INFO);
  }


  if (cms == 0) {
	  qcms_transform *transform = qcms_transform_create(input_profile, QCMS_DATA_RGBA_8,
                                                      output_profile, QCMS_DATA_RGBA_8,
                                                      QCMS_INTENT_PERCEPTUAL);
    if (!transform) {
      printf("qcms_transform_create failed");
      return -1;
    }
	  qcms_transform_data(transform, temp, temp, length/4);
  } else if (cms == 1) {
    int flags = 0;
    transformFixed = cmsCreateTransform(
      linput_profile, TYPE_RGBA_8,
      loutput_profile, TYPE_RGBA_8,
      INTENT_RELATIVE_COLORIMETRIC, flags);
    cmsDoTransform(transformFixed, temp, temp, length/4);
  } else if (cms == 2) {
    CGContextDrawImage(cout, rect, ref);
  }

  clock_t cms_time = clock() - cms_start;
	printf("transform-time: %ld\n", cms_time);

  for (i=0; i<length; i+=4) {
     // A R G B
     // B G R A
     unsigned char a, b, r, g;
     b = temp[i];
     g = temp[i+1];
     r = temp[i+2];
     a = temp[i+3];
     data[i] = r;
     data[i+1] = g;
     data[i+2] = b;
     data[i+3] = a;
  }

	cairo_surface_write_to_png(s, output_image);

  if (cms == 0) {
	  qcms_profile_release(input_profile);
	  qcms_profile_release(output_profile);
  }

	return 0;
}

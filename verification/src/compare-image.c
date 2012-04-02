/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <stdlib.h>
#include <time.h>
#include "qcms.h"
#include "lcms2.h"
#include <cairo.h>

#define USE_LCMS

int main(int argc, char **argv)
{
  if (argc != 3) {
    printf("USAGE: IMG1 IMG2\n");
    return -1;
  }

	char *img1 = argv[1];
	char *img2 = argv[2];

	cairo_surface_t *s1 = cairo_image_surface_create_from_png(img1);
	cairo_surface_t *s2 = cairo_image_surface_create_from_png(img2);

  if (cairo_image_surface_get_height(s1) != cairo_image_surface_get_height(s2) ||
      cairo_image_surface_get_stride(s1) != cairo_image_surface_get_stride(s2)) {
    printf("the images do not have the same dimensions (%i, %i) vs (%i, %i)\n",
        cairo_image_surface_get_stride(s1), cairo_image_surface_get_height(s1),
        cairo_image_surface_get_stride(s2), cairo_image_surface_get_height(s2));
  }

	unsigned char *data1 = cairo_image_surface_get_data(s1);
	unsigned char *data2 = cairo_image_surface_get_data(s2);
	int length = cairo_image_surface_get_height(s1) * cairo_image_surface_get_stride(s2);
  int w = cairo_image_surface_get_stride(s2);
  int i = 0;

  unsigned long long totalDiff = 0;
  for (i=0; i<length; i+=4) {
    int diff = abs(data1[i] - data2[i]) + abs(data1[i+1] - data2[i+1]) +
                abs(data1[i+2] - data2[i+2]);
    totalDiff += diff;
    if (diff != 0) {
      int x = (i % w) / 4;
      int y = (i / w);
      printf("Diff: %05i x: %i y: %i r1: %i g1: %i b1: %i r2: %i g2: %i b2: %i\n",
             diff, x, y, data1[i+2], data1[i+1], data1[i+0], data2[i+2], data2[i+1], data2[i+0]);
    }
  }

  printf("Total: %llu\n", totalDiff);

	return 0;
}

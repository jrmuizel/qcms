#OPT_FLAGS=-O2
CAIRO_CFLAGS=`pkg-config --cflags cairo`
CAIRO_LDFLAGS=`pkg-config --libs cairo`

LDFLAGS= -Wl,-framework,ApplicationServices -ldl `pkg-config --libs lcms2`
CFLAGS=-g -I../ $(OPT_FLAGS)

SRC_DIR=./src
OBJ_DIR=./obj
QCMS_LIB=-L.. -lqcms
BIN_DIR=.

all: colorsync-perf transform-image

transform-image: $(SRC_DIR)/transform-image.c ../libqcms.a
	$(CC) $(CFLAGS) $(QCMS_LIB) $(CAIRO_CFLAGS) -o $(BIN_DIR)/$@ $< $(LDFLAGS) $(CAIRO_LDFLAGS) $

compare-image: $(SRC_DIR)/compare-image.c ../libqcms.a
	$(CC) $(CFLAGS) $(QCMS_LIB) $(CAIRO_CFLAGS) -o $(BIN_DIR)/$@ $< $(LDFLAGS) $(CAIRO_LDFLAGS) $

colorsync-perf: $(QCMS_OBJS)

clean:
	rm -rf $(BIN_DIR)/transform*

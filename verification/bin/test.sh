#!/bin/bash
rm -rf ./tmp
mkdir tmp
cp -R profiles tmp/
cp images/1.png tmp/transform.png
cp images/Upper_Left.png tmp/transform2.png
cp images/Upper_Right.png tmp/transform3.png

#v2
./bin/verify.sh profiles/sRGB.icc profiles/sRGB.icc transform.png pic00 "Identity" v2 2> /dev/null
./bin/verify.sh profiles/sRGBCannon2.icc profiles/sRGBCannon3.icc transform.png pic01 "TRC Curve" v2 2> /dev/null

#clut
./bin/verify.sh profiles/clut_only.icc profiles/sRGB.icc transform.png pic21 "in" clut 2> /dev/null
./bin/verify.sh profiles/sRGB.icc profiles/clut_only.icc transform.png pic23 "out" clut 2> /dev/null
./bin/verify.sh profiles/clut_rgb_table.icc profiles/sRGB.icc transform.png pic26 "With TRC (lcms is likely using TRC)" clut 2> /dev/null

#mab
./bin/verify.sh profiles/upperleft.icc profiles/sRGB.icc transform2.png pic31 "M&B Curves -> TRC (UpperLeft)" mab 2> /dev/null
./bin/verify.sh profiles/upperright.icc profiles/sRGB.icc transform3.png pic32 "A&M&B Curves -> TRC (UpperRight)" mab 2> /dev/null
./bin/verify.sh profiles/sRGB_v4_ICC_preference.icc profiles/sRGB.icc transform.png pic33 "A&M&B Curves -> TRC, Color space profile, Parametric Curve" mab 2> /dev/null
./bin/verify.sh profiles/sRGB.icc profiles/upperleft.icc transform.png pic34 "TRC -> M&B Curves" mab 2> /dev/null

#parametric
./bin/verify.sh profiles/aRGBlcms2.icc profiles/sRGB.icc transform.png pic40 "Type 0" param 2> /dev/null
./bin/verify.sh profiles/sRGBlcms2.icc profiles/sRGB.icc transform.png pic41 "Type 3" param 2> /dev/null
./bin/verify.sh profiles/sRGB.icc profiles/aRGBlcms2.icc transform.png pic42 "Type 0 out" param 2> /dev/null
./bin/verify.sh profiles/sRGB.icc profiles/sRGBlcms2.icc transform.png pic43 "Type 3 out" param 2> /dev/null

#pcs
./bin/verify.sh profiles/lab_clut.icc profiles/sRGB.icc transform.png pic60 "LAB->XYZ" pcs 2> /dev/null
./bin/verify.sh profiles/sRGB.icc profiles/lab_clut.icc transform.png pic61 "XYZ->LAB" pcs 2> /dev/null

#negative
./bin/verify.sh profiles/bad.icc profiles/sRGB.icc transform.png pic50 "Bad Profile" negative 2> /dev/null
./bin/verify.sh profiles/graylcms2.icc profiles/sRGB.icc transform.png pic51 "Image-Profile colorspace mismatch" negative 2> /dev/null
./bin/verify.sh profiles/xyzlcms2.icc profiles/sRGB.icc transform2.png pic52 "XYZ Input Color Space" negative 2> /dev/null
./bin/verify.sh profiles/sRGB.icc profiles/upperright.icc transform3.png pic53 "No mBA tag, unlinkable" negative 2> /dev/null
./bin/verify.sh profiles/limitlcms2.icc profiles/sRGB.icc transform.png pic54 "Device Link profile" negative 2> /dev/null
./bin/verify.sh profiles/toosmall.icc profiles/sRGB.icc transform.png pic55 "Too small" negative 2> /dev/null

#bugzilla (488800)
./bin/verify.sh profiles/bugzilla/30.03.09-6500K-22-120cd.icc profiles/sRGB.icc transform.png pic70 "v4 Matrix profile for Acer P243W by LaCie Blue Eye Pro" bugzilla 2> /dev/null
./bin/verify.sh profiles/bugzilla/30.03.09-6500K-22-120cd-lut.icc profiles/sRGB.icc transform.png pic71 "v4 LUT profile for Acer P243W by LaCie Blue Eye Pro" bugzilla 2> /dev/null
./bin/verify.sh profiles/bugzilla/2690_20090319-3.icm profiles/sRGB.icc transform.png pic72 "Nec LCD2690WUXI ICC profile" bugzilla 2> /dev/null
./bin/verify.sh profiles/bugzilla/HP_LP2475w.icc profiles/sRGB.icc transform.png pic73 "Color profile for HP LP2475w wide gamut monitor created with Huey Pro calibrator" bugzilla 2> /dev/null
./bin/verify.sh profiles/bugzilla/hp_lp2475w.icc profiles/sRGB.icc transform.png pic74 "color profile for HP 2475w made by TFTCentral" bugzilla 2> /dev/null
./bin/verify.sh profiles/bugzilla/240PW9.ICM profiles/sRGB.icc transform.png pic75 "Philips 240PW9ES ICC profile" bugzilla 2> /dev/null
./bin/verify.sh profiles/bugzilla/Monitor-09-05-31.icc profiles/sRGB.icc transform.png pic76 "v4 LUT for Dell 2408WFP by Eye-One Match 3 using Eye-One Display 2" bugzilla 2> /dev/null
./bin/verify.sh profiles/bugzilla/HP-LP2475w-Wide-LCD-Monitor.icm profiles/sRGB.icc transform.png pic77 "Profile for HP LP2475w from Spyder2" bugzilla 2> /dev/null


cat ./misc/overview_header.html > ./tmp/overview.html
find tmp -name "*summary.html" | xargs cat >> ./tmp/overview.html
cat ./misc/overview_footer.html >> ./tmp/overview.html

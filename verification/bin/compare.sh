#!/bin/bash
gdb ./transform-image $1 $2 $3 $4_cms0.png 0
./transform-image $1 $2 $3 $4_cms1.png 1
cat misc/result_header.html > $4_result.html
echo "buildCmsSelector('qcms', $4_cms0.png)\n" >> $4_result.html
echo "buildCmsSelector('lcms', $4_cms0.png)\n" >> $4_result.html
cat misc/result_footer.html >> $4_result.html

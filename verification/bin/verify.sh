#!/bin/bash

echo -e "${1##*/} -> ${2##*/}"

cat misc/result_header.html > ./tmp/$4_result.html
echo -e "profile('${1##*/}','$1','${2##*/}','$2');\n" >> ./tmp/$4_result.html

#echo -e "./transform-image $1 $2 ./tmp/$3 ./tmp/$4_cms0.png 0 > ./tmp/log 2>&1"
./transform-image $1 $2 ./tmp/$3 ./tmp/$4_cms0.png 0 > ./tmp/log 2>&1
if [ $? != 0 ]; then
{
  echo -e "addError(\"qcms-param\",\"./transform-image $1 $2 ./tmp/$3 ./tmp/$4_cms0.png 0\");" >> ./tmp/$4_result.html
  cmserr=`cat ./tmp/log | sed -e ';s/\"/\\\"/g' | awk '{printf "%s<br>",$0} END {print ""}'`
  echo -e "addError(\"qcms-out\",\"$cmserr\");" >> ./tmp/$4_result.html
} fi
time1=`cat ./tmp/log | grep transform-time`
echo -e "buildCmsSelector('qcms', '$4_cms0.png');\n" >> ./tmp/$4_result.html
echo -e "time('qcms', '${time1##* }');\n" >> ./tmp/$4_result.html

./transform-image $1 $2 ./tmp/$3 ./tmp/$4_cms1.png 1 > ./tmp/log 2>&1
if [ $? != 0 ]; then
{
  echo -e "addError(\"lcms-param\",\"./transform-image $1 $2 ./tmp/$3 ./tmp/$4_cms1.png 1\");" >> ./tmp/$4_result.html
  cmserr=`cat ./tmp/log | sed -e ';s/\"/\\\"/g' | awk '{printf "%s<br>",$0} END {print ""}'`
  echo -e "addError(\"lcms-out\",\"$cmserr\");" >> ./tmp/$4_result.html
} fi
time2=`cat ./tmp/log | grep transform-time`
echo -e "buildCmsSelector('lcms', '$4_cms1.png');\n" >> ./tmp/$4_result.html
echo -e "time('lcms', '${time2##* }');\n" >> ./tmp/$4_result.html

./transform-image $1 $2 ./tmp/$3 ./tmp/$4_cms2.png 2 > ./tmp/log 2>&1
if [ $? != 0 ]; then
{
  echo -e "addError(\"cs-param\",\"./transform-image $1 $2 ./tmp/$3 ./tmp/$4_cms2.png 2\");" >> ./tmp/$4_result.html
  cmserr=`cat ./tmp/log | sed -e ';s/\"/\\\"/g' | awk '{printf "%s<br>",$0} END {print ""}'`
  echo -e "addError(\"cs-out\",\"$cmserr\");" >> ./tmp/$4_result.html
} fi
time3=`cat ./tmp/log | grep transform-time`
echo -e "buildCmsSelector('cs', '$4_cms2.png');\n" >> ./tmp/$4_result.html
echo -e "time('cs', '${time3##* }');\n" >> ./tmp/$4_result.html

./compare-image ./tmp/$4_cms0.png ./tmp/$4_cms1.png | sort -r | head > ./tmp/diff
totaldifflcms=`cat ./tmp/diff | grep Total`
cat ./tmp/diff | grep Diff | sed 's/^/diff("lcms","/;s/$/");/' >> ./tmp/$4_result.html
./compare-image ./tmp/$4_cms0.png ./tmp/$4_cms2.png | sort -r | head > ./tmp/diff
totaldiffcs=`cat ./tmp/diff | grep Total`
cat ./tmp/diff | grep Diff | sed 's/^/diff("cs","/;s/$/");/' >> ./tmp/$4_result.html
echo -e "cms('$4_cms0.png');\n" >> ./tmp/$4_result.html

echo -e "buildCmsSelector('Orignal', '$3');\n" >> ./tmp/$4_result.html
cat misc/result_footer.html >> ./tmp/$4_result.html

echo -e "addResultRow('${1##*/} -> ${2##*/}','${totaldifflcms##* }','${totaldiffcs##* }','${time1##* }','${time2##* }','${time3##* }','$4_result.html','$5','$6')\n" >> ./tmp/$4_summary.html
#echo -e "<a href=\"$4_result.html\">${1##*/} -> ${2##*/}</a><br>\n" >> ./tmp/$4_summary.html

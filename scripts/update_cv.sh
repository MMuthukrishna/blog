#!/bin/bash
CV_PATH='content/cv'
pdflatex -output-directory $CV_PATH ./$CV_PATH/cv.tex
pdfjam $CV_PATH/cv.pdf 1 -o $CV_PATH/cv-1.pdf
pdfjam $CV_PATH/cv.pdf 2 -o $CV_PATH/cv-2.pdf
pdfjam $CV_PATH/cv-1.pdf $CV_PATH/cv-2.pdf --nup 2x1 --landscape --outfile $CV_PATH/cv-landscape.pdf
rm $CV_PATH/cv-1.pdf
rm $CV_PATH/cv-2.pdf
git add content/cv/cv.tex
git add content/cv/cv.pdf
git add content/cv/cv-landscape.pdf
git commit -m "Update cv"
git push
./scripts/deploy.sh

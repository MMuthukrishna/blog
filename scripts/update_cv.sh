#!/bin/bash
pdflatex -output-directory content/cv ./content/cv/cv.tex
git add content/cv/cv.tex
git add content/cv/cv.pdf
git commit -m "Update cv"
git push
./scripts/deploy.sh

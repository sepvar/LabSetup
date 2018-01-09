# Lab Manual and Set-up Instructions

default: 
	@echo "make -n ... to display commands with running"
	@echo "make -s ... to not display commands when running them"
	@echo "Choices: setup-h, setup-l, images, list (prints copy-paste select image creation), counterr, toperr, typeerr, allerr"
	@echo "make all will make all html, all latex, and images"

git: 
	git diff-index --stat master

view: 
	/c/Program\ Files/Mozilla\ Firefox/firefox.exe TMC-lab-setup.html > /dev/null &

src/mathbook-setup-latex.xsl: 
	git diff-index --name-only master | grep src/mathbook-setup-latex.xsl && git diff-index --stat master 

src/mathbook-setup-html.xsl: 
	git diff-index --name-only master | grep src/mathbook-setup-html.xsl && git diff-index --stat master

src/Lab-setup.ptx:
	git diff-index --name-only master | grep src/Lab-setup.ptx && git diff-index --stat master


${BEE}/user/mathbook-setup-latex.xsl: src/mathbook-setup-latex.xsl
	cp src/mathbook-setup-latex.xsl ${BEE}/user/

${BEE}/user/mathbook-setup-html.xsl: src/mathbook-setup-html.xsl
	cp src/mathbook-setup-html.xsl ${BEE}/user/

setup-h: ${BEE}/user/mathbook-setup-html.xsl src/Lab-setup.ptx 
	xsltproc ${BEE}/user/mathbook-setup-html.xsl src/Lab-setup.ptx

setup-l: ${BEE}/user/mathbook-setup-latex.xsl src/Lab-setup.ptx 
	xsltproc ${BEE}/user/mathbook-setup-latex.xsl src/Lab-setup.ptx

setup-p: setup-l
	pdflatex TMC-lab-setup.tex && pdflatex TMC-lab-setup.tex || pdflatex TMC-lab-setup.tex

setup: setup-h setup-p


html: setup-h 

latex: setup-l 

pdf: setup-p

images: src/Lab-setup.ptx
#	${BEE}/script/mbx -v -c latex-image -r [specific image reference] -f svg -d images ${PWD}/src/Lab-setup.ptx
	${BEE}/script/mbx -v -c latex-image -f svg -d images ${PWD}/src/Lab-setup.ptx


# To list the images in the ptx and print a line that will check to see if that image exists and (if not) try to create the image...

list: src/Lab-setup.ptx
	cat src/Lab-setup.ptx | \
		sed 's/^ *<image/<image/g' | \
		grep '<image' | grep -v "images" | \
		sed 's/ width=.*>/>/g' | \
		sed 's+^.*ptx:id=\"\(.*\)\">+ls images/\1.svg || C:/Users/tensen/Desktop/Book/mathbook/script/mbx \-v \-c latex-image \-r \1 \-f svg \-d images ${PWD}/src/Lab-setup.ptx+g'

counterr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.ptx
	@echo `java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.ptx | wc -l`" errors"

toperr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.ptx
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.ptx | head -5

typeerr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.ptx
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.ptx | \
		sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\): error: element "\([a-zA-Z][a-zA-Z]*\)".*/\3 line \1:\2/g' | \
		sort -k1

# To find the errors on "todo"  (must change in two places)                                                vvvv                                                 vvvv
# 	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.ptx | grep ": element \"todo" | sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\):.*/todo line \1:\2/g'
#                                                                                                          ^^^^                                                 ^^^^

allerr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.ptx
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.ptx | \
		sort -k4  

all: setup-h setup-l images

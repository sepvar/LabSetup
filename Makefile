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

src/Lab-setup.xml:
	git diff-index --name-only master | grep src/Lab-setup.xml && git diff-index --stat master


${BEE}/user/mathbook-setup-latex.xsl: src/mathbook-setup-latex.xsl
	cp src/mathbook-setup-latex.xsl ${BEE}/user/

${BEE}/user/mathbook-setup-html.xsl: src/mathbook-setup-html.xsl
	cp src/mathbook-setup-html.xsl ${BEE}/user/

setup-h: ${BEE}/user/mathbook-setup-html.xsl src/Lab-setup.xml 
	xsltproc ${BEE}/user/mathbook-setup-html.xsl src/Lab-setup.xml

setup-l: ${BEE}/user/mathbook-setup-latex.xsl src/Lab-setup.xml 
	xsltproc ${BEE}/user/mathbook-setup-latex.xsl src/Lab-setup.xml

setup-p: setup-l
	pdflatex TMC-lab-setup.tex && pdflatex TMC-lab-setup.tex || pdflatex TMC-lab-setup.tex

setup: setup-h setup-p


html: setup-h 

latex: setup-l 

pdf: setup-p

images: src/Lab-setup.xml
#	${BEE}/script/mbx -v -c latex-image -r [specific image reference] -f svg -d images ${PWD}/src/Lab-setup.xml
	${BEE}/script/mbx -v -c latex-image -f svg -d images ${PWD}/src/Lab-setup.xml


# To list the images in the xml and print a line that will check to see if that image exists and (if not) try to create the image...

list: src/Lab-setup.xml
	cat src/Lab-setup.xml | \
		sed 's/^ *<image/<image/g' | \
		grep '<image' | grep -v "images" | \
		sed 's/ width=.*>/>/g' | \
		sed 's+^.*xml:id=\"\(.*\)\">+ls images/\1.svg || C:/Users/tensen/Desktop/Book/mathbook/script/mbx \-v \-c latex-image \-r \1 \-f svg \-d images ${PWD}/src/Lab-setup.xml+g'

counterr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.xml
	@echo `java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.xml | wc -l`" errors"

toperr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.xml
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.xml | head -5

typeerr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.xml
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.xml | \
		sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\): error: element "\([a-zA-Z][a-zA-Z]*\)".*/\3 line \1:\2/g' | \
		sort -k1

# To find the errors on "todo"  (must change in two places)                                                vvvv                                                 vvvv
# 	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng 121-Lab-Manual.xml | grep ": element \"todo" | sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\):.*/todo line \1:\2/g'
#                                                                                                          ^^^^                                                 ^^^^

allerr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.xml
	java -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng src/Lab-setup.xml | \
		sort -k4  

all: setup-h setup-l images

.SUFFIXES: .sh .cgi .1 .txt
.PHONY: all clean install
all: wh-labels.cgi wh-labels.cgi.txt
.1.txt:
	nroff -Tascii -mdoc $< | col -bx >$@
.sh.cgi:
	sed "s,@HOME,$$HOME," $< >$@
clean:
	rm -f *.cgi *.cgi.txt
install: wh-labels.cgi
	cp $> $$HOME/html/

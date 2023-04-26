.SUFFIXES: .sh .cgi .1 .txt
.PHONY: all clean install
all: wh.cgi wh.cgi.txt
.1.txt:
	nroff -Tascii -mdoc $< | col -bx >$@
.sh.cgi:
	sed "s,@HOME,$$HOME," $< >$@
clean:
	rm -f *.cgi *.cgi.txt
install: wh.cgi
	cp $> $$HOME/html/

### Makefile		Created      : Sat Feb  8 21:56:05 2003
###			Last modified: Sun Dec 25 10:34:55 2016
OCAMLMAKEFILE=OCamlMakefile
SOURCES1=mytcp.ml url.ml http.ml linkCollecter.ml crawler.ml
#SOURCES2=mytcp.ml url.ml http.ml
SOURCES=$(SOURCES1)
RESULT=crawler
LIBS=str unix

include $(OCAMLMAKEFILE)

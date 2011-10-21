include $(GOROOT)/src/Make.inc

TARG=blas

OFILES_amd64=\
	     double_amd64.$O

OFILES=\
	$(OFILES_$(GOARCH))

ALLGOFILES=\
	   double.go\

NOGOFILES=\
	$(subst _$(GOARCH).$O,.go,$(OFILES_$(GOARCH)))

GOFILES=\
	$(filter-out $(NOGOFILES),$(ALLGOFILES))\
	$(subst .go,_decl.go,$(NOGOFILES))\

include $(GOROOT)/src/Make.pkg

include $(GOROOT)/src/Make.inc

TARG=blas

OFILES_amd64=\
	     ddot_amd64.$O\
	     dnrm2_amd64.$O\
	     dasum_amd64.$O\

OFILES=\
	$(OFILES_$(GOARCH))

ALLGOFILES=\
	   sdot.go\
	   ddot.go\
	   dnrm2.go\
	   dasum.go\

NOGOFILES=\
	$(subst _$(GOARCH).$O,.go,$(OFILES_$(GOARCH)))

GOFILES=\
	$(filter-out $(NOGOFILES),$(ALLGOFILES))\
	$(subst .go,_decl.go,$(NOGOFILES))\

include $(GOROOT)/src/Make.pkg

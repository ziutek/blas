include $(GOROOT)/src/Make.inc

GC = $Og -N
TARG=blas

OFILES_amd64=\
	     sdsdot_amd64.$O\
	     sdot_amd64.$O\
	     ddot_amd64.$O\
	     dnrm2_amd64.$O\
	     dasum_amd64.$O\
	     dswap_amd64.$O\

OFILES=\
	$(OFILES_$(GOARCH))

ALLGOFILES=\
	   common.go\
	   sdsdot.go\
	   sdot.go\
	   ddot.go\
	   dnrm2.go\
	   dasum.go\
	   idamax.go\
	   dswap.go\

NOGOFILES=\
	$(subst _$(GOARCH).$O,.go,$(OFILES_$(GOARCH)))

GOFILES=\
	$(filter-out $(NOGOFILES),$(ALLGOFILES))\
	$(subst .go,_decl.go,$(NOGOFILES))\

include $(GOROOT)/src/Make.pkg

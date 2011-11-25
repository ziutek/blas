include $(GOROOT)/src/Make.inc

#GC = $Og -N
GC = $Og -B
TARG=blas

OFILES_amd64=\
	     sdsdot_amd64.$O\
	     sdot_amd64.$O\
	     ddot_amd64.$O\
	     snrm2_amd64.$O\
	     dnrm2_amd64.$O\
	     sasum_amd64.$O\
	     dasum_amd64.$O\
	     isamax_amd64.$O\
	     idamax_amd64.$O\
	     sswap_amd64.$O\
	     dswap_amd64.$O\
	     scopy_amd64.$O\
	     dcopy_amd64.$O\
	     saxpy_amd64.$O\
	     daxpy_amd64.$O\
	     sscal_amd64.$O\
	     dscal_amd64.$O\
	     #drotg_amd64.$O\

OFILES=\
	$(OFILES_$(GOARCH))

ALLGOFILES=\
	   common.go\
	   sdsdot.go\
	   sdot.go\
	   ddot.go\
	   snrm2.go\
	   dnrm2.go\
	   sasum.go\
	   dasum.go\
	   isamax.go\
	   idamax.go\
	   sswap.go\
	   dswap.go\
	   scopy.go\
	   dcopy.go\
	   saxpy.go\
	   daxpy.go\
	   sscal.go\
	   dscal.go\
	   drotg.go\

NOGOFILES=\
	$(subst _$(GOARCH).$O,.go,$(OFILES_$(GOARCH)))

GOFILES=\
	$(filter-out $(NOGOFILES),$(ALLGOFILES))\
	$(subst .go,_decl.go,$(NOGOFILES))\

include $(GOROOT)/src/Make.pkg

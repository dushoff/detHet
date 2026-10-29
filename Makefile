## This is detHet

current: target
-include target.mk
Ignore = target.mk

vim_session:
	bash -ic "vmt"

## -include makestuff/perl.def

######################################################################

Sources += $(wildcard *.md *.R)

## claude.md

######################################################################

## Simulation functions live in RTutorials
pardirs += RTutorials
Ignore += $(pardirs)

## Grant figure: S, I, R and their mean mixing rates (Rnull=1.5, kappa=2, 20 groups)
## hetFig.Rout.pdf: hetFig.R
hetFig.Rout: hetFig.R RTutorials/ICI3D_Heterogeneous_Groups.R makestuff/okabe.R
	$(pipeR)

######################################################################

### Makestuff

Sources += Makefile

Ignore += makestuff
msrepo = https://github.com/dushoff

## ln -s ../makestuff . ## Do this first if you want a linked makestuff
Ignore += makestuff*.stamp
Makefile: makestuff00.stamp
makestuff%.stamp: | makestuff
	- $(RM) makestuff*.stamp
	cd makestuff && $(MAKE) pull
	touch $@
makestuff:
	git clone --depth 1 $(msrepo)/makestuff

-include makestuff/os.mk

-include makestuff/pipeR.mk

-include makestuff/git.mk
-include makestuff/visual.mk

library(shellpipes)
library(deSolve)
library(dplyr)
library(tidyr)
library(ggplot2); theme_set(theme_bw(base_size=8))
library(patchwork)
library(directlabels)

sourceFiles()

Rnull <- 1.5
kappa <- 2
nGroups <- 20
Tfinal <- 10

sim <- groupSim(cbar=Rnull, kappa=kappa, nGroups=nGroups, Tfinal=Tfinal, steps=200)

## cR is 0/0 at the start, and numerically noisy while R is tiny
sim <- mutate(sim, cR = ifelse(R > 1e-6, cR, NA))

print(sim, n=Inf)

long <- (sim
	|> pivot_longer(-time)
	|> mutate(
		class = factor(sub("^c", "", name), levels=c("S", "I", "R"))
		, panel = ifelse(grepl("^c", name), "rate", "prop")
	)
)

## Room on the right for direct labels
xscale <- scale_x_continuous(expand=expansion(mult=c(0.02, 0.1)))

props <- (ggplot(filter(long, panel=="prop"))
	+ aes(time, value, color=class)
	+ geom_line(linewidth=0.6)
	+ xscale
	+ labs(x=NULL, y="Proportion")
	+ theme(legend.position="none", axis.text.x=element_blank())
)

rates <- (ggplot(filter(long, panel=="rate"))
	+ aes(time, value, color=class)
	+ geom_line(linewidth=0.6, na.rm=TRUE)
	+ geom_hline(yintercept=Rnull, linetype="dashed", color="grey50")
	+ annotate("text", x=0, y=Rnull, label="population mean"
		, hjust=0, vjust=-0.4, size=2.2, colour="grey40"
	)
	+ geom_dl(aes(label=class), na.rm=TRUE
		, method=list("last.points", dl.trans(x=x+0.05), "bumpup", cex=0.7)
	)
	+ xscale
	+ labs(x="Time (generations)", y="Mean activity")
	+ theme(legend.position="none")
)

## Sized for one panel of a 7-inch-wide figure; don't rescale in LaTeX
startGraphics(height=2.4, width=1.9)
print(props / rates + plot_layout(heights=c(2, 3)))

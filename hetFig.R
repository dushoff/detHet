library(shellpipes)
library(deSolve)
library(dplyr)
library(tidyr)
library(ggplot2); theme_set(theme_bw(base_size=14))
library(patchwork)

sourceFiles()

Rnull <- 1.5
kappa <- 2
nGroups <- 20
Tfinal <- 12

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

props <- (ggplot(filter(long, panel=="prop"))
	+ aes(time, value, color=class)
	+ geom_line(linewidth=1)
	+ labs(x=NULL, y="Proportion of population", color=NULL)
)

rates <- (ggplot(filter(long, panel=="rate"))
	+ aes(time, value, color=class)
	+ geom_line(linewidth=1, na.rm=TRUE)
	+ geom_hline(yintercept=Rnull, linetype="dashed", color="grey50")
	+ labs(x="Time (generations)", y="Mean mixing rate", color=NULL)
)

startGraphics(height=7, width=6)
print(props / rates + plot_layout(guides="collect"))

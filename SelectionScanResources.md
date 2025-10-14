# Some useful selection scan literature

## Metrics
- Extended haplotype homozygosity (EHH):  Sabeti, P., Reich, D., Higgins, J. et al. Detecting recent positive selection in the human genome from haplotype structure. Nature 419, 832–837 (2002).
   https://doi.org/10.1038/nature01140
    - Kind of the OG paper
- iHS:  Voight BF, Kudaravalli S, Wen X, Pritchard JK (2006) A Map of Recent Positive Selection in the Human Genome. PLoS Biol 4(3): e72. https://doi.org/10.1371/journal.pbio.0040072
    - Intermediate frequency, ongoing hard sweeps 
- Cross population EHH (XPEHH) : Sabeti PC, Varilly P, Fry B, Lohmueller J, Hostetter E, Cotsapas C, Xie X, Byrne EH, McCarroll SA, Gaudet R, et al. Genome-wide detection and characterization of positive selection in human populations.
  Nature. 2007;449(7164):913–918. doi: 10.1038/nature06250
    - Sweeps closer to fixation
- Program to calculate the above and other EHH based metrics like nSL, xpNSL, etc.: https://github.com/szpiech/selscan

## More recent metrics 
- Singleton density score (SDS) : Yair Field et al. ,Detection of human adaptation during the past 2000 years.Science354,760-764(2016).DOI:10.1126/science.aag0776
    - Recent selection, biobank scale whole genome sequencing
- iLDS: Pervasive selective sweeps across human gut microbiomes Richard Wolff, Nandita R. Garud bioRxiv 2023.12.22.573162; doi: https://doi.org/10.1101/2023.12.22.573162
    - Leverages deleterious variation around beneficial sites

## Recent empirical papers
- Johnson, K.E., Voight, B.F. Patterns of shared signatures of recent positive selection across human populations. Nat Ecol Evol 2, 713–720 (2018). https://doi.org/10.1038/s41559-018-0478-6
    - Applied iHS to Phase 3 1KG WGS
    - Looked at patterns of shared sweeps across populations
- Taliun, D., Harris, D.N., Kessler, M.D. et al. Sequencing of 53,831 diverse genomes from the NHLBI TOPMed Program. Nature 590, 290–299 (2021). https://doi.org/10.1038/s41586-021-03205-y
    - Applied SDS to recent TOPMED release 

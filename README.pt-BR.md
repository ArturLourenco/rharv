# rharv

[![R-CMD-check](https://github.com/ArturLourenco/rharv/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ArturLourenco/rharv/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

Português \| [English](https://arturlourenco.github.io/rharv/README.md)

O rharv simula sistemas de aproveitamento de água de chuva com um modelo
de balanço hídrico diário. A partir de uma série diária de chuva, ele
calcula o volume captado, roda o balanço do reservatório dia a dia e
deriva métricas de desempenho (vertimento, déficit, atendimento,
confiabilidade) e valores de dimensionamento por garantia, ou seja, a
demanda constante, a área de captação ou a capacidade do reservatório
que evitam qualquer falha. O dimensionamento fica a cargo do analista: a
simulação diária permite explorar vários valores de projeto em vez de
aplicar uma única fórmula fechada.

## Instalação

``` r

# install.packages("remotes")
remotes::install_github("ArturLourenco/rharv")
```

O núcleo (simulação, métricas, dimensionamento) não tem dependências
pesadas, bastando o R base mais o `rlang`. Os gráficos usam o ggplot2 e
o app usa shiny e bslib, todos sugeridos e não obrigatórios.

## Início rápido

``` r

library(rharv)

# Demanda diária de um campus de 1089 pessoas a 6,03 L/pessoa/dia
demand <- rh_daily_demand(1089, 6.03)

# Simula um reservatório de 400 m3 na série de chuva de Princesa Isabel (inclusa)
sim <- rh_simulate(
  precip = precip_pi$value,
  demand = demand,
  area = sum(areas_pi$area_m2),
  capacity = 400,
  runoff = 0.85, efficiency = 1
)
sim
#> <rharv_sim>
#>   steps: 38716 | area: 4170.097 m2 | capacity: 400 m3 | timing: after_demand
#>   attendance: 69.3% | reliability: 68.5% | days unmet: 12199
#>   totals (m3): deficit 78150.18 | overflow 130953.28 | usable 175685.02

# Maior demanda que garante déficit zero (m3/dia)
rh_guaranteed_demand(precip_pi$value, area = sum(areas_pi$area_m2),
                     capacity = 400, runoff = 0.85, efficiency = 1)
#> [1] 1.8839
```

## O que faz

A função
[`rh_simulate()`](https://arturlourenco.github.io/rharv/reference/rh_simulate.md)
roda o balanço hídrico diário do reservatório (regra de operação YBS ou
YAS) e devolve um objeto `rharv_sim` com métodos
[`print()`](https://rdrr.io/r/base/print.html),
[`summary()`](https://rdrr.io/r/base/summary.html) e `autoplot()`;
[`rh_available_volume()`](https://arturlourenco.github.io/rharv/reference/rh_available_volume.md)
implementa `Vdisp = P * A * C * eta`. As métricas de
[`rh_metrics()`](https://arturlourenco.github.io/rharv/reference/rh_metrics.md)
são vertimento, déficit, volume aproveitável, atendimento volumétrico e
confiabilidade temporal.

O dimensionamento cobre o caso de déficit zero com
[`rh_guaranteed_demand()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md),
[`rh_guaranteed_capacity()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md)
e
[`rh_required_area()`](https://arturlourenco.github.io/rharv/reference/rh_sizing.md),
e qualquer meta de garantia com
[`rh_size_for()`](https://arturlourenco.github.io/rharv/reference/rh_size_for.md);
os solucionadores são bisseção,
[`stats::optimize`](https://rdrr.io/r/stats/optimize.html) e busca
incremental.

Para análise existem as varreduras
[`rh_sweep()`](https://arturlourenco.github.io/rharv/reference/rh_sweep.md)
e
[`rh_grid()`](https://arturlourenco.github.io/rharv/reference/rh_grid.md),
com modo rápido por climatologia, além de
[`rh_guarantee_curve()`](https://arturlourenco.github.io/rharv/reference/rh_guarantee_curve.md),
[`rh_iso_curve()`](https://arturlourenco.github.io/rharv/reference/rh_iso_curve.md),
[`rh_resource_curve()`](https://arturlourenco.github.io/rharv/reference/rh_resource_curve.md),
[`rh_series_spread()`](https://arturlourenco.github.io/rharv/reference/rh_series_spread.md),
[`rh_seasonal_demand()`](https://arturlourenco.github.io/rharv/reference/rh_seasonal_demand.md),
[`rh_scenarios_from_years()`](https://arturlourenco.github.io/rharv/reference/rh_scenarios_from_years.md)
e
[`rh_compare()`](https://arturlourenco.github.io/rharv/reference/rh_compare.md).

Os gráficos incluem a superfície de trade-off com contornos de
iso-garantia
([`rh_plot_tradeoff()`](https://arturlourenco.github.io/rharv/reference/rh_plot_tradeoff.md)),
a comparação de alavancas
([`rh_plot_levers()`](https://arturlourenco.github.io/rharv/reference/rh_plot_levers.md)),
as curvas Storage-Yield-Reliability
([`rh_plot_syr()`](https://arturlourenco.github.io/rharv/reference/rh_plot_syr.md)),
a curva de projeto adimensional
([`rh_plot_design_curve()`](https://arturlourenco.github.io/rharv/reference/rh_plot_design_curve.md)),
as curvas de projeto iso-garantia e recursos contra garantia
([`rh_plot_iso()`](https://arturlourenco.github.io/rharv/reference/rh_plot_iso.md),
[`rh_plot_resource_curve()`](https://arturlourenco.github.io/rharv/reference/rh_plot_resource_curve.md)),
o comportamento do reservatório, o balanço mensal, o calendário de
falhas, o espalhamento da chuva e a matriz de climatologia. O
[`rh_explore()`](https://arturlourenco.github.io/rharv/reference/rh_explore.md)
abre o app Shiny e o
[`rh_demo()`](https://arturlourenco.github.io/rharv/reference/rh_demo.md)
abre o caderno de demonstração comentado.

Veja
[`vignette("ifpb-pi-case-study")`](https://arturlourenco.github.io/rharv/articles/ifpb-pi-case-study.md)
para um exemplo aplicado a um campus real e
[`vignette("analysis-and-sizing")`](https://arturlourenco.github.io/rharv/articles/analysis-and-sizing.md)
para o ferramental de análise.

## Referências

A abordagem de simulação diária foi aplicada a este campus no seguinte
trabalho de evento, antes do lançamento do pacote:

- Silva, R. M. V. da; Lourenço, A. M. G.; Del Grande, M. H.;
  Farias, C. A. S. de; Albuquerque, E. M. de; Araújo, A. O. de (2024).
  *Avaliação do potencial de aproveitamento de água de chuva usando
  técnicas de modelagem hidrológica: estudo de caso do campus IFPB-PI.*
  XVII Simpósio de Recursos Hídricos do Nordeste (XVII SRHNE), João
  Pessoa-PB. ABRHidro.
  \[[artigo](https://github.com/ArturLourenco/rharv/blob/main/paper/XVII-SRHNE-2024-rainwater-harvesting-IFPB-PI.pdf)\]
  \[[apresentação](https://github.com/ArturLourenco/rharv/blob/main/paper/XVII-SRHNE-2024-presentation.pdf)\]

Embasamento:

- Souza, T. J. (2015). *Potencial de aproveitamento de água de chuva no
  meio urbano: o caso de Campina Grande, PB.* UFCG.
- ABNT NBR 15527:2019, *Aproveitamento de água de chuva de coberturas
  para fins não potáveis* (relação do volume disponível e fator de
  eficiência; cancela a edição de 2007 e deixa o dimensionamento do
  reservatório a cargo do projetista).

Para citar o rharv, rode `citation("rharv")`. Um artigo de software
dedicado ao pacote está em preparação (2026).

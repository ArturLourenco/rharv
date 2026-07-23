<!-- README.pt-BR.md: tradução manual; mantenha em sincronia com README.md. -->

# rharv <img src="man/figures/logo.png" align="right" height="139" alt="logo do rharv" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/ArturLourenco/rharv/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ArturLourenco/rharv/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Português | [English](README.md)

O rharv simula sistemas de aproveitamento de água de chuva com um modelo de
balanço hídrico diário. A partir de uma série diária de chuva, ele calcula o
volume captado, roda o balanço do reservatório dia a dia e deriva métricas de
desempenho (vertimento, déficit, atendimento, confiabilidade) e valores de
dimensionamento por garantia, ou seja, a demanda constante, a área de captação
ou a capacidade do reservatório que evitam qualquer falha. O dimensionamento
fica a cargo do analista: a simulação diária permite explorar vários valores de
projeto em vez de aplicar uma única fórmula fechada.

## Instalação

``` r
# install.packages("remotes")
remotes::install_github("ArturLourenco/rharv")
```

O núcleo (simulação, métricas, dimensionamento) não tem dependências pesadas,
bastando o R base mais o `rlang`. Os gráficos usam o ggplot2 e o app usa shiny e
bslib, todos sugeridos e não obrigatórios.

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

A função `rh_simulate()` roda o balanço hídrico diário do reservatório (regra de
operação YBS ou YAS) e devolve um objeto `rharv_sim` com métodos `print()`,
`summary()` e `autoplot()`; `rh_available_volume()` implementa
`Vdisp = P * A * C * eta`. As métricas de `rh_metrics()` são vertimento,
déficit, volume aproveitável, atendimento volumétrico e confiabilidade temporal.

O dimensionamento cobre o caso de déficit zero com `rh_guaranteed_demand()`,
`rh_guaranteed_capacity()` e `rh_required_area()`, e qualquer meta de garantia
com `rh_size_for()`; os solucionadores são bisseção, `stats::optimize` e busca
incremental.

Para análise existem as varreduras `rh_sweep()` e `rh_grid()`, com modo rápido
por climatologia, além de `rh_guarantee_curve()`, `rh_iso_curve()`,
`rh_resource_curve()`, `rh_series_spread()`, `rh_seasonal_demand()`,
`rh_scenarios_from_years()` e `rh_compare()`.

Os gráficos incluem a superfície de trade-off com contornos de iso-garantia
(`rh_plot_tradeoff()`), a comparação de alavancas (`rh_plot_levers()`), as
curvas Storage-Yield-Reliability (`rh_plot_syr()`), a curva de projeto
adimensional (`rh_plot_design_curve()`), as curvas de projeto iso-garantia e
recursos contra garantia (`rh_plot_iso()`, `rh_plot_resource_curve()`), o
comportamento do reservatório, o balanço mensal, o calendário de falhas, o
espalhamento da chuva e a matriz de climatologia. O `rh_explore()` abre o app
Shiny e o `rh_demo()` abre o caderno de demonstração comentado.

Veja `vignette("ifpb-pi-case-study")` para um exemplo aplicado a um campus real
e `vignette("analysis-and-sizing")` para o ferramental de análise.

## Referências

A abordagem de simulação diária foi aplicada a este campus no seguinte trabalho
de evento, antes do lançamento do pacote:

- Silva, R. M. V. da; Lourenço, A. M. G.; Del Grande, M. H.; Farias, C. A. S. de;
  Albuquerque, E. M. de; Araújo, A. O. de (2024). *Avaliação do potencial de
  aproveitamento de água de chuva usando técnicas de modelagem hidrológica:
  estudo de caso do campus IFPB-PI.* XVII Simpósio de Recursos Hídricos do
  Nordeste (XVII SRHNE), João Pessoa-PB. ABRHidro.
  \[[artigo](https://github.com/ArturLourenco/rharv/blob/main/paper/XVII-SRHNE-2024-rainwater-harvesting-IFPB-PI.pdf)\]
  \[[apresentação](https://github.com/ArturLourenco/rharv/blob/main/paper/XVII-SRHNE-2024-presentation.pdf)\]

Embasamento:

- Souza, T. J. (2015). *Potencial de aproveitamento de água de chuva no meio
  urbano: o caso de Campina Grande, PB.* UFCG.
- ABNT NBR 15527:2019, *Aproveitamento de água de chuva de coberturas para fins
  não potáveis* (relação do volume disponível e fator de eficiência; cancela a
  edição de 2007 e deixa o dimensionamento do reservatório a cargo do projetista).

Para citar o rharv, rode `citation("rharv")`. Um artigo de software dedicado ao
pacote está em preparação (2026).

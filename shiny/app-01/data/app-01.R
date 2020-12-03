# Reproduce shiny/app-01/data/app-01.rds
library(readr)
library(dplyr)
readr::read_csv("data/exp-01.csv") %>%
    dplyr::filter(!is.infinite(estimate)) %>%
    dplyr::group_by(N, d, l, o, m, S) %>%
    dplyr::summarise(mspe = mean((estimate - target)^2)) %>%
    dplyr::rename(method = m) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(o = factor(o, labels = c("1", "√2"))) %>%
    readr::write_rds("shiny/app-01/data/app-01.rds")
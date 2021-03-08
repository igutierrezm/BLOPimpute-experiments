library(magrittr)
f <- function (x, y) mean((x - y)^2)
exp_02a <- 
    readr::read_csv("data/exp-01.csv") %>%
    dplyr::filter(l == 0.75, o == 1, !is.infinite(estimate), m == "blop") %>%
    dplyr::group_by(d, N, S) %>%
    dplyr::summarise(`BLOP (fixed S)` = f(estimate, target), .groups = "drop")
    
exp_02b <- 
    readr::read_csv("data/exp-02.csv") %>%
    dplyr::filter(l == 0.75, o == 1, !is.infinite(estimate)) %>%
    dplyr::group_by(d, N) %>%
    dplyr::summarise(`BLOP (max S)` = f(estimate, target), .groups = "drop")

exp_02 <-
    dplyr::inner_join(exp_02a, exp_02b) %>%
    tidyr::pivot_longer(!c(d, N, S), names_to = "method", values_to = "mse")

p <- 
    exp_02 %>%
    dplyr::group_by(method, d, N, S) %>%
    ggplot2::ggplot(ggplot2::aes(x = S, y = mse, color = method)) + 
    ggplot2::facet_grid(N ~ d, labeller = "label_both", scales = "free") +
    ggplot2::geom_line() +
    ggplot2::theme_linedraw() +
    ggplot2::scale_color_grey() +
    ggplot2::theme(
        panel.grid.major = ggplot2::element_blank(), 
        panel.grid.minor = ggplot2::element_blank(),
        legend.position  = "top"
    )
ggplot2::ggsave("images/exp-02.pdf", p, width = 6, height = 3)
p

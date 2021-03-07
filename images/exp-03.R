library(magrittr)
f <- function (x, y) mean((x - y)^2)
exp_03a <- 
    readr::read_csv("data/exp-02.csv") %>%
    dplyr::filter(l == 0.75, o == 1, !is.infinite(estimate)) %>%
    dplyr::group_by(m, d, N) %>%
    dplyr::summarise(mse = f(estimate, target), .groups = "drop")

exp_03b <- 
    readr::read_csv("data/exp-03.csv") %>%
    dplyr::filter(l == 0.75, o == 1, !is.infinite(estimate)) %>%
    dplyr::group_by(m, d, N) %>%
    dplyr::summarise(mse = f(estimate, target), .groups = "drop")

exp_03 <-
    rbind(exp_03a, exp_03b) %>%
    dplyr::rename(method = m)

p <- 
    exp_03 %>%
    ggplot2::ggplot(ggplot2::aes(x = d, y = mse, fill = method)) + 
    ggplot2::facet_grid( ~ N, labeller = "label_both", scales = "free") +
    ggplot2::geom_bar(stat = "identity", position = ggplot2::position_dodge()) +
    ggplot2::theme_linedraw() +
    ggplot2::scale_fill_grey() + 
    ggplot2::theme(
        panel.grid.major = ggplot2::element_blank(), 
        panel.grid.minor = ggplot2::element_blank(),
        legend.position  = "top"
    )
ggplot2::ggsave("images/exp-03.pdf", p, width = 6, height = 3)
p

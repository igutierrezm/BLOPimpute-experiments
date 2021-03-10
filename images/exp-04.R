library(magrittr)
f <- function (x, y) mean((x - y)^2)
exp_04a <- 
    readr::read_csv("data/exp-02.csv") %>%
    dplyr::filter(l == 1.75, o == sqrt(2), !is.infinite(estimate)) %>%
    dplyr::mutate(m = "blop (max S)") %>%
    dplyr::group_by(m, d, N) %>%
    dplyr::summarise(mse = f(estimate, target), .groups = "drop")

exp_04b <- 
    readr::read_csv("data/exp-04.csv") %>%
    dplyr::filter(l == 1.75, o == sqrt(2), !is.infinite(estimate)) %>%
    dplyr::mutate(m = "blop (fitted S)") %>%
    dplyr::group_by(m, d, N) %>%
    dplyr::summarise(mse = f(estimate, target), .groups = "drop")

exp_04 <-
    rbind(exp_04a, exp_04b) %>%
    dplyr::rename(method = m)

p <- 
    exp_04 %>%
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
ggplot2::ggsave("images/exp-04.pdf", p, width = 6, height = 3)
p

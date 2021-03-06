library(magrittr)
f <- function (x, y) mean((x - y)^2)
exp_03a <- 
    readr::read_csv("data/exp-02.csv") %>%
    dplyr::filter(l == 1.75, o == sqrt(2), !is.infinite(estimate)) %>%
    dplyr::mutate(m = "blop (max S)") %>%
    dplyr::group_by(m, d, N) %>%
    dplyr::summarise(mse = f(estimate, target), .groups = "drop")

exp_03b <- 
    readr::read_csv("data/exp-03.csv") %>%
    dplyr::filter(l == 1.75, o == sqrt(2), !is.infinite(estimate)) %>%
    dplyr::mutate(m = "blop (fitted S, naive method)") %>%
    dplyr::group_by(m, d, N) %>%
    dplyr::summarise(mse = f(estimate, target), .groups = "drop")

exp_03c <- 
    readr::read_csv("data/exp-04.csv") %>%
    dplyr::filter(l == 1.75, o == sqrt(2), !is.infinite(estimate)) %>%
    dplyr::mutate(m = "blop (fitted S, improved method)") %>%
    dplyr::group_by(m, d, N) %>%
    dplyr::summarise(mse = f(estimate, target), .groups = "drop")

exp_03 <-
    rbind(exp_03a, exp_03b, exp_03c) %>%
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
        panel.grid.minor = ggplot2::element_blank()
    )
ggplot2::ggsave("images/exp-03.pdf", p, width = 6, height = 3)
p

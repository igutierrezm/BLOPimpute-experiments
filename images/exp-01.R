library(magrittr)
exp_01 <- readr::read_csv("data/exp-01.csv")
p <- 
    exp_01 %>%
    dplyr::rename(method = m) %>%
    dplyr::filter(l == 0.75, o == 1, !is.infinite(estimate)) %>%
    dplyr::group_by(method, d, N, S) %>%
    dplyr::summarise(mse = mean((estimate - target)^2), .groups = "drop") %>%
    ggplot2::ggplot(ggplot2::aes(x = S, y = mse, color = method)) + 
    ggplot2::facet_grid(N ~ d, labeller = "label_both") +
    ggplot2::geom_line() +
    ggplot2::theme_linedraw() +
    ggplot2::scale_color_grey() +
    ggplot2::theme(
        panel.grid.major = ggplot2::element_blank(), 
        panel.grid.minor = ggplot2::element_blank(),
        legend.position  = "top"
    )
ggplot2::ggsave("images/exp-01.pdf", p, width = 6, height = 3)
p

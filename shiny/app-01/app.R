library(shinythemes)
library(ggthemr)
library(plotly)

ggthemr("light", type = "outer", layout = "scientific", spacing = 2)
df <- readRDS("data/app-01.rds")
eq <- c(
    "\\begin{alignat*}{3}
        y_i^\\star &= \\sum_{j=1}^2 X_{ij}(-1)^{j-1} + \\lambda U_i, &\\qquad i &\\in [N], \\\\
        X_{ij} &\\sim - \\log U([0, 1]), &\\qquad j &\\in [2], \\\\
        U_i &\\sim N(0, 1), \\\\
        p_i &= \\frac{l}{10} + \\frac{0.7}{1 + \\exp(1 + 1.1 X_{i1} - 0.8 X_{i2})}, \\\\
        y_i &= \\begin{cases}
            \\,. & \\text{con probabilidad $p_i$}, \\\\
            y_i^\\star & \\text{con probabilidad $1 - p_i$},
        \\end{cases}
    \\end{alignat*}",
    "\\begin{alignat*}{3}
        y_i^\\star &= \\sum_{j=1}^4 X_{ij}(-1)^{j-1} + \\lambda U_i, &\\qquad i &\\in [N], \\\\
        X_{ij} &\\sim - \\log U([0, 1]), &\\qquad j &\\in [4], \\\\
        U_i &\\sim N(0, 1), \\\\
        p_i &= \\frac{l}{10} + \\frac{0.7}{1 + \\exp(1 + 1.1 X_{i1} - 0.8 X_{i2})}, \\\\
        y_i &= \\begin{cases}
            \\,. & \\text{con probabilidad $p_i$}, \\\\
            y_i^\\star & \\text{con probabilidad $1 - p_i$},
        \\end{cases}
    \\end{alignat*}",
    "\\begin{alignat*}{3}
        y_i^\\star &= \\sum_{j=1}^6 X_{ij}(-1)^{j-1} + \\lambda U_i, &\\qquad i &\\in [N], \\\\
        X_{ij} &\\sim - \\log U([0, 1]), &\\qquad j &\\in [6], \\\\
        U_i &\\sim N(0, 1), \\\\
        p_i &= \\frac{l}{10} + \\frac{0.7}{1 + \\exp(1 + 1.1 X_{i1} - 0.8 X_{i2})}, \\\\
        y_i &= \\begin{cases}
            \\,. & \\text{con probabilidad $p_i$}, \\\\
            y_i^\\star & \\text{con probabilidad $1 - p_i$},
        \\end{cases}
    \\end{alignat*}",
    "\\begin{alignat*}{3}
        y_i^\\star &= \\sum_{j=1}^{10} X_{ij}(-1)^{j-1} + \\lambda U_i, &\\qquad i &\\in [N], \\\\
        X_{ij} &\\sim - \\log U([0, 1]), &\\qquad j &\\in [10], \\\\
        U_i &\\sim N(0, 1), \\\\
        p_i &= \\frac{l}{10} + \\frac{0.7}{1 + \\exp(1 + 1.1 X_{i1} - 0.8 X_{i2})}, \\\\
        y_i &= \\begin{cases}
            \\,. & \\text{con probabilidad $p_i$}, \\\\
            y_i^\\star & \\text{con probabilidad $1 - p_i$},
        \\end{cases}
    \\end{alignat*}",
    "\\begin{alignat*}{3}
        y_i^\\star &= X_{i1} - X_{i2} + X_{i1}^2 - X_{i2}^2 - X_{1i}X_{2i} + \\lambda U_i, &\\qquad i &\\in [N], \\\\
        X_{ij} &\\sim - \\log U([0, 1]), &\\qquad j &\\in [2], \\\\
        U_i &\\sim N(0, 1), \\\\
        p_i &= \\frac{l}{10} + \\frac{0.7}{1 + \\exp(1 + 1.1 X_{i1} - 0.8 X_{i2})}, \\\\
        y_i &= \\begin{cases}
            \\,. & \\text{con probabilidad $p_i$}, \\\\
            y_i^\\star & \\text{con probabilidad $1 - p_i$},
        \\end{cases}
    \\end{alignat*}"
    ) %>%
    lapply(withMathJax)

plot01 <- function(df, .N, .d) {
    p <- 
        dplyr::filter(df, N == .N, d == .d) %>%
        ggplot(aes(x = S, y = mspe, color = method)) + 
        facet_wrap(o ~ l, labeller = "label_both", scales = "free_y") +
        geom_line()
     ggplotly(p) %>% 
        config(mathjax = 'cdn')
}

ui <- fluidPage(
    theme = shinytheme("flatly"),
    titlePanel("My Shiny App"),
    sidebarLayout(
        sidebarPanel(
            selectInput("N", "Choose the sample size", c(500, 1000), 1000),
            selectInput("dgp", "Choose the DGP",  c(1:4), 1),
        ),
        
        mainPanel(
            h2("DGP"),
            uiOutput('ui1'),
            h2("Results"),
            plotlyOutput(outputId = "plot1")
        )
    )
)

server <- function(input, output) {
    output$plot1 <- renderPlotly({
        plot01(df, input$N, input$dgp)
    })
    output$ui1 <- renderUI({
        eq[[as.numeric(input$dgp)]]
    })    
}

# Run the app (comment the last line for local deployment)
app <- shinyApp(ui = ui, server = server)
# shiny::runApp(app, host = '0.0.0.0', port = as.numeric(Sys.getenv('PORT')))
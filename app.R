# Load packages
library(shiny)
library(shinythemes)
library(dplyr)
library(readr)

# Load dataset
data <- read_csv("data/iris.csv")

# Define UI of application
ui <- fluidPage(
    theme = shinytheme("lumen"),
    titlePanel("Iris dataset exploration"),
    sidebarLayout(
        sidebarPanel(
            # Drop-down selector of class
            selectInput(
                inputId = "class",
                label = strong("Class:"),
                choices = unique(data$class)
            ),

            # Slider selector for sepal length
            sliderInput(
                inputId = "sepal_length_range",
                label = "Select a range of sepal length:",
                min = min(data$sepal_length),
                max = max(data$sepal_length),
                value = c(min(data$sepal_length), max(data$sepal_length))
            ),

            # Slider selector for sepal width
            sliderInput(
                inputId = "sepal_width_range",
                "Select a range of sepal width:",
                min = min(data$sepal_width),
                max = max(data$sepal_width),
                value = c(min(data$sepal_width), max(data$sepal_width))
            ),

            # Selector of scatter colour
            selectInput(
                inputId = "colour",
                label = "Select a colour for the scatterplot:",
                choices = c("black", "red", "blue", "green", "orange", "purple")
            ),

            # Select whether to overlay smooth trend line
            checkboxInput(
                inputId = "smoother",
                label = strong("Overlay smooth trend line"),
                value = FALSE
            ),

            # Display only if the smoother is checked
            conditionalPanel(
                condition = "input.smoother == true",
                sliderInput(
                    inputId = "f",
                    label = "Smoother span:",
                    min = 0.01,
                    max = 1,
                    value = 0.67,
                    step = 0.01,
                    animate = animationOptions(interval = 100)
                ),
                HTML("Higher values give more smoothness.")
            )
        ),

        # Output: Description, scatterplot & reference
        mainPanel(
            plotOutput(outputId = "scatterplot", height = "300px"),
            textOutput(outputId = "desc"),
            tags$a(
                href = "https://archive.ics.uci.edu/ml/datasets/iris",
                title = "Source: Iris dataset (Fisher, 1936)",
                target = "_blank"
            )
        )
    )
)

# Define server function
server <- function(input, output) {
    # Subset data according to user-selected conditions
    selected_trends <- reactive({
        req(input$sepal_length_range, input$sepal_width_range)
        validate(need(!is.na(input$sepal_length_range[1]) & !is.na(input$sepal_length_range[2]), "Error: Please select a range of sepal length."))
        validate(need(input$sepal_length_range[1] < input$sepal_length_range[2], "Error: Minimum value should be smaller than maximum value."))
        validate(need(!is.na(input$sepal_width_range[1]) & !is.na(input$sepal_width_range[2]), "Error: Please select a range of sepal width."))
        validate(need(input$sepal_width_range[1] < input$sepal_width_range[2], "Error: Minimum value should be smaller than maximum value."))
        data %>%
        filter(
            class == input$class,
            sepal_length > input$sepal_length_range[1] & sepal_length < input$sepal_length_range[2],
            sepal_width > input$sepal_width_range[1] & sepal_width < input$sepal_width_range[2]
        )
    })

    # Create scatterplot object the plotOutput function is expecting
    output$scatterplot <- renderPlot({
        par(mar = c(4, 4, 1, 1))
        plot(
            main = paste0("Sepal properties of ", input$class),
            x = selected_trends()$sepal_length,
            y = selected_trends()$sepal_width,
            type = "p",
            pch = 16,
            xlab = "Sepal length",
            ylab = "Sepal width",
            col = input$colour,
            fg = "#ffffff",
            col.lab = "#000000",
            col.axis = "#000000"
        )
        box(col = "#000000")
        
        # Display only if smoother is checked
        if(input$smoother){
            smooth_curve <- lowess(
                x = as.numeric(selected_trends()$sepal_length),
                y = selected_trends()$sepal_width,
                f = input$f
            )
            lines(smooth_curve, col = input$colour, lwd = 3)
        }
    })
}

# Create Shiny application
shinyApp(ui = ui, server = server)
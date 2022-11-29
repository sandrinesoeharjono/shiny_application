# Load packages
library(dplyr)

# Import 'data' object from UI
source("ui.R")

# Define server function
server <- function(input, output) {
    # Validate the user-selected conditions
    selected_trends <- reactive({
        req(input$sepal_length_range, input$sepal_width_range, input$petal_length_range, input$petal_width_range)
        validate(need(!is.na(input$sepal_length_range[1]) & !is.na(input$sepal_length_range[2]), "Error: Please select a range of sepal length."))
        validate(need(!is.na(input$sepal_width_range[1]) & !is.na(input$sepal_width_range[2]), "Error: Please select a range of sepal width."))
        validate(need(!is.na(input$petal_length_range[1]) & !is.na(input$petal_length_range[2]), "Error: Please select a range of petal length."))
        validate(need(!is.na(input$petal_width_range[1]) & !is.na(input$petal_width_range[2]), "Error: Please select a range of petal width."))
        
        # Subset data accordingly
        data %>%
            filter(
                class == input$class,
                sepal_length >= input$sepal_length_range[1] & sepal_length <= input$sepal_length_range[2],
                sepal_width >= input$sepal_width_range[1] & sepal_width <= input$sepal_width_range[2],
                petal_length >= input$petal_length_range[1] & petal_length <= input$petal_length_range[2],
                petal_width >= input$petal_width_range[1] & petal_width <= input$petal_width_range[2]
            )
    })

    # Create sepal scatterplot (length vs width)
    output$sepal_scatterplot <- renderPlot({
        # Verify that sufficient data are available to plot
        validate(need(nrow(selected_trends()) > 0, "Error: No data available to plot given the selected constraints."))

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
        
        # Add smoothing curve if smoother selector is checked
        if(input$smoother){
            smooth_curve <- lowess(
                x = as.numeric(selected_trends()$sepal_length),
                y = selected_trends()$sepal_width,
                f = input$f
            )
            lines(smooth_curve, col = input$colour, lwd = 3)
        }
    })

    # Create petal scatterplot (length vs width)
    output$petal_scatterplot <- renderPlot({
        # Verify that sufficient data are available to plot
        validate(need(nrow(selected_trends()) > 0, "Error: No data available to plot given the selected constraints."))

        par(mar = c(4, 4, 1, 1))
        plot(
            main = paste0("Petal properties of ", input$class),
            x = selected_trends()$petal_length,
            y = selected_trends()$petal_width,
            type = "p",
            pch = 16,
            xlab = "Petal length",
            ylab = "Petal width",
            col = input$colour,
            fg = "#ffffff",
            col.lab = "#000000",
            col.axis = "#000000"
        )
        box(col = "#000000")
        
        # Add smoothing curve if smoother selector is checked
        if(input$smoother){
            smooth_curve <- lowess(
                x = as.numeric(selected_trends()$petal_length),
                y = selected_trends()$petal_width,
                f = input$f
            )
            lines(smooth_curve, col = input$colour, lwd = 3)
        }
    
    # Add table of selected data
    output$dataframe <- renderDataTable(
        selected_trends(),
        caption = htmltools::tags$caption(
            style = 'caption-side: top; text-align: center; color:black; font-weight:bold;', 'Selected Dataset'
        )
    )
    })
}
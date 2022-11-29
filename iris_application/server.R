# Load packages
library(dplyr)
library(ggplot2)

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

    # Create sepal scatterplot
    output$sepal_scatterplot <- renderPlot({
        # Verify that sufficient data are available to plot
        validate(need(nrow(selected_trends()) > 0, "Error: No data available to plot given the selected constraints."))

        # Create scatterplot (length vs width)
        ggplot(data = selected_trends(), aes(x = sepal_length, y = sepal_width)) +
            ggtitle(paste0("Sepal properties of ", input$class)) +
            theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
            xlab("Sepal length") +
            ylab("Sepal width") +
            geom_point(colour = input$colour) +
            # Add smoothing curve if smoother selector is checked
            {if(input$smoother) geom_smooth(method = "loess", size = 1.5, colour = input$colour)}
    })

    # Create petal scatterplot
    output$petal_scatterplot <- renderPlot({
        # Verify that sufficient data are available to plot
        validate(need(nrow(selected_trends()) > 0, "Error: No data available to plot given the selected constraints."))
        
        # Create scatterplot (length vs width)
        ggplot(data = selected_trends(), aes(x = petal_length, y = petal_width)) +
            ggtitle(paste0("Petal properties of ", input$class)) +
            theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
            xlab("Petal length") +
            ylab("Petal width") +
            geom_point(colour = input$colour) +
            # Add smoothing curve if smoother selector is checked
            {if(input$smoother) geom_smooth(method = "loess", size = 1.5, colour = input$colour)}
    })

    # Add table of selected data
    output$dataframe <- renderDataTable(
        selected_trends(),
        caption = htmltools::tags$caption(
            style = 'caption-side: top; text-align: center; color:black; font-weight:bold;', 'Selected Dataset'
        )
    )
}
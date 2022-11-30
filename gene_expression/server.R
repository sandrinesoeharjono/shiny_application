library(shiny)
library(cluster)
library(DT)
library(wesanderson)

# Import 'data' object from UI
source("data.R")

server <- function(input, output, session) {
    # DATA
    output$dataframe <- renderDataTable(
        gexp_data,
        caption = htmltools::tags$caption(
            style = 'caption-side:top; text-align:center; color:#555555; font-weight:bold; font-size: 125%', 'Full Expression Dataset'
        )
    )

    # TEXT
    output$general <- renderUI({
      HTML(
        paste0(
        "Here, I use a <a href='https://www.ncbi.nlm.nih.gov/geo/download/?acc=GDS5662'> publicly available dataset</a>
        from <a href='https://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc=GDS5027'> Prat A, Bianchini G, Thomas M, Belousov A et al. (2014)</a> 
        to demonstrate examples of gene expression data manipulation and interactive visualization of its results.
        This dataset contains gene expression values for ", n_features, " features from ", n_samples, " samples of the ", organism,
        " species from a ", title, ".<br><br><b>The tabs allow the user to explore:</b><br>- PCA;<br>- Hierarchical clustering;<br>- Differential expression;<br>- Heatmap;<br>- GSEA.",
        "<br><br><b>Feel free to explore the raw expression dataset (rows = genes, columns = samples) below:</b><br><br>"
        )
      )
    })
}
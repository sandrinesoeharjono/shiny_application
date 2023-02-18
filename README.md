# Shiny Applications
Examples of applications created using the Shiny package in R. Each application has its own folder:
- **iris_application**: Scatterplots and tables of sepal & petal length/width subject to user-defined constraints, as well as overlaid smoothing functions, for data exploration purposes. You can visualize [here](https://sandrinesoeharjono.shinyapps.io/iris_application/) its latest deployed application.
- **gene_expression**: Basic gene expression analyses: PCA, hierarchical clustering, differential expression, heatmap and GSEA. You can visualize [here](https://sandrinesoeharjono.shinyapps.io/gene_expression/) its latest deployed application [IN PROGRESS].

## Installation
To build these applications, you must first install the R programming language. For more information on how to do so on your machine, please see its [documentation](https://www.r-project.org/).

## Usage
To launch an application, run the following command from the root of its folder:
```bash
R -e "shiny::runApp()"
```
You will see a message appear such as the following:
```bash
Listening on http://127.0.0.1:7687
```
Enter this URL into your browser to visualize the dashboard.

## Deployment
To deploy the application using ShinyApp.IO, you must first have installed the 'rsconnect' R package and have a [ShinyApp.IO account](https://www.shinyapps.io/?_ga=2.107189314.1911391660.1669660577-1664356779.1669660577#).

Once those are completed, run the following command from the root of the application's folder:
```bash
R -e "rsconnect::deployApp()"
```
The building may take up to a few minutes. Once complete, a message such as the following will appear:
```bash
Application successfully deployed to https://sandrinesoeharjono.shinyapps.io/iris_application/
```
Enter this URL into your browser to visualize and share the deployed application.
# Setup packrat 

```R
 
packrat::init(options = list(use.cache = TRUE))
   
 
```

# Shiny app

A simple shiny tercen operator :
 - display an histrogram
 - compute the mean
 
```
devtools::install_github("tercen/teRcen")

shiny::runApp(port=3044, launch.browser = FALSE)
```

 






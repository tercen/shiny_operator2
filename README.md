# Setup packrat 

```R

devtools::install_github("tercen/TSON", ref = "1.4-rtson", subdir="rtson", upgrade_dependencies = TRUE)
devtools::install_github("tercen/teRcen", ref = "0.4.8", upgrade_dependencies = TRUE)

packrat::init(options = list(use.cache = TRUE))
  
git add -A && git commit -m "upgrade" && git tag -a 0.0.9 -m "++" && git push && git push --tags
  
  
packrat::status()
packrat::snapshot()
 
```

# Shiny app

A simple shiny tercen operator :
 - display an histrogram
 - compute the mean
 
```
devtools::install_github("tercen/teRcen")

shiny::runApp(port=3044, launch.browser = FALSE)
```

 






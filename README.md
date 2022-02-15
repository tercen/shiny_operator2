##### Setup renv 

```R
renv::restore(prompt = F)
```

##### Description

A simple shiny tercen operator :
 - display an histrogram
 - compute the mean
 
```
devtools::install_github("tercen/teRcen")

shiny::runApp(port=3044, launch.browser = FALSE)
```


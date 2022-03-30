##############################
# DATASETS * Airbnb Listings #
##############################

library(rvest)
library(data.table)

out_path <- file.path(dmpkg.funs::pub_path, 'datasets', 'wd', 'airbnb')

y <- read_html('http://insideairbnb.com/get-the-data.html') |>
            html_elements('a') |>
            html_attr('href')
y <- y[grepl('listings.csv$|neighbourhoods', y)] |> tstrsplit('/')
y <- unique(data.table(country = y[[4]], region = y[[5]], city = y[[6]], last_update = y[[7]]))
y[city == 'visualisations', `:=`( region = country, city = country, last_update = region )]
y <- unique(y)
y[, last_update := as.Date(last_update)]
y <- y[y[, .I[which.max(last_update)], .(country, region, city)]$V1][order(country, region, city)]
fwrite(y, file.path(out_path, 'cities'))

fns <- c('listings.csv', 'neighbourhoods.csv', 'neighbourhoods.geojson')
for(idx in 1:nrow(y)){
    message('Processing ', y[idx, city])
    fpth <- file.path(out_path, y[idx, city])
    dir.create(fpth)
    for(fn in fns)
        if(y[idx, country] == y[idx, city] & y[idx, region] == y[idx, city]){
            download.file(
                paste('http://data.insideairbnb.com', y[idx, city], y[idx, last_update], 'visualisations', fn, sep = '/'), 
                file.path(fpth, fn)
            )
        } else {
            download.file(
                paste('http://data.insideairbnb.com', y[idx, country], y[idx, region], y[idx, city], y[idx, last_update], 'visualisations', fn, sep = '/'), 
                file.path(fpth, fn)
            )
        }
}

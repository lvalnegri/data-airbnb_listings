
dmpkg.funs::load_pkgs(dmp = FALSE, 'data.table', 'sf')

out_path <- file.path(pub_path, 'datasets', 'wd', 'airbnb')
fns <- list.dirs(out_path, FALSE)[-1]

y <- lapply(
        fns, 
		\(x) {
		    message('Processing ', x, '...')
		    st_read(file.path(out_path, x, 'neighbourhoods.geojson'), quiet = TRUE) |>
				subset(select = 1) |> 
		        st_zm() |> st_make_valid() |> st_transform(4326) |> st_cast('MULTIPOLYGON')
        }
)
names(y) <- fns
saveRDS(y, file.path(out_path, 'boundaries'))

y <- rbindlist(lapply(
        fns, 
		\(x) {
		    message('Processing ', x, '...')
		    data.table( city = x, fread(file.path(out_path, x, 'listings.csv')) )
        }
))
fwrite(y, file.path(out_path, 'listings'))

# leaflet() |> 
#     addTiles() |> 
#     addCircleMarkers(
#         data = y[city == 'london' & neighbourhood == 'Southwark'],
#         lng = ~longitude,
#         lat = ~latitude, 
#         radius = 2,
#         label = ~name
#     )

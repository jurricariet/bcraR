#' Series disponibles
#'
#' @description
#'
#' Muestra las series disponibles en la API  Principales variables de Estadísticas Monetarias
#' https://www.bcra.gob.ar/BCRAyVos/catalogo-de-APIs-banco-central.asp
#'
#' @param pattern Opcional: palabras claves para filtrar las series. Por defecto muestra todas las disponibles
#'
#' @return Dataframe con las series con su código para poder consultar
#'
#' @examples
#'
#' series_disponibles <- get_datasets('tasas')
#'
#' @export

get_datasets <- function(pattern=NULL) {
  limit <- 1000
  offset <- 0
  todos <- list()
  
  repeat {
    url <- paste0('https://api.bcra.gob.ar/estadisticas/v4.0/Monetarias?limit=', limit, '&offset=', offset)
    get <- httr::GET(url)
    text <- rawToChar(get$content)
    Encoding(text) <- "UTF-8"
    parsed <- jsonlite::fromJSON(text)
    
    # Ajustá según la estructura real de la respuesta
    df <- as.data.frame(parsed)[, c(1, 5:14)]
    names(df) <- c('status','id_variable','descripcion','categoria','tipo_serie',
                   'periodicidad','unidad','moneda','primera_fecha','fecha','valor')
    
    todos <- c(todos, list(df))
    
    if (nrow(df) < limit) break
    
    offset <- offset + limit
  }
  
  lista_variables <- do.call(rbind, todos)
  
  if (!is.null(pattern)) {
    lista_variables <- lista_variables[grep(pattern, lista_variables$descripcion, ignore.case = TRUE), ]
  }
  
  return(lista_variables)
}

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
  get <- httr::GET('https://api.bcra.gob.ar/estadisticas/v3.0/Monetarias')
  text <- rawToChar(get$content)
  Encoding(text) <- "UTF-8"
  lista_variables <- as.data.frame(jsonlite::fromJSON(text))
  names(lista_variables) <- c('status','id_variable','descripcion','categoria',
                              'fecha','valor')
  if(!is.null(pattern)){
    lista_variables <- lista_variables[grep(pattern, lista_variables$descripcion, ignore.case = TRUE),]
  return(lista_variables)
  } else {
    return(lista_variables)
  }
}

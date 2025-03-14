#' Datos del Mercado de Cambios
#'
#' @description
#'
#' Devuelve los datos del Anexo estadístico del informe mensual del mercado de cambios, correspondiente al excel 'Nuevo Anexo', pestaña 'Datos mercado de cambios', en formato data frame
#'
#' @return Dataframe con los datos del mercado de cambios
#'
#' @examples
#'
#' data <- get_mercado_cambios()
#' head(data)
#' @export

get_mercado_cambios <- function() {
  # URL del archivo
  url1 <- 'https://www.bcra.gob.ar/Pdfs/PublicacionesEstadisticas/Nuevo-anexo-MC.xlsm'

  # Crear archivo temporal con extensión correcta
  tf <- tempfile(fileext = ".xlsm")

  # Descargar el archivo
  httr::GET(
    url1,
    httr::write_disk(tf, overwrite = TRUE),
    httr::config(ssl_verifypeer = FALSE)  # Configuración SSL correcta para httr
  )


  # Leer el archivo
  mulc <- readxl::read_excel(tf, sheet="Datos Mercado de Cambios")
  return(mulc)
}



#' Datos de la API del BCRA
#'
#' @description
#'
#' Devuelve los datos de la consulta a la API en formato data frame
#' #'
#' @param id_vars Codigo de la variable a consultar o vector con multiples codigos
#'
#' @param start_date Fecha de inicio de la consulta
#'
#' @param end_date Fecha de fin de la consulta
#'
#' @return Dataframe con los datos de la consulta
#'
#' @examples
#'
#' ids <- c(6,14)
#' fecha_inicio <- '2024-01-01'
#' fecha_fin <- Sys.Date()
#' tasas <- get_bcra(id_vars = ids, start_date = fecha_inicio, end_date = fecha_fin)
#'
#' @export


get_bcra <- function(id_vars, start_date = "2024-01-01", end_date = "2025-12-31") {
  # Funcion auxiliar para obtener serie individual
  get_serie_individual <- function(id_variable, start_date, end_date) {
    # Inicializar un dataframe vacio para almacenar resultados
    all_results <- data.frame(fecha = character(), valor = numeric(), stringsAsFactors = FALSE)

    # Convertir fechas a objetos de fecha
    current_start <- as.Date(start_date)
    final_end <- as.Date(end_date)

    # Establecer un valor fijo para max_records
    max_records <- 1000

    # Bucle para dividir en intervalos
    while(current_start <= final_end) {
      # Calcular el final del intervalo actual
      current_end <- min(current_start + lubridate::days(max_records), final_end)

      # Crear la URL para la consulta a la API
      url <- paste0('https://api.bcra.gob.ar/estadisticas/v4.0/Monetarias/',
                    id_variable,
                    '?desde=', format(current_start, "%Y-%m-%d"),
                    '&hasta=', format(current_end, "%Y-%m-%d"))

      # Realizar la consulta a la API
      response <- httr::GET(url)

      # Verificar si la solicitud fue exitosa
      if (httr::status_code(response) == 200) {
        # Parsear la respuesta
        content <- rawToChar(response$content)
        parsed_content <- jsonlite::fromJSON(content)

        # Verificar si hay resultados
        if (length(parsed_content$results) > 0) {
          results <- as.data.frame(parsed_content$results$detalle, stringsAsFactors = FALSE)

          # Convertir fecha a Date y valor a numeric
          results$fecha <- as.Date(results$fecha)
          results$valor <- as.numeric(as.character(results$valor))
          results$id_variable <- parsed_content$results$idVariable

          # Agregar resultados al dataframe
          all_results <- rbind(all_results, results)
        }
      } else {
        warning(paste("Error en consulta para variable", id_variable,
                      "en intervalo", current_start, "a", current_end,
                      "- Codigo de estado:", httr::status_code(response)))
      }

      # Mover al siguiente intervalo
      current_start <- current_end + lubridate::days(1)
    }

    return(all_results)
  }

  # Verificar si id_vars es un vector o un solo ID
  if (length(id_vars) == 1) {
    # Si es un solo ID, obtener esa serie
    result <- get_serie_individual(id_vars, start_date, end_date)
  } else {
    # Si es un vector, mapear sobre cada ID y combinar resultados
    result_list <- lapply(id_vars, function(id) {
      get_serie_individual(id, start_date, end_date)
    })

    # Combinar todos los resultados en un solo dataframe usando do.call con rbind en R base
    result <- do.call(rbind, result_list)

    # Reiniciar los rownames
    rownames(result) <- NULL
  }

  # Eliminar duplicados si los hubiera y devolver el resultado
  return(unique(result))
}

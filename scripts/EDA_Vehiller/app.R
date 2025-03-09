# ------------------------------------------
# PAQUETES NECESARIOS
# ------------------------------------------
library(shiny)
library(shinydashboard)
library(rgl)
library(viridisLite)
library(dplyr)
library(DT)

# ------------------------------------------
# INTERFAZ DE USUARIO (UI)
# ------------------------------------------
ui <- dashboardPage(
  skin = "blue",  # Cambiamos a "blue" para que coincida con la estética
  dashboardHeader(
    title = "Dashboard de Pokémon 3D",
    titleWidth = 300
  ),
  
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Gráfico 3D", tabName = "grafico_3d", icon = icon("globe")),
      menuItem("Tabla de Datos", tabName = "tabla_datos", icon = icon("table"))
    ),
    
    # Filtros en la barra lateral
    sliderInput("size_filter", "Tamaño de los puntos:", min = 1, max = 5, value = 3),  # Rango ajustado a 1-5
    uiOutput("type_buttons")  # Botones de tipo en lugar de lista desplegable
  ),
  
  dashboardBody(
    # CSS personalizado para la estética azul con blanco
    tags$head(
      tags$style(HTML("
        /* Fondo general del dashboard */
        body {
          background-color: #385a7f !important;
          color: white !important;
        }
        
        /* Fondo del header */
        .main-header .navbar {
          background-color: #385a7f !important;
          color: white !important;
        }
        
        /* Fondo del sidebar */
        .main-sidebar {
          background-color: #385a7f !important;
          color: white !important;
        }
        
        /* Color del texto en el sidebar */
        .main-sidebar .sidebar-menu li a {
          color: white !important;
        }
        
        /* Fondo de los boxes */
        .box {
          background-color: #385a7f !important;
          border: 1px solid #ffffff80 !important;
          color: white !important;
        }
        
        /* Títulos de los boxes */
        .box-title {
          color: white !important;
        }
        
        /* Fondo de los inputs */
        .selectize-input, .selectize-dropdown {
          background-color: #385a7f !important;
          color: white !important;
        }
        
        /* Botones */
        .btn {
          background-color: #385a7f !important;
          border-color: white !important;
          color: white !important;
          margin: 5px;
          width: 80px;  # Ancho fijo para los botones
        }
        
        /* Contenedor de botones */
        .button-container {
          display: grid;
          grid-template-columns: repeat(3, 1fr);  # 3 columnas
          gap: 5px;  # Espacio entre botones
        }
        
        /* Tabla de datos */
        .dataTables_wrapper {
          color: white !important;
        }
        
        /* Paginación de la tabla */
        .dataTables_paginate .paginate_button {
          color: white !important;
        }
      "))
    ),
    
    tabItems(
      # Pestaña del gráfico 3D
      tabItem(
        tabName = "grafico_3d",
        fluidRow(
          box(
            title = textOutput("graph_title"),  # Título dinámico
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DTOutput("summary_table"),  # Matriz resumen
            rglwidgetOutput("rgl_plot", width = "100%", height = "600px")
          )
        )
      ),
      
      # Pestaña de la tabla de datos
      tabItem(
        tabName = "tabla_datos",
        fluidRow(
          box(
            title = "Tabla de Datos de Pokémon",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("data_table")  # Usar DT:: para evitar conflictos
          )
        )
      )
    )
  )
)

# ------------------------------------------
# LÓGICA DEL SERVIDOR (SERVER)
# ------------------------------------------
server <- function(input, output, session) {
  
  # Cargar y preprocesar los datos
  pokemon <- reactive({
    read.csv("C:/Users/AsistMinisterial/Documents/GitHub/Sistema-de-clasificaci-n-Pokemon---Trabajo-Final-Computaci-n-1/data/pokemon.csv", fileEncoding = "UTF-8") %>%  # Asegúrate de que la ruta sea correcta
      rename_with(~ tolower(gsub("[^a-zA-Z0-9]", "", .x))) %>%
      mutate(
        type1 = as.factor(gsub("[^a-zA-Z0-9]", "", type1)),
        type1_id = as.numeric(as.factor(type1)),
        total_scaled = total / max(total) * 4,
        speed_color = viridis(100)[cut(speed, breaks = 100)]  # Usar viridis para colores
      ) %>%
      filter(
        complete.cases(atk, spdef, speed),
        type1 != ""
      )
  })
  
  # Generar botones de tipo en una cuadrícula de 6 filas y 3 columnas
  output$type_buttons <- renderUI({
    types <- unique(pokemon()$type1)
    div(class = "button-container",
        lapply(types, function(type) {
          actionButton(
            inputId = paste0("type_", type),
            label = type,
            style = "margin: 5px;"
          )
        })
    )
  })
  
  # Variable reactiva para almacenar el tipo seleccionado
  selected_type <- reactiveVal(NULL)
  
  # Observar los botones de tipo
  observe({
    types <- unique(pokemon()$type1)
    lapply(types, function(type) {
      observeEvent(input[[paste0("type_", type)]], {
        selected_type(type)
      })
    })
  })
  
  # Paleta de colores personalizada para los tipos
  type_colors <- c(
    "fire" = "#FF4500",  # Rojo anaranjado
    "fighting" = "#8B0000",  # Rojo oscuro
    "flying" = "#87CEEB",  # Azul claro
    "dragon" = "#6A5ACD",  # Azul medio
    "dark" = "#2F4F4F",  # Verde oscuro
    "water" = "#0000FF",  # Azul
    "grass" = "#008000",  # Verde
    "electric" = "#FFD700",  # Dorado
    "psychic" = "#FF1493",  # Rosa
    "ice" = "#00FFFF",  # Cian
    "bug" = "#9ACD32",  # Verde lima
    "rock" = "#8B4513",  # Marrón
    "ghost" = "#4B0082",  # Índigo
    "steel" = "#708090",  # Gris
    "fairy" = "#FF69B4"  # Rosa claro
  )
  
  # Título dinámico del gráfico
  output$graph_title <- renderText({
    req(selected_type())
    paste("Gráfico 3D de Pokémon - Tipo:", selected_type())
  })
  
  # Matriz resumen de coordenadas
  output$summary_table <- renderDT({
    req(selected_type())  # Asegurarse de que se haya seleccionado un tipo
    
    # Filtrar datos según el tipo seleccionado
    filtered_data <- pokemon() %>%
      filter(type1 == selected_type()) %>%
      select(atk, spdef, speed)  # Seleccionar solo las columnas relevantes
    
    # Mostrar la tabla resumen
    datatable(
      filtered_data,
      options = list(
        pageLength = 5,  # Mostrar solo 5 filas por página
        scrollX = TRUE,  # Habilitar desplazamiento horizontal
        dom = "t",  # Mostrar solo la tabla (sin búsqueda ni paginación)
        ordering = FALSE  # Deshabilitar ordenación
      ),
      rownames = FALSE  # Ocultar nombres de filas
    )
  })
  
  # Renderizar el gráfico 3D
  output$rgl_plot <- renderRglwidget({
    req(selected_type())  # Asegurarse de que se haya seleccionado un tipo
    
    # Filtrar datos según el tipo seleccionado
    filtered_data <- pokemon() %>%
      filter(type1 == selected_type())
    
    # Asignar colores automáticamente
    point_color <- type_colors[selected_type()]
    
    # Crear el gráfico 3D
    open3d(useNULL = TRUE)  # Usar un dispositivo nulo para evitar ventanas emergentes
    plot3d(
      x = filtered_data$atk,
      y = filtered_data$spdef,
      z = filtered_data$speed,
      col = point_color,  # Color automático basado en el tipo
      size = input$size_filter,
      type = "s",
      alpha = 0.85,
      axes = FALSE,
      xlab = "", ylab = "", zlab = ""
    )
    axes3d(edges = c("x", "y", "z"), col = "#ffffff80", tick = FALSE, nticks = 6)
    grid3d(c("x", "y", "z"), col = "#2d3f4d", lwd = 1.5)
    
    # Cambiar el fondo de la gráfica 3D
    bg3d(color = "#385a7f")  # Fondo azul
    
    # Agregar etiquetas a los ejes
    text3d(x = max(filtered_data$atk) + 10, y = 0, z = 0, texts = "Ataque (X)", col = "white", cex = 1.2)
    text3d(x = 0, y = max(filtered_data$spdef) + 10, z = 0, texts = "Defensa Especial (Y)", col = "white", cex = 1.2)
    text3d(x = 0, y = 0, z = max(filtered_data$speed) + 10, texts = "Velocidad (Z)", col = "white", cex = 1.2)
    
    # Convertir el gráfico 3D en un widget HTML
    rglwidget()
  })
  
  # Renderizar la tabla de datos
  output$data_table <- DT::renderDataTable({  # Usar DT:: para evitar conflictos
    datatable(pokemon(), options = list(pageLength = 10, scrollX = TRUE))
  })
}

# ------------------------------------------
# EJECUTAR LA APLICACIÓN
# ------------------------------------------
shinyApp(ui, server)
# ------------------------------------------
# PAQUETES NECESARIOS
# ------------------------------------------
library(shiny)
library(shinydashboard)
library(rgl)
library(tidyverse)
library(gt)
library(viridis)
library(DT)
library(ggalluvial)

# ------------------------------------------
# CARGAR Y PREPARAR DATOS
# ------------------------------------------
# Cargar datos
pokemon <- read.csv("C:/Users/AsistMinisterial/Documents/GitHub/Sistema-de-clasificacion-Pokemon---Trabajo-Final-Computacion-1/data/pokemon.csv", fileEncoding = "UTF-8") %>%
  rename_with(~ tolower(gsub("[^a-zA-Z0-9]", "", .x))) %>%  # Paréntesis cerrado
  mutate(
    type1 = as.factor(gsub("[^a-zA-Z0-9]", "", type1)),
    total_scaled = total / max(total) * 4,
    speed_color = viridis(100)[cut(speed, breaks = 100)]
  )

# Preparación de datos
pokemon_abilities <- pokemon %>%
  separate_rows(abilities, sep = ", ") %>%
  filter(!is.na(abilities))  # Filtro correctamente cerrado
              
              type1_freq <- pokemon %>% 
                count(type1, name = "n") %>% 
                arrange(desc(n))
              
              type2_freq <- pokemon %>% 
                count(type2, name = "n") %>% 
                drop_na(type2) %>% 
                arrange(desc(n))
              
              habilidades_por_tipo <- pokemon %>%
                separate_rows(abilities, sep = ", ") %>%
                filter(!is.na(abilities)) %>%
                group_by(type1, abilities) %>%
                summarise(n = n(), .groups = "drop") %>%
                group_by(type1) %>%
                slice_max(n, n = 3)
              
              # ------------------------------------------
              # INTERFAZ DE USUARIO (UI)
              # ------------------------------------------
              ui <- dashboardPage(
                skin = "blue",
                dashboardHeader(
                  title = "Dashboard Pokémon Completo",
                  titleWidth = 300
                ),
                
                dashboardSidebar(
                  width = 300,
                  sidebarMenu(
                    menuItem("Gráfico 3D", tabName = "3d", icon = icon("globe")),
                    menuItem("Análisis Univariado", tabName = "univariado", icon = icon("chart-bar")),
                    menuItem("Combinaciones", tabName = "combinaciones", icon = icon("heatmap")),
                    menuItem("Habilidades", tabName = "habilidades", icon = icon("table")),
                    menuItem("Datos Crudos", tabName = "datos", icon = icon("database"))
                  ),
                  
                  sliderInput("size_filter", "Tamaño puntos 3D:", min = 1, max = 5, value = 3),
                  uiOutput("type_buttons")
                ),
                
                dashboardBody(
                  tags$head(
                    tags$style(HTML("
        * { color: white !important; }
        .shiny-plot-output text { fill: white !important; }
        .axis text { color: white !important; }
        .button-container {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 8px;
          padding: 10px;
        }
        .btn {
          width: 100px !important;
          height: 40px !important;
          padding: 5px !important;
          border-radius: 5px !important;
        }
        .dataTables_wrapper { color: white !important; }
        body { background-color: #385a7f !important; }
        .main-header .navbar { background-color: #385a7f !important; }
        .main-sidebar { background-color: #385a7f !important; }
        .box { 
          background-color: #385a7f !important; 
          border: 1px solid #ffffff80 !important;
        }
      "))
                  ),
                  
                  tabItems(
                    # Pestaña 3D
                    tabItem(tabName = "3d",
                            box(title = "Visualización 3D", width = 12, status = "primary",
                                DTOutput("summary_table_3d"),
                                rglwidgetOutput("rgl_plot", width = "100%", height = "600px"))
                    ),
                    
                    # Pestaña Univariado
                    tabItem(tabName = "univariado",
                            fluidRow(
                              box(title = "Tipos Primarios", width = 6, status = "primary",
                                  plotOutput("type1_plot", height = "500px")),
                              box(title = "Tipos Secundarios", width = 6, status = "primary",
                                  gt_output("type2_table"))
                            )
                    ),
                    
                    # Pestaña Combinaciones
                    tabItem(tabName = "combinaciones",
                            box(title = "Mapa de Calor Tipos", width = 12, status = "primary",
                                plotOutput("heatmap_plot", height = "600px"))
                    ),
                    
                    # Pestaña Habilidades
                    tabItem(tabName = "habilidades",
                            fluidRow(
                              box(title = "Top 6 Habilidades", width = 6, status = "primary",
                                  plotOutput("top_abilities_plot", height = "500px")),
                              box(title = "Habilidades por Tipo", width = 6, status = "primary",
                                  gt_output("habilidades_table"))
                            )
                    ),
                    
                    # Pestaña Datos
                    tabItem(tabName = "datos",
                            box(title = "Datos Completos", width = 12, status = "primary",
                                DT::dataTableOutput("full_data_table")))
                  )
                )
              )
              
              # ------------------------------------------
              # LÓGICA DEL SERVIDOR (SERVER)
              # ------------------------------------------
              server <- function(input, output, session) {
                
                # Botones de tipos
                output$type_buttons <- renderUI({
                  types <- unique(pokemon$type1)
                  div(class = "button-container",
                      lapply(types, function(type) {
                        actionButton(paste0("type_", type), type, style = "margin: 5px;")
                      }))
                })
                
                selected_type <- reactiveVal(NULL)
                lapply(unique(pokemon$type1), function(type) {
                  observeEvent(input[[paste0("type_", type)]], { selected_type(type) })
                })
                
                # Gráfico 3D
                output$rgl_plot <- renderRglwidget({
                  req(selected_type())
                  filtered_data <- pokemon %>% filter(type1 == selected_type())
                  
                  open3d(useNULL = TRUE)
                  plot3d(
                    x = filtered_data$atk,
                    y = filtered_data$spdef,
                    z = filtered_data$speed,
                    col = viridis(nrow(filtered_data)),
                    size = input$size_filter,
                    type = "s",
                    alpha = 0.85,
                    axes = FALSE
                  )
                  axes3d(edges = c("x", "y", "z"), col = "white", lwd = 2)
                  grid3d(c("x", "y", "z"), col = "#ffffff80", lwd = 1.5)
                  mtext3d("Ataque", edge = "x", col = "white", line = 2)
                  mtext3d("Defensa Especial", edge = "y", col = "white", line = 2)
                  mtext3d("Velocidad", edge = "z", col = "white", line = 2)
                  bg3d(color = "#385a7f")
                  rglwidget()
                })
                
                # Análisis Univariado
                output$type1_plot <- renderPlot({
                  ggplot(type1_freq, aes(reorder(type1, n), n, fill = type1)) +
                    geom_col(alpha = 0.9, width = 0.7) +
                    geom_label(aes(label = n), fill = "white", size = 4, label.padding = unit(0.3, "lines")) +
                    scale_fill_viridis(discrete = TRUE) +
                    coord_flip() +
                    labs(x = NULL, y = "Frecuencia") +
                    theme_bw() +
                    theme(
                      legend.position = "none",
                      plot.background = element_rect(fill = "#385a7f"),
                      axis.text = element_text(color = "white", size = 12),
                      panel.grid = element_line(color = "#ffffff20")
                    )
                })
                
                output$type2_table <- render_gt({
                  type2_freq %>%
                    gt() %>%
                    data_color(columns = n, colors = viridis(10)) %>%
                    fmt_number(columns = n, decimals = 0) %>%
                    tab_options(table.font.color = "white")
                })
                
                # Mapa de Calor
                output$heatmap_plot <- renderPlot({
                  pokemon %>%
                    count(type1, type2) %>%
                    drop_na(type2) %>%
                    ggplot(aes(type1, type2, fill = n)) +
                    geom_tile(color = "white") +
                    geom_text(aes(label = n), color = "white", size = 3) +
                    scale_fill_viridis(option = "magma") +
                    labs(x = NULL, y = NULL) +
                    theme_bw() +
                    theme(
                      axis.text.x = element_text(angle = 45, hjust = 1, color = "white"),
                      axis.text.y = element_text(color = "white"),
                      plot.background = element_rect(fill = "#385a7f"),
                      legend.text = element_text(color = "white")
                    )
                })
                
                # Habilidades
                output$top_abilities_plot <- renderPlot({
                  habilidades_separadas <- pokemon %>%
                    separate_rows(abilities, sep = ", ") %>%
                    filter(!is.na(abilities)) %>%
                    count(abilities, name = "n") %>%
                    slice_max(n, n = 6)
                  
                  ggplot(habilidades_separadas, aes(reorder(abilities, n), n)) +
                    geom_col(fill = "#2c3e50", alpha = 0.8, width = 0.7) +
                    geom_label(aes(label = n), fill = "#e74c3c", color = "white", size = 4) +
                    coord_flip() +
                    labs(title = "Top 6 Habilidades", x = NULL, y = NULL) +
                    theme_minimal() +
                    theme(
                      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
                      axis.text = element_text(color = "white", size = 12),
                      plot.background = element_rect(fill = "#385a7f"),
                      panel.grid = element_line(color = "#ffffff20")
                    )
                })
                
                output$habilidades_table <- render_gt({
                  habilidades_por_tipo %>%
                    group_by(type1) %>%
                    slice_max(n, n = 6) %>%
                    gt() %>%
                    data_color(columns = n, colors = viridis(10)) %>%
                    fmt_number(columns = n, decimals = 0) %>%
                    tab_options(
                      table.font.color = "white",
                      column_labels.background.color = "#385a7f",
                      data_row.padding = px(5)
                    )
                })
                
                # Datos Completos
                output$full_data_table <- DT::renderDataTable({
                  datatable(
                    pokemon,
                    options = list(
                      pageLength = 10,
                      scrollX = TRUE,
                      dom = 'Bfrtip',
                      buttons = c('copy', 'csv', 'excel')
                    ),
                    rownames = FALSE,
                    style = "bootstrap",
                    class = "compact",
                    filter = "top"
                  ) %>%
                    formatStyle(columns = names(pokemon), color = "white")
                })
              }
              
              # ------------------------------------------
              # EJECUTAR LA APLICACIÓN
              # ------------------------------------------
              shinyApp(ui, server)
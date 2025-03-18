library(shiny)
library(tidyverse)
library(gt)
library(viridis)

# Cargar datos (ajusta la ruta según tu entorno)
pokemon <- read.csv("C:/Users/AsistMinisterial/Documents/GitHub/Sistema-de-clasificacion-Pokemon---Trabajo-Final-Computacion-1/data/pokemon.csv", fileEncoding = "UTF-8")

# ------------------------------------------
# Preparación de datos (se ejecuta una vez)
# ------------------------------------------
pokemon_abilities <- pokemon %>%
  separate_rows(abilities, sep = ", ") %>%
  filter(!is.na(abilities))

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
# Interfaz de usuario (UI)
# ------------------------------------------
ui <- fluidPage(
  titlePanel("EDA_Vehiller.dashboard"),
  sidebarLayout(
    sidebarPanel(
      h4("Autor: vehiller Dwindt"),
      h5("Fecha: 2025-03-07"),
      width = 2
    ),
    mainPanel(
      tabsetPanel(
        # Panel 1: Tipo Primario
        tabPanel("Distribución Tipo Primario",
                 plotOutput("type1_plot",
                            height = "600px")
        ),
        
        # Panel 2: Tipo Secundario
        tabPanel("Frecuencia Tipo Secundario",
                 gt_output("type2_table")
        ),
        
        # Panel 3: Mapa de Calor
        tabPanel("Combinaciones de Tipos",
                 plotOutput("heatmap_plot",
                            height = "600px")
        ),
        
        # Panel 4: Top Habilidades
        tabPanel("Top 10 Habilidades",
                 plotOutput("top_abilities_plot",
                            height = "500px")
        ),
        
        # Panel 5: Tabla Interactiva
        tabPanel("Habilidades por Tipo",
                 gt_output("habilidades_table")
        )
      ),
      width = 10
    )
  )
)

# ------------------------------------------
# Lógica del servidor (Server)
# ------------------------------------------
server <- function(input, output) {
  
  # Gráfico de tipo primario
  output$type1_plot <- renderPlot({
    ggplot(type1_freq, aes(x = reorder(type1, n), y = n, fill = type1)) +
      geom_col(alpha = 0.9, width = 0.7) +
      geom_label(aes(label = n), fill = "white", size = 3.5) +
      scale_fill_viridis(discrete = TRUE, option = "plasma") +
      labs(title = "Distribución de Tipos Primarios", x = NULL, y = "Frecuencia") +
      coord_flip() +
      theme_bw(base_size = 14) +
      theme(legend.position = "none")
  })
  
  # Tabla de tipo secundario
  output$type2_table <- render_gt({
    type2_freq %>%
      gt() %>%
      tab_header(
        title = md("**Frecuencia de Tipos Secundarios**"),
        subtitle = "Orden descendente"
      ) %>%
      data_color(
        columns = n,
        colors = scales::col_numeric(palette = viridis(10), domain = NULL)
      ) %>%
      fmt_number(columns = n, decimals = 0)
  })
  
  # Mapa de calor
  output$heatmap_plot <- renderPlot({
    pokemon %>%
      count(type1, type2) %>%
      drop_na(type2) %>%
      ggplot(aes(x = type1, y = type2, fill = n)) +
      geom_tile(color = "white") +
      geom_text(aes(label = n), color = "black", size = 3.5) +
      scale_fill_viridis(option = "magma", name = "Frecuencia") +
      labs(title = "Mapa de Calor: Combinaciones de Tipos",
           x = "Tipo Primario",
           y = "Tipo Secundario") +
      theme_bw(base_size = 14) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Top 10 habilidades
  output$top_abilities_plot <- renderPlot({
    habilidades_separadas <- pokemon %>%
      separate_rows(abilities, sep = ", ") %>%
      filter(!is.na(abilities)) %>%
      count(abilities, name = "n") %>%
      arrange(desc(n)) %>%
      slice_max(n, n = 10)
    
    ggplot(habilidades_separadas, aes(x = reorder(abilities, n), y = n)) +
      geom_col(fill = "#2c3e50", alpha = 0.8) +
      geom_label(aes(label = n), fill = "#e74c3c", color = "white", size = 3.5) +
      coord_flip() +
      labs(title = "Top 10 Habilidades más Comunes", x = NULL, y = "Frecuencia") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"))
  })
  
  # Tabla habilidades por tipo
  output$habilidades_table <- render_gt({
    habilidades_por_tipo %>%
      gt() %>%
      tab_header(
        title = md("**Habilidades más Comunes por Tipo Primario**"),
        subtitle = "Top 3 habilidades por tipo"
      ) %>%
      data_color(
        columns = n,
        colors = scales::col_numeric(palette = viridis(10), domain = NULL)
      ) %>%
      fmt_number(columns = n, decimals = 0)
  })
}

# Ejecutar la aplicación
shinyApp(ui, server)
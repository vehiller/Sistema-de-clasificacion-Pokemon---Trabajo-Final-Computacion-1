# # Parte desarrollada por Alirio Guerrero, análisis estadístico.
# # 4. Análisis de Combinaciones de Tipos por habilidades:
# # Calcular la frecuencia de cada combinación única de Type1 y Type2.
# # Visualizar las combinaciones más comunes.

import csv
from collections import defaultdict
import plotly.express as px

# Función para analizar habilidades agrupadas por combinación de tipos
def analizar_combinaciones_interactivas(csv_file, columna1, columna2, columna_habilidades):
    combinaciones_habilidades = defaultdict(list)

    # Leer archivo CSV y agrupar habilidades por combinación de tipos
    with open(csv_file, mode='r', encoding='utf-8') as archivo:
        lector_csv = csv.DictReader(archivo, delimiter=';')
        for fila in lector_csv:
            combinacion = (fila[columna1], fila[columna2])
            habilidades = fila[columna_habilidades].split()
            combinaciones_habilidades[combinacion].extend(habilidades)

    # Crear datos para la gráfica
    datos = []
    for combinacion, habilidades in combinaciones_habilidades.items():
        tipo1, tipo2 = combinacion
        habilidades_texto = ", ".join(habilidades)
        datos.append({
            'Combinación': f"{tipo1} + {tipo2}",
            'Número de Habilidades': len(habilidades),
            'Habilidades': habilidades_texto
        })

    # Crear gráfico interactivo
    fig = px.bar(
        datos,
        x='Combinación',
        y='Número de Habilidades',
        hover_data=['Habilidades'],  # Mostrar detalles al pasar el mouse
        title='Número de habilidades por combinación de tipos',
        labels={'Combinación': 'Combinación de Type1 y Type2', 'Número de Habilidades': 'Cantidad de Habilidades'},
        template='plotly'
    )
    fig.update_layout(
        xaxis=dict(tickangle=45),  # Rotar etiquetas del eje X
        height=600,  # Ajustar altura del gráfico
        margin=dict(t=50, b=150)  # Ajustar márgenes
    )

    # Guardar gráfico como archivo HTML
    fig.write_html('grafico_interactivo.html')
    print("El gráfico se guardó como 'grafico_interactivo.html'. Ábrelo manualmente en tu navegador.")

    # Mostrar el gráfico en el navegador
    fig.show()

# Ejecutar análisis
analizar_combinaciones_interactivas('DBPokemons.csv', 'type1', 'type2', 'abilities')


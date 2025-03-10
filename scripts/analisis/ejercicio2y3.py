# Parte desarrollada por Alirio Guerrero, análisis estadístico.
# 2 y 3. Análisis de Combinaciones de Tipos y habilidades:
# Calcular la frecuencia de cada combinación única de Type1 y Type2.
# Visualizar las combinaciones más comunes.

import csv
from collections import Counter
import matplotlib.pyplot as plt
import seaborn as sns        
        

# Función para analizar combinaciones de tipos
def analizar_combinaciones(csv_file, columna1, columna2):
    combinaciones = Counter()
    
    with open(csv_file, mode='r', encoding='utf-8') as archivo:
        lector_csv = csv.DictReader(archivo, delimiter=';')
        for fila in lector_csv:
            combinacion = (fila[columna1], fila[columna2])
            combinaciones[combinacion] += 1
    
    print(f"\nFrecuencia de cada combinación de {columna1} y {columna2}:")
    for combinacion, frecuencia in combinaciones.items():
        print(f"{combinacion}: {frecuencia}")
    
    # Encuentro la clave asociada al valor máximo y mínimo
    frecuencia_maxima = max(combinaciones, key=combinaciones.get)
    frecuencia_minima = min(combinaciones, key=combinaciones.get)

    # Obtengo los valores máximo y mínimo usando las claves encontradas
    valor_maximo = combinaciones[frecuencia_maxima]
    valor_minimo = combinaciones[frecuencia_minima]

    # Creo un nuevo diccionario con los resultados
    frecuencia_max_min = {
        'frecuencia_maxima': (frecuencia_maxima, valor_maximo),
        'frecuencia_minima': (frecuencia_minima, valor_minimo)
    }

    # Imprimo el nuevo diccionario
    for clave, (key, value) in frecuencia_max_min.items():
        print(f"{clave} ({key}): {value}")

    # Graficar las combinaciones más comunes
    datos = ["+".join(combinacion) for combinacion in combinaciones.keys()]
    valores = list(combinaciones.values())
    plt.figure(figsize=(10, 6))
    sns.barplot(x=datos, y=valores, palette="viridis")
    
    plt.title(f'Frecuencia de combinaciones de {columna1} y {columna2}')
    plt.xlabel('Combinaciones')
    plt.ylabel('Frecuencia')
    plt.xticks(rotation=90)
    plt.show()


# Análisis de combinaciones de tipos
analizar_combinaciones('DBPokemons.csv', 'type1', 'type2')
# Análisis de combinaciones por habilidades y tipo primario
analizar_combinaciones('DBPokemons.csv', 'abilities', 'type1')



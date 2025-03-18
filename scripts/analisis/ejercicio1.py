# Análisis estadístico desarrollado por Alirio
# cat("Aquí se realizarán los cálculos y gráficos.\n")
# Parte desarrollada por Alirio Guerrero, análisis estadístico.
# Ejercicio 1, calcular la frecuencia de type1 y type2 de Pokemones y la frecuencia en habilidades.


import csv # Importo la librería csv
from collections import Counter # Del modulo collections importo Counter (cuenta el numero de veces que se repiten datos en un objeto iterable)

import matplotlib.pyplot as plt
import seaborn as sns

def graficar_frecuencia(frecuencias, titulo):
    # Crear listas de datos
    datos = list(frecuencias.keys())
    valores = list(frecuencias.values())
    
    # Crear el gráfico de barras
    plt.figure(figsize=(10, 6))
    sns.barplot(x=datos, y=valores, palette="viridis")
    
    # Añadir título y etiquetas
    plt.title(titulo)
    plt.xlabel('Datos')
    plt.ylabel('Frecuencia')
    plt.xticks(rotation=90)  # Rotar etiquetas del eje x si son largas
    
    # Mostrar el gráfico
    plt.show()


def procesar_columna(csv_file, columna):
    # Leo el archivo CSV y extrae los datos de la columna especificada
    lista_datos = [] # Creo la variable para guardar los datos de esa columna
    with open(csv_file, mode='r', encoding='utf-8') as archivo: # Abro el CSV en modo lectura
        lector_csv = csv.DictReader(archivo, delimiter=',') # Leo cada fila del CSV y la guardo en un diccionario
        for fila in lector_csv:
            lista_datos.append(fila[columna])  # Añado los datos de la columna especificada a la lista de datos

    contador_frecuencias = Counter(lista_datos) # Cuento las repeticiones de cada dato único en la lista
    
    return contador_frecuencias # retorno la lista de datos, y las frecuencias de cada dato en esa columna

# Calcula la frecuencia relativa de cada dato en la columna
def calcular_frecuenciaRelativa(frecuencias):
    lista_frecuencias = frecuencias.values()
    total_datos = 0
    acum_relativa = 0
    frecuencias_relativas = {}
    for frecuencia in lista_frecuencias:
        total_datos += frecuencia
    
    for dato,frecuencia in frecuencias.items():
        frecuencia_relativa = frecuencia / total_datos
        frecuencias_relativas[dato] = frecuencia_relativa
        acum_relativa += frecuencia_relativa # Acumulador de frecuencias relativas

    return frecuencias_relativas, acum_relativa

def mostrar_analisis(csv_file, columna):
    # Asigno los valores retornados en el mismo orden 
    frecuencias = procesar_columna(csv_file, columna)
    
    # Muestro los resultados:
    print(f"Datos en la columna '{columna}':")
    print(f"\nFrecuencia de cada dato de {columna}:")
    cont1 = 1 # contadores
    cont2 = 1
    for dato, frecuencia in frecuencias.items():
        print(f"{cont1}. {dato}: {frecuencia}")
        cont1 += 1

    frecuencias_relativas, acum_relativa = calcular_frecuenciaRelativa(frecuencias)
    
    print(f"\nFrecuencia relativa de cada dato de {columna}:")
    for dato, frecuencia_relativa in frecuencias_relativas.items():
        print(f"{cont2}. {dato}: {frecuencia_relativa}")
        cont2 += 1
    print(f'Suma de las frecuencias relativas: {acum_relativa}')
    
    # Encuentro la clave asociada al valor máximo y mínimo
    frecuencia_maxima = max(frecuencias, key=frecuencias.get)
    frecuencia_minima = min(frecuencias, key=frecuencias.get)

    # Obtengo los valores máximo y mínimo usando las claves encontradas
    valor_maximo = frecuencias[frecuencia_maxima]
    valor_minimo = frecuencias[frecuencia_minima]

    # Creo un nuevo diccionario con los resultados
    frecuencia_max_min = {
        'frecuencia_maxima': (frecuencia_maxima, valor_maximo),
        'frecuencia_minima': (frecuencia_minima, valor_minimo)
    }

    # Imprimo el nuevo diccionario
    for clave, (key, value) in frecuencia_max_min.items():
        print(f"{clave} ({key}): {value}")
    
    graficar_frecuencia(frecuencias, f'Frecuencia de {columna}')



# Llamo a la función que muestra los analisis
ver_analisis = input("Seleccione el analisis de frecuencia que desea ver \n --> type1 |1| type2 |2| abilities |3| : ") # Pulsar el num de opción

if ver_analisis == '1':
    ('DBPokemons.csv', 'type1') # Frecuencias de la columna type1

elif ver_analisis == '2':
    mostrar_analisis('DBPokemons.csv', 'type2') # Frecuencias de la columna type2

elif ver_analisis == '3':
    mostrar_analisis('DBPokemons.csv', 'abilities') # Frecuencias de la columna abilities

else:
    print('Opción invalida.')

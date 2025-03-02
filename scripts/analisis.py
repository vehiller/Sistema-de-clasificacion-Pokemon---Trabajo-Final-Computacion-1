# Análisis estadístico desarrollado por Alirio
cat("Aquí se realizarán los cálculos y gráficos.\n")
# Parte desarrollada por Alirio Guerrero, análisis estadístico del 1 al 5
# Ejercicio 1, calcular la frecuencia de type1 y type2 de Pokemones y la frecuencia en habilidades.


import csv # Importo la librería csv
from collections import Counter # Del modulo collections importo Counter (cuenta el numero de veces que se repiten datos en un objeto iterable)

def procesar_columna(csv_file, columna):
    # Leo el archivo CSV y extrae los datos de la columna especificada
    lista_datos = [] # Creo la variable para guardar los datos de esa columna
    with open(csv_file, mode='r', encoding='utf-8') as archivo: # Abro el CSV en modo lectura
        lector_csv = csv.DictReader(archivo, delimiter=';') # Leo cada fila del CSV y la guardo en un diccionario
        for fila in lector_csv:
            lista_datos.append(fila[columna])  # Añado los datos de la columna especificada a la lista de datos

    contador_frecuencias = Counter(lista_datos) # Cuento las repeticiones de cada dato único en la lista
    
    return lista_datos, contador_frecuencias # retorno la lista de datos, y las frecuencias de cada dato en esa columna

# Creo las variables de la función
csv_file = 'DBPokemons.csv'  # Nombre del archivo CSV
columna = 'type1'  # Columna a analizar

# Asigno los valores retornados en el mismo orden 
lista_datos, frecuencias = procesar_columna(csv_file, columna)

# Muestro los resultados:
print(f"Datos en la columna '{columna}':")
print(lista_datos)
print("\nFrecuencia de cada dato:")
for dato, frecuencia in frecuencias.items():
    print(f"{dato}: {frecuencia}")

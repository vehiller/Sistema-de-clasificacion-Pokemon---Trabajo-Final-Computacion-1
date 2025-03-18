import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Cargar datos del archivo CSV
data = pd.read_csv("DBPokemons.csv", sep=',')

# Diccionario de efectividad ampliado basado en la base de datos
type_effectiveness = {
    "Fuego": {"resistencias": ["Planta", "Hielo", "Bicho", "Acero", "Fuego", "Hada"],
              "debilidades": ["Agua", "Tierra", "Roca"]},
    "Agua": {"resistencias": ["Fuego", "Tierra", "Roca", "Agua", "Acero"],
             "debilidades": ["Planta", "Eléctrico"]},
    "Eléctrico": {"resistencias": ["Eléctrico", "Acero", "Volador"],
                  "debilidades": ["Tierra"]},
    "Planta": {"resistencias": ["Agua", "Tierra", "Eléctrico", "Planta"],
               "debilidades": ["Fuego", "Hielo", "Veneno", "Volador", "Bicho"]},
    "Hielo": {"resistencias": ["Hielo"],
              "debilidades": ["Fuego", "Lucha", "Roca", "Acero"]},
    "Lucha": {"resistencias": ["Bicho", "Roca", "Siniestro"],
              "debilidades": ["Volador", "Psíquico", "Hada"]},
    "Veneno": {"resistencias": ["Planta", "Lucha", "Veneno", "Bicho", "Hada"],
               "debilidades": ["Tierra", "Psíquico"]},
    "Tierra": {"resistencias": ["Veneno", "Roca"],
               "debilidades": ["Agua", "Planta", "Hielo"]},
    "Volador": {"resistencias": ["Planta", "Lucha", "Bicho"],
                "debilidades": ["Eléctrico", "Hielo", "Roca"]},
    "Psíquico": {"resistencias": ["Lucha", "Psíquico"],
                 "debilidades": ["Bicho", "Siniestro", "Fantasma"]},
    "Bicho": {"resistencias": ["Planta", "Lucha", "Tierra"],
              "debilidades": ["Fuego", "Volador", "Roca"]},
    "Roca": {"resistencias": ["Normal", "Fuego", "Veneno", "Volador"],
             "debilidades": ["Agua", "Planta", "Lucha", "Tierra", "Acero"]},
    "Fantasma": {"resistencias": ["Veneno", "Bicho"],
                 "debilidades": ["Siniestro", "Fantasma"]},
    "Dragón": {"resistencias": ["Fuego", "Agua", "Eléctrico", "Planta"],
               "debilidades": ["Hielo", "Dragón", "Hada"]},
    "Siniestro": {"resistencias": ["Fantasma", "Siniestro", "Psíquico"],
                  "debilidades": ["Lucha", "Bicho", "Hada"]},
    "Acero": {"resistencias": ["Normal", "Planta", "Hielo", "Volador", "Psíquico", "Bicho", "Roca", "Dragón", "Acero", "Hada"],
              "debilidades": ["Fuego", "Lucha", "Tierra"]},
    "Hada": {"resistencias": ["Lucha", "Bicho", "Siniestro"],
             "debilidades": ["Veneno", "Acero"]}
}

# Crear un diccionario de puntaje para habilidades basado en habilidades únicas extraídas de la BD
ability_scores = {
    "Adaptability": 40, "Aerilate": 50, "Aftermath": 30, "Analytic": 35, 
    "Anger Point": 20, "Anticipation": 10, "Arena Trap": 50, "Armor Tail": 35, 
    "Aura Break": 20, "Bad Dreams": 40, "Ball Fetch": 5, "Battle Armor": 20,
    "Beads of Ruin": 50, "Berserk": 25, "Big Pecks": 10, "Blaze": 15,
    "Bulletproof": 35, "Cheek Pouch": 10, "Chilling Neigh": 45, "Chlorophyll": 30, 
    "Clear Body": 40, "Cloud Nine": 25, "Color Change": 20, "Commander": 50, 
    "Compound Eyes": 35, "Contrary": 50, "Corrosion": 30, "Costar": 20,
    "Cotton Down": 25, "Cursed Body": 30, "Cute Charm": 15, "Dancer": 30, 
    "Dark Aura": 45, "Dauntless Shield": 50, "Defeatist": 5, "Defiant": 40, 
    "Delta Stream": 50, "Desolate Land": 50, "Disguise": 50, "Download": 45, 
    "Dragon's Maw": 50, "Drizzle": 50, "Drought": 50, "Dry Skin": 20, 
    "Early Bird": 15, "Earth Eater": 50, "Effect Spore": 25, "Electric Surge": 50,
    "Emergency Exit": 10, "Fairy Aura": 45, "Filter": 40, "Flame Body": 20, 
    "Flare Boost": 30, "Flash Fire": 30, "Flower Gift": 15, "Flower Veil": 10, 
    "Forecast": 15, "Forewarn": 10, "Friend Guard": 10, "Frisk": 15, 
    "Full Metal Body": 50, "Fur Coat": 50, "Gale Wings": 40, "Gluttony": 20, 
    "Good as Gold": 50, "Gooey": 30, "Grassy Surge": 50, "Grim Neigh": 45, 
    "Guard Dog": 30, "Guts": 40, "Hadron Engine": 50, "Harvest": 35, 
}

# Función para calcular puntaje de efectividad de tipos
def calculate_type_score(type1, type2):
    resistencias = set()
    debilidades = set()
    for t in [type1, type2]:
        if pd.isna(t): continue
        resistencias.update(type_effectiveness.get(t, {}).get("resistencias", []))
        debilidades.update(type_effectiveness.get(t, {}).get("debilidades", []))
    return len(resistencias) - len(debilidades)

# Calcular BST
data["BST"] = data[["hp", "atk", "def", "spatk", "spdef", "speed"]].sum(axis=1)

# Calcular Puntaje Tipos
data["Puntaje Tipos"] = data.apply(lambda x: calculate_type_score(x["type1"], x["type2"]), axis=1)

# Calcular Puntaje Habilidad
data["Puntaje Habilidad"] = data["abilities"].apply(
    lambda x: sum(ability_scores.get(ab.strip(), 0) for ab in str(x).split()) if pd.notna(x) else 0
)

# Calcular Competitividad
data["Competitividad"] = data["BST"] + (data["Puntaje Tipos"] * 10) + data["Puntaje Habilidad"]

# Mostrar los 10 Pokémon más competitivos
top_10 = data.sort_values("Competitividad", ascending=False)[["name", "type1", "type2", "abilities", "Competitividad"]].head(10)
print(top_10)

plt.figure(figsize=(12, 6))
sns.barplot(
    x="Competitividad",
    y="name",
    data=top_10,
    palette="viridis"
)

# Detalles del gráfico
plt.title("Top 10 Pokémon más competitivos", fontsize=16)
plt.xlabel("Puntaje de Competitividad", fontsize=12)
plt.ylabel("Nombre del Pokémon", fontsize=12)
plt.tight_layout()

# Mostrar gráfico
plt.show()
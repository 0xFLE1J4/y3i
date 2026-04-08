#!/bin/bash

WALLPAPER_DIR="$HOME/.local/share/yi3/wallpaper"
CURRENT_FILE="$HOME/.current_wallpaper"

# Liste tous les wallpapers
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | sort)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "Aucun wallpaper trouvé dans $WALLPAPER_DIR"
    exit 1
fi

# Lit le wallpaper actuel
if [ -f "$CURRENT_FILE" ]; then
    CURRENT=$(cat "$CURRENT_FILE")
else
    CURRENT=""
fi

# Trouve l'index du wallpaper actuel
CURRENT_INDEX=-1
for i in "${!WALLPAPERS[@]}"; do
    if [ "${WALLPAPERS[$i]}" = "$CURRENT" ]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Passe au suivant
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPERS[@]} ))
NEXT="${WALLPAPERS[$NEXT_INDEX]}"

# Applique le wallpaper
feh --no-fehbg --bg-fill "$NEXT"

# Sauvegarde le wallpaper actuel
echo "$NEXT" > "$CURRENT_FILE"

# Met à jour .fehbg pour le prochain démarrage
echo "#!/bin/sh" > ~/.fehbg
echo "feh --no-fehbg --bg-fill '$NEXT'" >> ~/.fehbg
chmod +x ~/.fehbg

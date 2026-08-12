#!/usr/bin/env bash
set -euo pipefail

src=${1:-/mnt/c/Users/dave/Downloads}
out=${2:-social/tiktok/2026-eleven-shows}
logo=${3:-assets/images/standup-logo-round.png}

mkdir -p "$out"

font_regular=$(fc-match -f '%{file}\n' 'Montserrat:style=Regular' | head -n 1)
font_bold=$(fc-match -f '%{file}\n' 'Montserrat:style=Bold' | head -n 1)

make_slide() {
  local number=$1 file=$2 name=$3 title=$4
  local output
  slug=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-' | sed 's/^-//; s/-$//')
  output=$(printf '%s/%02d-%s.jpg' "$out" "$number" "$slug")

  magick "$src/$file" \
    \( -size 1080x610 gradient:'#00000000-#000000e8' \) -gravity south -composite \
    -gravity northwest \
    -fill '#e31b23' -draw 'roundrectangle 58,965 76,1237 9,9' \
    -font "$font_bold" -pointsize 70 -fill '#ffd52a' \
    -annotate +108+972 "$name" \
    \( -size 850x150 -background none -gravity northwest \
       -font "$font_regular" -pointsize 43 -fill white caption:"$title" \) \
    -gravity northwest -geometry +108+1065 -composite \
    -font "$font_bold" -pointsize 24 -fill '#ffd52a' \
    -annotate +108+1260 'STANDUP.CO.UK' \
    -quality 94 "$output"
}

make_card() {
  local output=$1 heading=$2 subheading=$3
  magick -size 1080x1350 radial-gradient:'#78131b-#120306' \
    \( "$logo" -resize 390x390 \) -gravity north -geometry +0+115 -composite \
    -gravity north -font "$font_bold" -fill '#ffd52a' -pointsize 76 \
    -size 920x230 -annotate +0+575 "$heading" \
    \( -size 850x210 -background none -gravity center \
       -font "$font_regular" -fill white -pointsize 44 caption:"$subheading" \) \
    -gravity north -geometry +0+845 -composite \
    -font "$font_bold" -fill '#ffd52a' -pointsize 34 \
    -annotate +0+1218 'STANDUP.CO.UK' \
    -quality 94 "$output"
}

make_card "$out/01-opening-card.jpg" \
  '11 EDINBURGH FRINGE\nCOMEDY SHOWS' \
  'we want to see in 2026'

make_slide 2  'AhirShah_TT.png'          'Ahir Shah'        'Golden'
make_slide 3  'Ania Magliano-TT.png'     'Ania Magliano'    'Peach Fuzz'
make_slide 4  'kristen-schaal-TT.png'    'Kristen Schaal'   'The Legend of Crystal Shell'
make_slide 5  'LarryDean_TT.png'          'Larry Dean'       'Hellbent'
make_slide 6  'Nish-Kumar-TT.png'         'Nish Kumar'       'Angry Humour From a Really Nice Guy'
make_slide 7  'olga-koch-TT.png'          'Olga Koch'        'Fat Tom Cruise'
make_slide 8  'paddy-young-TT.jpg'        'Paddy Young'      'Will Sir Be Laughing Alone?'
make_slide 9  'jack-dee-TT.png'           'Jack Dee'         "Jack's Joke Show"
make_slide 10 'ayaode-bamgboye-TT.png'    'Ayoade Bamgboye'  'Small Talk'
make_slide 11 'Lara-Ricote-TT.png'        'Lara Ricote'      'INKLING'
make_slide 12 'Rose-Matafeo-TT.png'       'Rose Matafeo'     'Work in Progress Morning Hour'

make_card "$out/13-closing-card.jpg" \
  'MORE EDINBURGH\nCOMEDY COVERAGE' \
  'Read the full preview and follow our Fringe coverage'

magick montage "$out"/[0-9][0-9]-*.jpg -thumbnail 216x270 -tile 4x4 -geometry +8+8 \
  -background '#111111' "$out/contact-sheet.jpg"

printf 'Created carousel in %s\n' "$out"

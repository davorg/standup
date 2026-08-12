#!/usr/bin/env bash
set -euo pipefail

reviews_file=${1:-reviews/2026/edinburgh/index.md}
out=${2:-social/tiktok/2026-edinburgh-reviews}
source_dir=${3:-$out/source}
logo=${4:-assets/images/standup-logo-round.png}
mkdir -p "$out"

font_regular=$(fc-match -f '%{file}\n' 'Montserrat:style=Regular' | head -n 1)
font_bold=$(fc-match -f '%{file}\n' 'Montserrat:style=Bold' | head -n 1)
font_stars=$(fc-match -f '%{file}\n' 'DejaVu Sans:style=Bold' | head -n 1)
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

make_card() {
  local output=$1 heading=$2 subheading=$3
  magick -size 1080x1350 radial-gradient:'#78131b-#120306' \
    \( "$logo" -resize 390x390 \) -gravity north -geometry +0+105 -composite \
    \( -size 920x240 -background none -gravity center -font "$font_bold" -fill '#ffd52a' -pointsize 76 caption:"$heading" \) \
    -gravity north -geometry +0+555 -composite \
    \( -size 850x180 -background none -gravity center -font "$font_regular" -fill white -pointsize 43 caption:"$subheading" \) \
    -gravity north -geometry +0+855 -composite -gravity north \
    -font "$font_bold" -fill '#ffd52a' -pointsize 34 -annotate +0+1215 'STANDUP.CO.UK' -quality 94 "$output"
}

make_review_slide() {
  local number=$1 slug=$2 title=$3 performers=$4 rating=$5 quote=$6 image=$7
  local output stars full has_half empty
  output=$(printf '%s/%02d-%s.jpg' "$out" "$number" "$slug")
  full=${rating%.*}; has_half=0; [[ $rating == *.5 ]] && has_half=1
  empty=$((5 - full - has_half)); stars=$(printf '★%.0s' $(seq 1 "$full"))
  (( has_half )) && stars+='½'; (( empty )) && stars+=$(printf '☆%.0s' $(seq 1 "$empty"))
  magick "$image" -resize '1080x1350^' -gravity center -extent 1080x1350 -blur 0x28 -modulate 55,70,100 \
    \( -size 1080x1350 xc:'#12030666' \) -compose over -composite \
    \( "$image" -resize '760x760' -bordercolor white -border 8 \) -gravity north -geometry +0+55 -compose over -composite \
    \( -size 1080x720 gradient:'#00000000-#120306fc' \) -gravity south -compose over -composite -gravity northwest \
    -fill '#e31b23' -draw 'roundrectangle 54,785 70,1255 8,8' \
    \( -size 900x58 -background none -gravity west -font "$font_bold" -pointsize 31 -fill '#ffd52a' caption:"$performers" \) \
    -gravity northwest -geometry +98+785 -compose over -composite \
    \( -size 900x145 -background none -gravity northwest -font "$font_bold" -pointsize 54 -fill white caption:"$title" \) \
    -gravity northwest -geometry +98+845 -compose over -composite \
    -font "$font_stars" -pointsize 48 -fill '#ffd52a' -annotate +98+1005 "$stars" \
    \( -size 880x170 -background none -gravity northwest -font "$font_regular" -pointsize 34 -fill white caption:"“$quote”" \) \
    -gravity northwest -geometry +98+1060 -compose over -composite \
    -font "$font_bold" -pointsize 25 -fill '#ffd52a' -annotate +98+1278 'STANDUP.CO.UK' -quality 94 "$output"
}

make_card "$out/01-opening-card.jpg" $'OUR FIRST EDINBURGH\nREVIEWS ARE IN' 'More reviews coming throughout the Fringe'
ruby -ryaml -rbase64 -e '
  yaml = File.read(ARGV[0]).split(/^---\s*$\n/, 3)[1]
  YAML.safe_load(yaml)["reviews"].select { |r| r["rating"] && r["text"]&.any? }.each do |r|
    f=[r["link"].split("/").last,r["title"],r["performers"].join(" & "),r["rating"].to_s,r.fetch("carousel_text")]
    puts f.map { |v| Base64.strict_encode64(v) }.join("\t")
  end
' "$reviews_file" > "$work_dir/reviews.tsv"

number=2
while IFS=$'\t' read -r a b c d e; do
  slug=$(printf %s "$a"|base64 -d); title=$(printf %s "$b"|base64 -d); performers=$(printf %s "$c"|base64 -d)
  rating=$(printf %s "$d"|base64 -d); quote=$(printf %s "$e"|base64 -d)
  case "$slug" in
    olga-koch-fat-tom-cruise) image="$source_dir/olga-koch.jpg" ;;
    ele-mckenzie-bringing-it-all-back-home) image="$source_dir/ele-mckenzie.jpg" ;;
    armageddon-outta-here) image="$source_dir/armageddon-outta-here.jpg" ;;
    lilla-multipass-woman-33) image="$source_dir/woman-33.jpg" ;;
    daniel-petrie-and-valeria-vulpe) image="$source_dir/daniel-petrie-valeria-vulpe.jpg" ;;
    jules-oakes-fragile) image="$source_dir/jules-oakes.jpg" ;;
    *) printf 'No image configured for %s\n' "$slug" >&2; exit 1 ;;
  esac
  make_review_slide "$number" "$slug" "$title" "$performers" "$rating" "$quote" "$image"
  number=$((number + 1))
done < "$work_dir/reviews.tsv"
make_card "$out/$(printf '%02d' "$number")-closing-card.jpg" $'MORE EDINBURGH\nREVIEWS COMING SOON' 'Read the latest at standup.co.uk/reviews/2026/edinburgh/'
magick montage "$out"/[0-9][0-9]-*.jpg -thumbnail 216x270 -tile 3x3 -geometry +8+8 -background '#111111' "$out/contact-sheet.jpg"
printf 'Created %d-slide carousel in %s\n' "$number" "$out"

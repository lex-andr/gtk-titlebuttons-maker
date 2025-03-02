#!/bin/bash

#- Output directory
OUTPUT_DIR="tikz-made-buttons"
mkdir -p "$OUTPUT_DIR"

#- Button actions and colors
declare -A COLORS=(
    [close]="closecolor"
    [maximize]="maximcolor"
    [minimize]="minimcolor"
    [restore]="maximcolor"
)

#- Button parameters
STATES=("" "-active" "-backdrop")
SIZES=(16 32)
HOVER=("" "-hover")

#- Function to create a LaTeX file and compile it
generate_button() {
    local action=$1 color=$2 state=$3 hover=$4 size=$5 
    local tex_file="drawing_buttons.tex"

    #- Set a color for the backdrop state
    [[ "$state" == "-backdrop" ]] && color="backdcolor"

    #- Define the scale based on size
    
    local scale=""
    [[ "$size" -eq 32 ]] && scale="@2"

    #- Create the LaTeX file
    #
    cat <<EOF > "$tex_file"
\\documentclass[tikz, border=2pt, convert={density=150,size=${size}x${size},outfile=${OUTPUT_DIR}/titlebutton-${action}${state}${hover}-dark${scale}.png}]{standalone}
\\usepackage{xcolor}

\\definecolor{closecolor}{HTML}{FF5555}
\\definecolor{minimcolor}{HTML}{F1FA8C}
\\definecolor{maximcolor}{HTML}{50FA7B}
\\definecolor{backdcolor}{HTML}{6272A4}

\\usetikzlibrary{shapes.geometric}
\\tikzset{
    rubberduck/.style={
        draw=red!50, shape=isosceles triangle, fill=red!50, 
        minimum height=1, minimum width=2, shape border rotate=#1, 
        isosceles triangle stretches, inner sep=0pt
    },
    rubber/.style={rubberduck=+60},
    ducky/.style={rubberduck=-90}
}

\\begin{document}
\\begin{tikzpicture}[ultra thick,every text node part/.style={align=center}]
    \\draw[${color}, fill=${color}] (0,0) circle (0.4);
EOF

    #- Add a drawing based on the action
    if [[ "$state" = "-active" || "$hover" = "-hover" ]]; then
        case "$action" in
            close)
                cat <<EOF >> "$tex_file"
    \\draw[black, line width=1.2mm] (-0.16, 0.16) -- (0.16, -0.16);
    \\draw[black, line width=1.2mm] (-0.16, -0.16) -- (0.16, 0.16);
EOF
                ;;
            maximize)
                cat <<EOF >> "$tex_file"
    \\node[fill=black, isosceles triangle, isosceles triangle apex angle=90, 
          minimum size=6, rotate=45, inner sep=0pt] at (0.1,0.1){};
    \\node[fill=black, isosceles triangle, isosceles triangle apex angle=90, 
          minimum size=6, rotate=225, inner sep=0pt] at (-0.1,-0.1){};
EOF
                ;;
            minimize)
            	cat <<EOF >> "$tex_file"
    \\draw[black, ultra thick] (-0.2, 0.02) -- (0.2, 0.02);
    \\draw[black, ultra thick] (-0.2, -0.02) -- (0.2, -0.02);
EOF
                ;;
            restore)
                cat <<EOF >> "$tex_file"
    \\node[fill=black, isosceles triangle, isosceles triangle apex angle=90, 
          minimum size=5, rotate=225, inner sep=0pt] at (0.1,0.1){};
    \\node[fill=black, isosceles triangle, isosceles triangle apex angle=90, 
          minimum size=5, rotate=45, inner sep=0pt] at (-0.1,-0.1){};
EOF
                ;;
        esac
    fi

    echo '\end{tikzpicture}' >> "$tex_file"
    echo '\end{document}' >> "$tex_file"

    #- Compile to generate the PNG file
    pdflatex -shell-escape -interaction=batchmode "$tex_file" > /dev/null 2>&1
}

#- Generate buttons for each combination of action, state, hovering and size
for button in "${!COLORS[@]}"; do
    for state in "${STATES[@]}"; do
        for hover in "${HOVER[@]}"; do
            for size in "${SIZES[@]}"; do
                [[ "$state" == "-active" && "$hover" == "-hover" ]] && continue
                
                generate_button "$button" "${COLORS[$button]}" "$state" "$hover" "$size"
            done
        done
    done
done

#- Clean up auxiliary files
rm -f *.aux *.log *.tex *.pdf

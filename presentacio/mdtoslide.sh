#! /bin/bash
# Andrés Felipe Usma Montenegro
# 2ASIX
# Script per convertir MD a Slide
#----------------------------------------------------------

pandoc \
	--standalone \
	--to=dzslides \
	--incremental \
	--css=style.css \
	--output=ELK.html \
ELK.md

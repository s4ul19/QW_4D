.PHONY: all preparar breve

all:
	latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex

preparar:
	python3 preparar_figuras.py

breve:
	pdflatex -interaction=nonstopmode -halt-on-error -jobname=presentacion_breve '\AtBeginDocument{\apendicefalse}\input{main.tex}'
	pdflatex -interaction=nonstopmode -halt-on-error -jobname=presentacion_breve '\AtBeginDocument{\apendicefalse}\input{main.tex}'

---
version: alpha
name: Nombre del sistema visual
description: Sistema visual para que agentes de IA generen interfaces coherentes con esta marca.
colors:
  primary: "#2E2F57"
  secondary: "#5F658A"
  tertiary: "#C0167B"
  neutral: "#F3F2F1"
  surface: "#FFFFFF"
  on-primary: "#FFFFFF"
  on-surface: "#1E2030"
typography:
  headline-lg:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 40px
    fontWeight: "700"
    lineHeight: 48px
    letterSpacing: -0.02em
  title-md:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 20px
    fontWeight: "600"
    lineHeight: 28px
  body-md:
    fontFamily: "Source Sans 3"
    fontSize: 16px
    fontWeight: "400"
    lineHeight: 24px
  label-sm:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 12px
    fontWeight: "600"
    lineHeight: 16px
    letterSpacing: 0.04em
rounded:
  sm: 6px
  md: 12px
  lg: 20px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
components:
  button-primary:
    backgroundColor: "{colors.tertiary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.md}"
    padding: 12px
  card-default:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    padding: "{spacing.lg}"
---

## Overview

Describe aqui el caracter visual general. Explica que sensacion debe transmitir la interfaz, que evitar y que nivel de expresividad visual se busca.

## Colors

Explica el papel de cada color. Indica cual domina, cual solo se usa para acciones y cual sirve de soporte o fondo.

## Typography

Aclara jerarquia, tono y usos. Indica cuando una tipografia es para titulares, cuerpo, datos o etiquetas.

## Layout

Documenta grid, anchos maximos, ritmos de espaciado, margenes, densidad y comportamiento responsive.

## Elevation & Depth

Explica sombras, capas, transparencias, bordes o ausencia de relieve si el sistema es plano.

## Shapes

Documenta radios, esquinas, tratamiento de contenedores y si el lenguaje es mas rigido o mas organico.

## Components

Describe como deben verse y comportarse botones, cards, inputs, tablas, modales o cualquier componente critico.

## Do's and Don'ts

- Haz: mantener el color acento reservado para acciones primarias.
- Haz: respetar la escala de espaciado definida.
- No hagas: mezclar tipografias fuera de los tokens definidos.
- No hagas: inventar variantes de componente sin relacionarlas con tokens existentes.

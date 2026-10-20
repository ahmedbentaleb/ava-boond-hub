#!/usr/bin/env python3
"""Recopie la todo méthodique du BRAIN sur la page « À faire » du hub.

Usage (depuis le dossier du hub) :  python -X utf8 outils/recopier_todo.py
Lit   : ../../_ops/TODO_METHODIQUE_2026-10-18.html
Écrit : todo.html  (même mise en page ; on ajoute seulement : pas de cache, barre propre masquée dans le hub, et les deux compteurs CODÉ / JUGÉ sous les chiffres de tête)
"""
import os, re, sys
HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import compteurs_conformite as cc
s = open(os.path.join(HUB, "..", "..", "_ops", "TODO_METHODIQUE_2026-10-18.html"), encoding="utf-8").read()
if 'http-equiv="Cache-Control"' not in s:
    s = s.replace('<meta charset="utf-8">', '<meta charset="utf-8"><meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"><meta http-equiv="Pragma" content="no-cache"><meta http-equiv="Expires" content="0">', 1)
if "dans-hub" not in s:
    s = s.replace("</head>", '<style>.dans-hub .nav{display:none}</style><script>if(self!==top)document.documentElement.classList.add("dans-hub")</script></head>', 1)
# la todo du BRAIN porte déjà deux cartes provisoires (≈ codés, jugés) : on les retire, les deux compteurs du hub les remplacent
s = re.sub(r'<div class="chiffre"><b>[^<]*</b><span>[^<]*écarts (?:CODÉS|JUGÉS)[^<]*</span></div>\s*', '', s)
import datetime
_J = ["lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche"]; _n = datetime.datetime.now()
s = re.sub(r"Mis à jour le [^(]*\(heure de Casablanca\)", "Mis à jour le %s %s à %s (heure de Casablanca)" % (_J[_n.weekday()], _n.strftime("%d/%m/%Y"), _n.strftime("%Hh%M")), s, count=1)
bloc = cc.bloc_html()
i = s.find('<div class="chiffres">')
j = s.find('<div class="bloc">', i) if i >= 0 else -1
if j > 0: s = s[:j] + bloc + "\n" + s[j:]
else: print("attention : repère introuvable, compteurs non insérés")
open(os.path.join(HUB, "todo.html"), "w", encoding="utf-8", newline="").write(s)
print("todo.html écrite")

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
s = s.replace('objectif <b>95 %</b>', 'objectif <b>100 %</b>').replace('jusqu’à 95 %', 'jusqu’à 100 %')
# D-424 : un seul gros chiffre, le prudent du nouveau tableau ; l'ancien passe en petit
import json as _json
_nj = _json.load(open(os.path.join(HUB, "conformite_nouveau.json"), encoding="utf-8"))
_bas = _nj.get("bas_txt") or ("%.0f" % _nj["bas"]); _reste = _nj["points"][-1].get("ecarts", ""); _haut = ("%.0f" % _nj["points"][-1]["note"])
_old = _json.load(open(os.path.join(HUB, "conformite_historique.json"), encoding="utf-8"))[-1]["note"]
_h = _json.load(open(os.path.join(HUB, "conformite_historique.json"), encoding="utf-8"))[-1]
_mesure = "%s, %s" % (_h.get("label", "").replace("campagne ", "campagne "), _h.get("heure", ""))
# la carte de tête est RECALCULÉE à chaque recopie (plus de valeur écrite à la main dans la to-do du BRAIN, quel que soit son texte)
s = re.sub(r'<div class="chiffre"><b>[^<]*</b><span>[^<]*conformité à Boond[^<]*</span></div>',
    '<div class="chiffre"><b>%s %%</b><span>d’Ava ressemble à Boond (chiffre prudent) ; peut monter jusqu’à %s %% quand les tests seront resserrés ; objectif 100 %%. Mesure : %s. Ancienne façon de compter (les écrans neufs comptaient 0), gardée pour l’historique : %s %%</span></div>' % (_bas, _haut, _mesure, ("%.1f" % _old).replace(".", ",")), s, count=1)
s = s.replace('<p class="compte">', '<p class="compte" style="font-weight:600">Aujourd’hui Ava ressemble à Boond à %s %% ; la cible est 100 %% des éléments mesurables. Il reste %s différences à fermer.</p><p class="compte" style="font-weight:400;font-size:13px;color:var(--t2)">Les éléments qu’on ne peut pas vérifier chez Boond (module facturation absent du compte, envois réels de mails, PDF à déposer) sont listés à part avec la raison.</p>' % (_bas, _reste) + chr(10) + '<p class="compte">', 1)
bloc = cc.bloc_html()
i = s.find('<div class="chiffres">')
j = s.find('<div class="bloc">', i) if i >= 0 else -1
if j > 0: s = s[:j] + bloc + "\n" + s[j:]
else: print("attention : repère introuvable, compteurs non insérés")
open(os.path.join(HUB, "todo.html"), "w", encoding="utf-8", newline="").write(s)
print("todo.html écrite")

#!/usr/bin/env python3
"""Dashboard « matching avec Boond » : écrit dashboard.html (8 cartes max) et matching.html (détail).

Usage (depuis le dossier du hub) :  python -X utf8 outils/matching.py
Lit   : matching.json (cartes, versions en ligne, ce qui reste). Reprend l'en-tête et le CSS du dashboard existant.
Écrit : dashboard.html, matching.html ; heure de mise à jour dans index.html (horloge de la machine = Casablanca).
"""
import json, os, re, datetime
HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
rd = lambda p: open(os.path.join(HUB, p), encoding="utf-8").read()
wr = lambda p, s: open(os.path.join(HUB, p), "w", encoding="utf-8", newline="").write(s)
M = json.loads(rd("matching.json"))
J = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]; n = datetime.datetime.now()
STAMP = "Mis à jour le %s %s à %s (heure de Casablanca)" % (J[n.weekday()], n.strftime("%d/%m/%Y"), n.strftime("%Hh%M"))

dash0 = rd("dashboard.html")
entete = dash0[:dash0.index("<main>")]
pet = lambda p: ('<span style="font-size:12px;color:var(--t3)">%s</span>' % p) if p else ""
cartes = ['<div class="dc dc-ok dc-bande"><b>%s</b><span>%s</span></div>' % (M["bande"]["titre"], M["bande"]["texte"])]
cartes += ['<div class="dc"><b>%s</b><span>%s</span>%s</div>' % (c["v"], c["l"], pet(c["p"])) for c in M["cartes"]]
assert len(cartes) <= 8
maj = '<p class="sous" style="text-align:center;color:var(--t3)">%s</p>' % STAMP
wr("dashboard.html", entete + '<main><div class="dgrid">' + "".join(cartes) + '</div>' + maj +
   '<p class="sous" style="text-align:center"><a href="matching.html">Détail du matching</a> · <a href="detail.html">Détail de la conformité</a></p></main></body></html>')

lignes = lambda rows: "".join("<tr>" + "".join("<td>%s</td>" % c for c in r) + "</tr>" for r in rows)
tab = lambda tete, rows: '<table class="tb"><thead><tr>%s</tr></thead><tbody>%s</tbody></table>' % ("".join("<th>%s</th>" % t for t in tete), lignes(rows))
corps = ('<main><h2>Matching avec Boond</h2>'
         + tab(["Ce qu’on compare", "Matching", "Détail"], [[c["l"].replace("Matching Boond · ", ""), "<b>%s</b>" % c["v"], c["p"]] for c in M["cartes"][:5]])
         + '<h2>En ligne</h2>' + tab(["Version", "Date", "Heure", "Coupure"], M["en_ligne"])
         + '<h2>Ce qui reste (V1.18)</h2>' + tab(["Chantier", "Reste"], M["reste"])
         + maj + '<p class="sous" style="text-align:center"><a href="dashboard.html">Dashboard</a></p></main></body></html>')
css = ('<style>.tb{width:100%;border-collapse:collapse;margin:8px 0 24px}.tb th,.tb td{border-bottom:1px solid var(--bord);padding:9px 10px;text-align:left;font-size:15px;color:var(--t1)}'
       '.tb th{color:var(--t3);font-weight:600;font-size:13px}h2{color:var(--t1)}</style>')
wr("matching.html", entete.replace("<title>Dashboard</title>", "<title>Matching</title>").replace("</head>", css + "</head>") + corps)

ix = rd("index.html")
ix = re.sub(r"Mis à jour le [^(]*\(heure de Casablanca\)", STAMP, ix, count=1)
if 'page:matching.html' not in ix:
    ix = ix.replace('{ v: "page:detail.html", label: "Détail", star: 1 },', '{ v: "page:detail.html", label: "Détail", star: 1 },\n      { v: "page:matching.html", label: "Matching Boond", star: 1 },', 1)
wr("index.html", ix)
print("ok", STAMP)

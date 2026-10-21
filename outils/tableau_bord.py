#!/usr/bin/env python3
"""Génère la première page du hub (etat.html) en TABLEAU DE BORD : chiffres, tableaux, dates, états. Aucun paragraphe.

Usage (depuis le dossier du hub) :  python -X utf8 outils/tableau_bord.py
Lit   : etat_ligne.json (état en ligne / retour arrière, version, heure, historique, gestes de Hamada)
        conformite_nouveau.json (prudent et règle du Juge, version d'après)
Écrit : etat.html et la bande en haut de index.html (entre <!--BANDE--> et <!--/BANDE-->).
À CHAQUE MISE EN LIGNE : mettre à jour etat_ligne.json (etat, date, heure lue sur la machine, version, conformite,
mises_en_ligne), relancer ce script, pousser : bande VERTE. À chaque retour arrière : "etat": "retour_arriere" -> bande ROUGE.
Heures = horloge de la machine (Casablanca, UTC+0), jamais Node.
"""
import json, os, re, datetime
HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
rd = lambda p: open(os.path.join(HUB, p), encoding="utf-8").read()
fr = lambda x: ("%.1f" % x).replace(".", ",")
L = json.loads(rd("etat_ligne.json")); nj = json.loads(rd("conformite_nouveau.json"))
J = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]; n = datetime.datetime.now()
STAMP = "Mis à jour le %s %s à %s (heure de Casablanca)" % (J[n.weekday()], n.strftime("%d/%m/%Y"), n.strftime("%Hh%M"))

ok = L["etat"] == "en_ligne"
wip = L["etat"] == "en_cours"
if wip:
    BANDE_TXT = "MISE EN LIGNE EN COURS — version %s depuis %s — actuellement en ligne : %s" % (L["mel"]["version"], L["mel"]["depuis"], L["version"])
elif ok:
    BANDE_TXT = "EN LIGNE depuis %s — %s — version %s — conformité %s" % (L["heure"], L["date"], L["version"], L["conformite"])
else:
    BANDE_TXT = "PAS EN LIGNE (retour arrière) — %s à %s — version %s — conformité %s" % (L["date"], L["heure"], L["version"], L["conformite"])
BANDE = '<div class="bande %s" role="status">%s</div>' % ("bande-wip" if wip else ("bande-ok" if ok else "bande-ko"), BANDE_TXT)

pr = nj.get("prochaine") or {}
le = [p for p in nj["points"] if p["label"] == "en ligne"]
le = le[0] if le else nj["points"][-1]
c1, c2 = L["compteurs"]["en_ligne"], L["compteurs"]["apres"]
H = n.strftime("%Hh%M")
def carte(b, libelle, apres=False, ident=None):
    return '<div class="chiffre"%s><b%s>%s</b><span>%s · %s</span></div>' % (' style="border-style:dashed"' if apres else "", (' id="%s"' % ident) if ident else "", b, libelle, H)
cartes = [
  carte("%s" % L["conformite"], "Prudent · en ligne %s · %s" % (L["version"], c1["campagne"])),
  carte("%s %%" % fr(le["note"]), "Règle du Juge · en ligne"),
  carte("%s %%" % fr(pr["bas"]), "Prudent · version d’après · %s" % pr.get("bas_label", c2["campagne"]), True) if pr else "",
  carte("%s %%" % fr(pr["haut"]), "Règle du Juge · version d’après · %s" % c2["campagne"], True) if pr else "",
  carte(c1["resolus"], "Résolus · en ligne"),
  carte(c1["rouges"], "Rouges · en ligne"),
  carte(c1["bloques"], "Bloqués · en ligne"),
  carte(c2["resolus"] if c2["resolus"] is not None else "—", "Résolus · version d’après", True),
  carte(c2["gagnes"], "Gagnés · version d’après", True) if c2.get("gagnes") else "",
  '<div class="chiffre" style="border-style:dashed"><b>⏳</b><span>Prochaine mise en ligne · version d’après · en attente de la n° 35, puis du mot de Hamada · %s</span></div>' % H,
  '<div class="chiffre"><b>7</b><span>Sessions Code en parallèle · %s</span></div>' % H,
  '<div class="chiffre"><b id="c-taches">…</b><span>Tâches faites <span id="c-taches-t"></span></span></div>',
  '<div class="chiffre"><b id="c-ouverts">…</b><span>Défauts ouverts <span id="c-corriges"></span></span></div>',
  '<div class="chiffre"><b id="c-dec">…</b><span>Décisions · dernière <span id="c-dec-d"></span></span></div>',
]
CARTES = '<div class="chiffres" id="chiffres">' + "".join(cartes) + '</div>'
m = re.search(r'<svg viewBox="0 0 620 120"[^>]*aria-label="Courbe du nouveau tableau".*?</svg>', rd("conformite-boond.html"), flags=re.S)
COURBE = ('<h2>Courbe · nouveau tableau (règle du Juge)</h2>\n' + m[0]) if m else ""
ce = L.get("campagne_en_cours")
if ce:
    tab_ce = '<table><tr><th>Campagne en cours</th><th>Fin prévue</th><th>État</th></tr><tr><td>%s</td><td>%s</td><td>⏳</td></tr></table>' % (ce["n"], ce["fin"])
else:
    tab_ce = '<table><tr><th>Campagne en cours</th><th>Fin prévue</th><th>État</th></tr><tr><td>aucune</td><td>—</td><td>✅</td></tr></table>'
tab_hist = '<table><tr><th>Date</th><th>Heure</th><th>Version</th><th>Résultat</th></tr>%s</table>' % "".join(
  "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>" % (m_["date"], m_["heure"], m_["version"], m_["resultat"]) for m_ in L["mises_en_ligne"])
tab_att = '<table><tr><th>N°</th><th>Geste de Hamada</th><th>État</th></tr>%s</table>' % "".join(
  "<tr><td>%s</td><td>%s</td><td>%s</td></tr>" % (a_["n"], a_["geste"], a_["etat"]) for a_ in L["attend_hamada"])

det = rd("etat-details.html")
head = det[:det.index("</style>") + len("</style>")]
head = re.sub(r"<title>.*?</title>", "<title>Tableau de bord</title>", head, flags=re.S)
js = det[det.rindex("<script>"):det.rindex("</main>")]
CSS = ('<style>.bande{margin:0 0 18px;padding:14px 16px;border-radius:10px;font-size:18px;font-weight:700;text-align:center;color:#fff}'
       '.bande-ok{background:#1b7f3b;border:2px solid #34D399}.bande-ko{background:#b3261e;border:2px solid #ff6b60}.bande-wip{background:#c26a00;border:2px solid #ffb347}'
       'table{width:100%;border-collapse:collapse;margin:4px 0 16px}th,td{text-align:left;padding:7px 10px;border-bottom:1px solid var(--bord);font-size:15px}'
       'th{color:var(--t2);font-weight:600;font-size:12px;text-transform:uppercase;letter-spacing:.05em}h2{margin-top:22px}.dans-hub .bande{display:none}</style>')
html = (head + CSS + '<script>if(self!==top)document.documentElement.classList.add("dans-hub")</script></head><body><main>\n'
        '<div class="nav"><a href="./" target="_top">← le hub</a></div>\n' + BANDE + '\n<h1>Où en sommes-nous</h1>\n<p class="sous">' + STAMP + '</p>\n'
        + CARTES + '\n' + COURBE + '\n<h2>Mises en ligne</h2>\n' + tab_hist + '\n' + tab_ce + '\n<h2>Attend le mot de Hamada</h2>\n' + tab_att +
        '\n<p class="sous"><a href="etat-details.html">Détails (ancienne vue)</a></p>\n' + js + '</main></body></html>\n')
for _f in ("detail.html", "etat.html"):
    open(os.path.join(HUB, _f), "w", encoding="utf-8", newline="").write(html.replace("<title>Tableau de bord</title>", "<title>Détail</title>").replace("<h1>Où en sommes-nous</h1>", "<h1>Détail</h1>"))

# DASHBOARD : 8 cartes maximum, des chiffres en gros, aucune phrase, aucune courbe, aucun tableau
cz = lambda v: "—" if v is None else v
cc = c2 if c2.get("resolus") is not None else c1
mh = L.get("mot_hamada", {"valeur": "NON", "precision": ""})
ce_ = L.get("campagne_en_cours")
D8 = [
  ('<div class="dc dc-wip dc-bande"><b>MISE EN LIGNE EN COURS</b><span>%s depuis %s</span></div>' % (L["mel"]["version"], L["mel"]["depuis"])) if wip else ('<div class="dc %s dc-bande"><b>%s</b><span>depuis %s — %s</span></div>' % ("dc-ok" if ok else "dc-ko", "EN LIGNE" if ok else "PAS EN LIGNE", L["heure"], L["date"][:5])),
  '<div class="dc"><b>%s</b><span>Conformité des RUBRIQUES (éléments) · en ligne</span>%s</div>' % (L.get("conformite_courte", L["conformite"]), ('<span style="font-size:12px;color:var(--t3)">%s</span>' % L["conformite_petit"]) if L.get("conformite_petit") else ""),
  '<div class="dc"><b style="font-size:36px;white-space:nowrap">%s / %s</b><span>Version d’après · prudent / règle du Juge</span></div>' % (("%s %%" % fr(pr["bas"])) if pr else "—", ("%s %%" % fr(pr["haut"])) if pr else "—"),
  '<div class="dc"><b>%s</b><span>Écarts résolus</span></div>' % cz(cc["resolus"]),
  '<div class="dc"><b>%s</b><span>Pas de test rouges</span></div>' % cz(cc["rouges"]),
  '<div class="dc"><b>%s</b><span>Pas de test bloqués</span></div>' % cz(cc["bloques"]),
  '<div class="dc"><b>%s</b><span>Campagne en cours · fin %s</span></div>' % ((ce_["n"], ce_["fin"]) if ce_ else ("—", "—")),
  '<div class="dc"><b>%s</b><span>Mot de Hamada attendu · %s</span></div>' % (mh["valeur"], mh.get("precision", "")),
]
# 8 cartes au maximum : une carte vide (pas de version d'après, pas de campagne en cours) cède sa place à la lenteur ou à la disposition
# 8 cartes au maximum : la DISPOSITION se place à côté de la conformité des rubriques ; Lenteur prend la place de la campagne en cours si elle est vide
_dp = L.get("disposition")
if isinstance(_dp, dict):
    D8[2] = '<div class="dc"><b>%s</b><span>%s</span>%s</div>' % (_dp["valeur"], _dp["libelle"], ('<span style="font-size:12px;color:var(--t3)">%s</span>' % _dp["petit"]) if _dp.get("petit") else "")
if not ce_ and L.get("lenteur"):
    D8[6] = '<div class="dc"><b>%s</b><span>%s</span></div>' % (L["lenteur"], L.get("lenteur_libelle", "Lenteur"))
# fusion : pas de test rouges / bloqués sur une seule carte, pour faire place à la carte « version d'après »
_ac = L.get("apres_carte")
if _ac:
    D8[4] = '<div class="dc"><b>%s / %s</b><span>Pas de test rouges / bloqués</span></div>' % (cz(cc["rouges"]), cz(cc["bloques"]))
    D8[5] = None
    D8.insert(2, None)
    D8[2], D8[3] = D8[3], '<div class="dc"><b>%s</b><span>%s</span>%s</div>' % (_ac["valeur"], _ac["libelle"], ('<span style="font-size:12px;color:var(--t3)">%s</span>' % _ac["petit"]) if _ac.get("petit") else "")
    D8 = [x for x in D8 if x]
assert len(D8) <= 8
DCSS = ('<style>main{max-width:900px}.dgrid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:14px;margin:6px 0 22px}'
        '.dc{background:var(--carte);border:1px solid var(--bord);border-radius:14px;padding:22px 20px;text-align:center}'
        '.dc b{display:block;font-size:48px;font-weight:700;line-height:1.1;color:var(--t1)}.dc span{display:block;margin-top:8px;font-size:15px;color:var(--t2)}'
        '.dc-bande b{font-size:40px}.dc-ok{background:#1b7f3b;border-color:#34D399}.dc-ok b,.dc-ok span{color:#fff}.dc-wip{background:#c26a00;border-color:#ffb347}.dc-wip b,.dc-wip span{color:#fff}.dc-ko{background:#b3261e;border-color:#ff6b60}.dc-ko b,.dc-ko span{color:#fff}'
        '@media (max-width:560px){.dc b{font-size:40px}}</style>')
dash = (head.replace("<title>Tableau de bord</title>", "<title>Dashboard</title>") + DCSS +
        '<script>if(self!==top)document.documentElement.classList.add("dans-hub")</script></head><body><main>'
        '<div class="dgrid">' + "".join(D8) + '</div><p class="sous" style="text-align:center"><a href="detail.html">Détail</a></p></main></body></html>')
open(os.path.join(HUB, "dashboard.html"), "w", encoding="utf-8", newline="").write(dash)

ix = rd("index.html")
ix = re.sub(r"Mis à jour le [^(]*\(heure de Casablanca\)", STAMP, ix, count=1)
bande_css = ('<style id="bande-css">.bande{margin:8px 0 10px;padding:12px 14px;border-radius:10px;font-size:16px;font-weight:700;text-align:center;color:#fff}'
             '.bande-ok{background:#1b7f3b;border:2px solid #34D399}.bande-ko{background:#b3261e;border:2px solid #ff6b60}.bande-wip{background:#c26a00;border:2px solid #ffb347}</style>')
if "<!--BANDE-->" not in ix:
    ix = ix.replace('<p class="tete-etat">', '<!--BANDE--><!--/BANDE-->\n    <p class="tete-etat">', 1)
ix = re.sub(r"<!--BANDE-->.*?<!--/BANDE-->", lambda m: "<!--BANDE-->" + BANDE + "<!--/BANDE-->", ix, count=1, flags=re.S)
if 'id="bande-css"' not in ix:
    ix = ix.replace("</head>", bande_css + "</head>", 1)
open(os.path.join(HUB, "index.html"), "w", encoding="utf-8", newline="").write(ix)
print("tableau de bord :", BANDE_TXT, "|", STAMP)

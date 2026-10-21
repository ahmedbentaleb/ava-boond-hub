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
if ok:
    BANDE_TXT = "EN LIGNE depuis %s — %s — version %s — conformité %s" % (L["heure"], L["date"], L["version"], L["conformite"])
else:
    BANDE_TXT = "PAS EN LIGNE (retour arrière) — %s à %s — version %s — conformité %s" % (L["date"], L["heure"], L["version"], L["conformite"])
BANDE = '<div class="bande %s" role="status">%s</div>' % ("bande-ok" if ok else "bande-ko", BANDE_TXT)

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
  carte("%s %%" % fr(pr["bas"]), "Prudent · version d’après · %s" % c2["campagne"], True) if pr else "",
  carte("%s %%" % fr(pr["haut"]), "Règle du Juge · version d’après", True) if pr else "",
  carte(c1["resolus"], "Résolus · en ligne"),
  carte(c1["rouges"], "Rouges · en ligne"),
  carte(c1["bloques"], "Bloqués · en ligne"),
  carte(c2["resolus"] if c2["resolus"] is not None else "—", "Résolus · version d’après", True),
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
       '.bande-ok{background:#1b7f3b;border:2px solid #34D399}.bande-ko{background:#b3261e;border:2px solid #ff6b60}'
       'table{width:100%;border-collapse:collapse;margin:4px 0 16px}th,td{text-align:left;padding:7px 10px;border-bottom:1px solid var(--bord);font-size:15px}'
       'th{color:var(--t2);font-weight:600;font-size:12px;text-transform:uppercase;letter-spacing:.05em}h2{margin-top:22px}.dans-hub .bande{display:none}</style>')
html = (head + CSS + '<script>if(self!==top)document.documentElement.classList.add("dans-hub")</script></head><body><main>\n'
        '<div class="nav"><a href="./" target="_top">← le hub</a></div>\n' + BANDE + '\n<h1>Où en sommes-nous</h1>\n<p class="sous">' + STAMP + '</p>\n'
        + CARTES + '\n' + COURBE + '\n<h2>Mises en ligne</h2>\n' + tab_hist + '\n' + tab_ce + '\n<h2>Attend le mot de Hamada</h2>\n' + tab_att +
        '\n<p class="sous"><a href="etat-details.html">Détails (ancienne vue)</a></p>\n' + js + '</main></body></html>\n')
open(os.path.join(HUB, "etat.html"), "w", encoding="utf-8", newline="").write(html)

ix = rd("index.html")
ix = re.sub(r"Mis à jour le [^(]*\(heure de Casablanca\)", STAMP, ix, count=1)
bande_css = ('<style id="bande-css">.bande{margin:8px 0 10px;padding:12px 14px;border-radius:10px;font-size:16px;font-weight:700;text-align:center;color:#fff}'
             '.bande-ok{background:#1b7f3b;border:2px solid #34D399}.bande-ko{background:#b3261e;border:2px solid #ff6b60}</style>')
if "<!--BANDE-->" not in ix:
    ix = ix.replace('<p class="tete-etat">', '<!--BANDE--><!--/BANDE-->\n    <p class="tete-etat">', 1)
ix = re.sub(r"<!--BANDE-->.*?<!--/BANDE-->", lambda m: "<!--BANDE-->" + BANDE + "<!--/BANDE-->", ix, count=1, flags=re.S)
if 'id="bande-css"' not in ix:
    ix = ix.replace("</head>", bande_css + "</head>", 1)
open(os.path.join(HUB, "index.html"), "w", encoding="utf-8", newline="").write(ix)
print("tableau de bord :", BANDE_TXT, "|", STAMP)

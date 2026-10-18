#!/usr/bin/env python3
"""Construit la page « Conformité à Boond » du hub depuis TABLEAU_CONFORMITE.md.

Usage (depuis le dossier du hub) :  python -I outils/conformite_tableau.py [HHhMM] [--revise="mention"]
--revise : même date et même version, mesure corrigée : la ligne de l'historique est remplacée (avec la mention) au lieu d'en ajouter une.
Lit   : ../../audits-independants/conformite/TABLEAU_CONFORMITE.md
Écrit : conformite-boond.html et conformite_historique.json (une ligne par mesure : date + version).
À chaque livraison : relire le fichier, relancer ce script, pousser. Rien d'exploitable n'y figure.
"""
import re, sys, json, subprocess, os
HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(HUB, "..", "..", "audits-independants", "conformite", "TABLEAU_CONFORMITE.md")
md = open(SRC, encoding="utf-8").read()
args = [a for a in sys.argv[1:] if not a.startswith("--revise=")]
REVISE = next((a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--revise=")), None)
H = args[0] if args else subprocess.run(["date", "+%Hh%M"], capture_output=True, text=True).stdout.strip()
STAMP = f"Mis à jour le dimanche 18/10/2026 à {H} (heure de Casablanca)"

fr = lambda x: x.replace(".", ",")
def pct(t):
    m = re.search(r"([\d.]+)\s*%", t)
    return float(m.group(1)) if m else None

head = re.search(r"\*\*Note globale : ([\d.]+) %\*\* \((\d+) éléments conformes sur (\d+) relevés[^)]*\) · \*\*date : (\d\d/\d\d/\d{4})\*\* · \*\*version d'Ava : (\w+)\*\* · Boond relevé à l'écran du (.+?) · mission", md)
note, conf, tot, date, ver, periode = float(head[1]), int(head[2]), int(head[3]), head[4], head[5], head[6]

def rows(block):
    out = []
    for l in block.splitlines():
        if not l.startswith("|") or set(l.replace("|", "").strip()) <= set("-: "): continue
        c = [x.strip().strip("*").strip() for x in l.strip().strip("|").split("|")]
        out.append(c)
    return out[1:]  # sans l'en-tête

# tableau par type + lignes présents / absents
haut = md[md.index("| Lecture |"): md.index("⭐ **La note est une borne haute**")]
par_type, presents, absents = [], None, None
for c in rows(haut):
    if c[0].startswith("dont écrans présents"): presents = (int(c[1]), int(c[2]), int(c[3]), pct(c[4]))
    elif c[0].startswith("dont écrans absents"): absents = (int(c[1]), int(c[2]), int(c[3]), pct(c[4]))
    elif not c[0].lower().startswith("note globale"): par_type.append((c[0], int(c[1]), int(c[2]), int(c[3]), pct(c[4])))

# tableaux par section
GROUPES = [("Saisie (création, par objet)", "saisie"), ("Fiche (par objet)", "fiche"), ("Cliquable (ce qui se clique)", "cliquable"), ("Actions", "actions"), ("Mails et notifications", "mails")]
sect = {}
for titre, cle in GROUPES:
    a = md.index(f"### {titre}") if f"### {titre}" in md else md.index("### " + titre.split(" (")[0])
    b = md.find("\n### ", a + 5); b = len(md) if b < 0 else b
    lst = []
    for c in rows(md[a:b]):
        nom = c[0]; absent = "écran absent" in c[4]
        sous = nom.lower().startswith("sous-total")
        lst.append((nom, int(c[1]), int(c[2]), int(c[3]), pct(c[4]), absent, sous))
    sect[cle] = lst

# historique
hp = os.path.join(HUB, "conformite_historique.json")
hist = json.load(open(hp, encoding="utf-8")) if os.path.exists(hp) else []
idx = next((i for i, h in enumerate(hist) if h["date"] == date and h["version"] == ver), None)
if idx is None:
    hist.append({"date": date, "note": note, "version": ver, "elements": tot})
elif REVISE:
    hist[idx] = {"date": date, "note": note, "version": ver, "elements": tot, "avant": hist[idx].get("avant", hist[idx]["note"]), "mention": REVISE}
json.dump(hist, open(hp, "w", encoding="utf-8", newline=""), ensure_ascii=False, indent=1)

def bar(p, absent=False):
    if p is None: return '<span class="bar"><i style="width:0"></i></span>'
    cl = "bar ab" if absent else "bar"
    return f'<span class="{cl}"><i style="width:{p:.1f}%"></i></span>'
def ligne(nom, n, e, c, p, absent=False, sous=False):
    b = "<b>" if sous else ""; bb = "</b>" if sous else ""
    ptxt = "—" if p is None else pc(p)
    tag = ' <small>(écran absent)</small>' if absent else ""
    return f'<tr><td>{b}{nom}{bb}{tag}</td><td class="n">{n}</td><td class="n">{e}</td><td class="n">{b}{ptxt}{bb}</td><td class="bc">{bar(p, absent)}</td></tr>'
TH = "<tr><th>Section</th><th class='n'>Relevés</th><th class='n'>Écarts</th><th class='n'>Conforme</th><th></th></tr>"

# réutilise l'en-tête commun (HEAD) défini dans le dossier du hub : copie du style de etat.html
et = open(os.path.join(HUB, "etat.html"), encoding="utf-8").read()
style = re.findall(r"<style>.*?</style>", et, re.S)
HEAD = ('<!doctype html>\n<html lang="fr"><head><meta charset="utf-8"><meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"><meta http-equiv="Pragma" content="no-cache"><meta http-equiv="Expires" content="0"><meta name="viewport" content="width=device-width,initial-scale=1">\n<title>Conformité à Boond</title>\n'
        + "\n".join(style) +
        '\n<script>if(self!==top)document.documentElement.classList.add("dans-hub")</script>\n</head><body><main>\n<div class="nav"><a href="./" target="_top">← le hub</a></div>\n')
EXTRA = """<style>
.note-g{display:flex;align-items:center;gap:22px;flex-wrap:wrap;margin:6px 0 4px}
.note-g .gros{font-size:64px;font-weight:700;line-height:1;color:var(--t1)} .note-g .gros small{font-size:28px;font-weight:600}
.note-g .col{flex:1;min-width:220px} .bar{display:block;height:12px;border-radius:6px;background:var(--bord);overflow:hidden;min-width:90px} .bar i{display:block;height:100%;background:var(--vert);border-radius:6px} .bar.ab i{background:var(--t3)}
.bar.grand{height:20px;border-radius:10px} .bar.grand i{border-radius:10px}
.date{display:inline-block;margin:4px 0 14px;padding:5px 12px;border:1px solid var(--vert);border-radius:8px;color:var(--vert);font-weight:600;font-size:14px}
td.n,th.n{text-align:right;white-space:nowrap} td.bc{width:30%;min-width:100px}
.borne{border-left:4px solid var(--cours);padding:8px 14px;margin:10px 0 16px;background:var(--carte);border-radius:0 8px 8px 0}
.deux2{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin:10px 0}.deux2>div{background:var(--carte);border:1px solid var(--bord);border-radius:10px;padding:12px 14px}
.deux2 b.v{font-size:28px;display:block}
@media (max-width:640px){.deux2{grid-template-columns:1fr}.note-g .gros{font-size:48px}}
</style>"""
def pc(x): return fr("%.1f" % x) + " %"
def hrow(h):
    m = (' <small>(%s : %s → %s)</small>' % (h["mention"], pc(h["avant"]), pc(h["note"]))) if h.get("mention") else ""
    return '<tr><td>%s%s</td><td>%s</td><td class="n">%s</td><td class="n"><b>%s</b></td><td class="bc">%s</td></tr>' % (h["date"], m, h["version"], h["elements"], pc(h["note"]), bar(h["note"]))
def brow(p, n): return '<tr><td>%s</td><td class="n">%s</td><td class="bc">%s</td></tr>' % (n, pc(p), bar(p))
HIST_ROWS = "".join(hrow(h) for h in reversed(hist))
bas = sorted([(p, n) for g in sect.values() for (n, a, e, c, p, ab, s) in g if not ab and not s and p is not None and a > 0])[:5]
cur = next(h for h in hist if h["date"] == date and h["version"] == ver)
MENTION = ('<p class="sous" style="margin:0 0 12px">%s : %s → %s</p>' % (cur["mention"].capitalize(), pc(cur["avant"]), pc(cur["note"]))) if cur.get("mention") else ""
html = HEAD + EXTRA + f'''<h1>Conformité à Boond</h1>
<p class="sous">{STAMP} · à chaque livraison, ce tableau est recalculé et la date de mesure change</p>
<span class="date">Mesurée le {date} sur la version {ver} · Boond relevé à l'écran du {periode}</span>{MENTION}

<div class="note-g"><div class="gros">{fr("%.1f" % note)}<small> %</small></div>
<div class="col"><span class="bar grand"><i style="width:{note:.1f}%"></i></span><p class="sous" style="margin:6px 0 0">{conf} éléments conformes sur {tot} relevés dans Boond</p></div></div>
<p class="borne"><b>C'est une borne haute.</b> Un écart compte pour un seul élément, alors qu'une ligne d'écart en couvre souvent plusieurs (« dix champs absents », « treize écrans »). La vraie conformité est donc probablement un peu plus basse.</p>

<div class="deux2">
<div><b class="v">{pc(presents[3])}</b>des écrans <b>présents chez Ava</b> sont conformes ({presents[2]} éléments sur {presents[0]})</div>
<div><b class="v">{pc(absents[3])}</b>des écrans <b>absents chez Ava</b> : ils n'existent pas encore ({absents[0]} éléments en écart)</div>
</div>

<h2>Par type de lecture</h2>
<table>{TH.replace("Section","Lecture")}{"".join(ligne(a.capitalize(), n, e, c, p) for a, n, e, c, p in par_type)}{ligne("Note globale", tot, tot-conf, conf, note, False, True)}</table>
'''
for titre, cle in GROUPES:
    html += f'<h2>{titre}</h2>\n<table>{TH}{"".join(ligne(n, a, e, c, p, ab, s) for n, a, e, c, p, ab, s in sect[cle])}</table>\n'
html += f'''<h2>Les sections les moins conformes, parmi les écrans qui existent chez Ava</h2>
<table><tr><th>Section</th><th class="n">Conforme</th><th></th></tr>{"".join(brow(p, n) for p, n in bas)}</table>
<h2>L'historique des mesures</h2>
<table><tr><th>Date de mesure</th><th>Version d'Ava</th><th class="n">Éléments relevés</th><th class="n">Conformité</th><th></th></tr>{HIST_ROWS}</table>
<p class="sous">Une nouvelle ligne s'ajoute à chaque livraison. Avec deux mesures ou plus, la courbe se lit directement dans ce tableau.</p>
<h2>Comment c'est compté</h2>
<table><tr><td class="e">1</td><td>Un « élément » est une chose lue dans Boond : un champ, une colonne, un bouton, un onglet, une carte, un message de liste vide, un lien, une entrée de menu.</td></tr>
<tr><td class="e">2</td><td>Chaque écart du rapport compte pour un élément. Conformes = éléments relevés − écarts. Pourcentage = conformes ÷ relevés.</td></tr>
<tr><td class="e">3</td><td>Un écran qui n'existe pas chez Ava vaut 0 %, avec tous ses éléments en écart.</td></tr>
<tr><td class="e">4</td><td>Les éléments qu'on ne peut pas relever sans rien envoyer ni rien modifier dans Boond sont retirés du calcul (35 à ce jour).</td></tr>
<tr><td class="e">5</td><td>Le tableau de bord et ses widgets ne sont pas comptés : c'est le seul écart permis (D-252).</td></tr></table>
</main></body></html>
'''
open(os.path.join(HUB, "conformite-boond.html"), "w", encoding="utf-8", newline="").write(html)
print("ok", note, len(hist), "mesure(s)")

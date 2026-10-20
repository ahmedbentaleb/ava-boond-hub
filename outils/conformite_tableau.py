#!/usr/bin/env python3
"""Construit la page « Conformité à Boond » du hub depuis TABLEAU_CONFORMITE.md.

Usage (depuis le dossier du hub) :  python -I outils/conformite_tableau.py [HHhMM] [--revise="mention"]
--rejeu=<RAPPORT_REJEU.md> --label="campagne n° 2" --heure=22h17 --version="e19afde5" : mesure d'une campagne de Tests (le tableau par section est dans le rapport de rejeu).
--revise : même date et même version, mesure corrigée : la ligne de l'historique est remplacée (avec la mention) au lieu d'en ajouter une.
Lit   : ../../audits-independants/conformite/TABLEAU_CONFORMITE.md
Écrit : conformite-boond.html et conformite_historique.json (une ligne par mesure : date + version).
À chaque livraison : relire le fichier, relancer ce script, pousser. Rien d'exploitable n'y figure.
"""
import re, sys, json, subprocess, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import compteurs_conformite as _cc
HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(HUB, "..", "..", "audits-independants", "conformite", "TABLEAU_CONFORMITE.md")
md = open(SRC, encoding="utf-8").read()
OPT = {a.split("=", 1)[0]: a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--")}
args = [a for a in sys.argv[1:] if not a.startswith("--")]
REVISE = OPT.get("--revise"); REJEU = OPT.get("--rejeu"); LABEL = OPT.get("--label"); HEURE = OPT.get("--heure"); VERSION = OPT.get("--version"); NOTE = OPT.get("--note")
H = args[0] if args else subprocess.run(["date", "+%Hh%M"], capture_output=True, text=True).stdout.strip()
import datetime
_J = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]
_n = datetime.datetime.now()
STAMP = "Mis à jour le %s %s à %s (heure de Casablanca)" % (_J[_n.weekday()], _n.strftime("%d/%m/%Y"), H)

fr = lambda x: x.replace(".", ",")
def pct(t):
    m = re.search(r"([\d.]+)\s*%", t)
    return float(m.group(1)) if m else None

NR = 35
GROUPES = [("Saisie (création, par objet)", "saisie"), ("Fiche (par objet)", "fiche"), ("Cliquable (ce qui se clique)", "cliquable"), ("Actions", "actions"), ("Mails et notifications", "mails")]
if REJEU:
    txt = open(REJEU, encoding="utf-8").read()
    m = re.search(r"APRÈS marquage RÉSOLU \| \*\*([\d.]+) % \((\d+) conformes sur (\d+) relevés", txt)
    note, conf, tot = float(m[1]), int(m[2]), int(m[3])
    dm = re.search(r"(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})_([0-9a-f+]+)", REJEU.replace("\\", "/").split("/")[-2])
    date = "%s/%s/%s" % (dm[3], dm[2], dm[1]) if dm else "18/10/2026"
    HEURE = HEURE or ((dm[4] + "h" + dm[5]) if dm else "")
    ver, periode = VERSION or (dm[6] if dm else "version de travail"), "08 au 18/10/2026"
    st_ = {}
    r1 = re.search(r"écarts RÉSOLUS[^:]*: (\d+)", txt); r2 = re.search(r"Rouges par lot[^|]*\| .*?total (\d+)", txt); r3 = re.search(r"BLOQUE (\d+)", txt)
    r4 = re.search(r"pas ROUGE (\d+) · VERT (\d+) · BLOQUE (\d+)", txt)
    if r4: st_["pas_rouges"], st_["pas_verts"], st_["pas_bloques"] = int(r4[1]), int(r4[2]), int(r4[3]); st_["pas"] = sum(int(x) for x in r4.groups())
    if r1: st_["resolus"] = int(r1[1])
    if r2: st_["rouges"] = int(r2[1])
    if r3: st_["bloques"] = int(r3[1])
    mm = re.search(r"Éléments non relevables listés à part : (\d+)", txt); NR = int(mm[1]) if mm else NR
    blk = txt[txt.index("Section | Relevés"):]; blk = blk[:blk.index("```")]
    par_type, presents, absents, sect = [], None, None, {k: [] for _, k in GROUPES}
    cle_de = {"Saisie": "saisie", "Fiche": "fiche", "Cliquable": "cliquable", "Actions": "actions", "Mails": "mails"}
    sous_totaux = False
    for l in blk.splitlines():
        c = [x.strip() for x in l.split(" | ")]
        if l.startswith("Sous-totaux"): sous_totaux = True; continue
        if len(c) < 5 or c[0].startswith("Section") or not re.match(r"^[\d-]", c[1]): continue
        n, e, k_, p = int(c[1]), int(c[2]), int(c[3]), pct(c[4])
        if not sous_totaux:
            sect[cle_de[c[0].split()[0]]].append((c[0], n, e, k_, p, "écran absent" in c[4], False))
        elif c[0] in cle_de.values():
            par_type.append((c[0], n, e, k_, p))
            sect[c[0]].append(("Sous-total " + c[0], n, e, k_, p, False, True))
        elif c[0].startswith("dont écrans présents"): presents = (n, e, k_, p)
        elif c[0].startswith("dont écrans absents"): absents = (n, e, k_, p)
else:
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

    mm = re.search(r"non relevables\*\* : \*\*(\d+)\*\*|Éléments non relevables : \*\*(\d+)\*\*", md)
    NR = int(next(g for g in (mm.groups() if mm else ()) if g)) if mm else NR
# historique
hp = os.path.join(HUB, "conformite_historique.json")
hist = json.load(open(hp, encoding="utf-8")) if os.path.exists(hp) else []
if LABEL:
    ent = {"date": date, "label": LABEL, "heure": HEURE or "", "note": note, "version": ver, "elements": tot}
    ent.update(st_ if REJEU else {})
    if NOTE: ent["texte"] = NOTE
    idx = next((i for i, h in enumerate(hist) if h["date"] == date and h.get("label") == LABEL), None)
    if idx is None: hist.append(ent)
    else: hist[idx] = ent
else:
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
    return f'<tr><td>{b}{nom}{bb}{tag}</td><td class="nm">{n}</td><td class="nm">{e}</td><td class="nm">{b}{ptxt}{bb}</td><td class="bc">{bar(p, absent)}</td></tr>'
TH = "<tr><th>Section</th><th class='nm'>Relevés</th><th class='nm'>Écarts</th><th class='nm'>Conforme</th><th></th></tr>"

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
td.nm,th.nm{text-align:right;white-space:nowrap;font-size:inherit;font-weight:inherit;color:inherit;width:auto} td.bc{width:30%;min-width:100px}
.borne{border-left:4px solid var(--cours);padding:8px 14px;margin:10px 0 16px;background:var(--carte);border-radius:0 8px 8px 0}
.deux2{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin:10px 0}.deux2>div{background:var(--carte);border:1px solid var(--bord);border-radius:10px;padding:12px 14px}
.deux2 b.v{font-size:28px;display:block}
@media (max-width:640px){.deux2{grid-template-columns:1fr}.note-g .gros{font-size:48px}}
</style>"""
def pc(x): return fr("%.1f" % x) + " %"
def hrow(h):
    m = (' <small>(%s : %s → %s)</small>' % (h["mention"], pc(h["avant"]), pc(h["note"]))) if h.get("mention") else ""
    lab = (" · %s%s" % (h["label"], (" (" + h["heure"] + ")") if h.get("heure") else "")) if h.get("label") else ""
    return '<tr><td>%s%s%s</td><td>%s</td><td class="nm">%s</td><td class="nm"><b>%s</b></td><td class="bc">%s</td></tr>' % (h["date"], lab, m, h["version"], h["elements"], pc(h["note"]), bar(h["note"]))
def brow(p, n): return '<tr><td>%s</td><td class="nm">%s</td><td class="bc">%s</td></tr>' % (n, pc(p), bar(p))
def courbe():
    W, Hh, x0, x1 = 620, 160, 60, 590
    Y = lambda v: 140 - v * 1.2
    n = len(hist)
    X = lambda i: x0 + (x1 - x0) * (i / (n - 1) if n > 1 else 0.5)
    pts = " ".join("%.0f,%.0f" % (X(i), Y(h["note"])) for i, h in enumerate(hist))
    o = ['<svg viewBox="0 0 %d %d" role="img" aria-label="Courbe de la conformité" style="width:100%%;max-width:680px;display:block">' % (W, Hh)]
    o.append('<line x1="%d" y1="%.0f" x2="%d" y2="%.0f" stroke="var(--cours)" stroke-dasharray="5 4"/><text x="%d" y="%.0f" fill="var(--cours)" font-size="11">objectif 95 %%</text>' % (x0, Y(95), x1, Y(95), x0, Y(95) - 5))
    for v in (0, 50):
        o.append('<line x1="%d" y1="%.0f" x2="%d" y2="%.0f" stroke="var(--bord)"/><text x="6" y="%.0f" fill="var(--t3)" font-size="11">%d %%</text>' % (x0, Y(v), x1, Y(v), Y(v) + 4, v))
    if n > 1: o.append('<polyline points="%s" fill="none" stroke="var(--vert)" stroke-width="2.5"/>' % pts)
    for i, h in enumerate(hist):
        lab = h.get("label", "")
        o.append('<circle cx="%.0f" cy="%.0f" r="5" fill="var(--vert)"/><text x="%.0f" y="%.0f" text-anchor="middle" fill="var(--t1)" font-size="12" font-weight="600">%s</text><text x="%.0f" y="%.0f" text-anchor="middle" fill="var(--t3)" font-size="10">%s</text>' % (X(i), Y(h["note"]), X(i), Y(h["note"]) - 10, pc(h["note"]), X(i), 156, lab))
    o.append("</svg>")
    return "".join(o)
COURBE = courbe()
HIST_ROWS = "".join(hrow(h) for h in reversed(hist))
bas = sorted([(p, n) for g in sect.values() for (n, a, e, c, p, ab, s) in g if not ab and not s and p is not None and a > 0])[:5]
cur = hist[idx] if idx is not None else hist[-1]
MENTION = ('<p class="sous" style="margin:0 0 12px">%s : %s → %s</p>' % (cur["mention"].capitalize(), pc(cur["avant"]), pc(cur["note"]))) if cur.get("mention") else ""
QUAND = (" vers " + cur["heure"].replace("h", " h ")) if cur.get("heure") else ""
SURQUOI = ("la version de travail du Livrable 3 (%s), %s" % (ver, cur["label"])) if cur.get("label") else ("la version " + ver)
COMPTEURS = _cc.bloc_html()
NOUVEAU = ""
try:
    nj = json.load(open(os.path.join(HUB, "conformite_nouveau.json"), encoding="utf-8"))
    b0 = nj["base"]; pts_n = [b0] + nj["points"]; last = pts_n[-1]
    def _courbe_n():
        W, Hh, x0, x1 = 620, 120, 120, 500
        Y = lambda v: 100 - (v - 50) * 1.6
        X = lambda i: x0 + (x1 - x0) * (i / max(1, len(pts_n) - 1))
        o = ['<svg viewBox="0 0 %d %d" role="img" aria-label="Courbe du nouveau tableau" style="width:100%%;max-width:680px;display:block">' % (W, Hh)]
        o.append('<line x1="%d" y1="%.0f" x2="%d" y2="%.0f" stroke="var(--bord)"/><text x="6" y="%.0f" fill="var(--t3)" font-size="11">50 %%</text>' % (x0 - 60, Y(50), x1 + 60, Y(50), Y(50) + 4))
        o.append('<polyline points="%s" fill="none" stroke="var(--v2)" stroke-width="2.5"/>' % " ".join("%.0f,%.0f" % (X(i), Y(q["note"])) for i, q in enumerate(pts_n)))
        for i, q in enumerate(pts_n):
            o.append('<circle cx="%.0f" cy="%.0f" r="5" fill="var(--v2)"/><text x="%.0f" y="%.0f" text-anchor="middle" fill="var(--t1)" font-size="12" font-weight="600">%s</text><text x="%.0f" y="116" text-anchor="middle" fill="var(--t3)" font-size="10">%s</text>' % (X(i), Y(q["note"]), X(i), Y(q["note"]) - 10, pc(q["note"]), X(i), q["label"]))
        o.append("</svg>")
        return "".join(o)
    bas_n = nj.get("bas")
    FOURCH = (" (fourchette %s–%s)" % (pc(bas_n), pc(last["note"]))) if bas_n else ""
    CONF9 = ('<li style="display:list-item;border:0;padding:2px 0"><b>Confirmés par un scénario vert : %s sur %s (%s).</b> Les autres éléments conformes sont des « conformes par comparaison » : lus dans Boond et dans Ava, pas encore confirmés par un test.</li>'
             % (nj["verts"], last["releves"], pc(nj["verts_pct"]))) if nj.get("verts") else ""
    AMBI = ('<li style="display:list-item;border:0;padding:2px 0">%s écarts résolus ont une preuve discutable : sans eux, la note tombe à %s. Le Juge les résorbe à la campagne n° 10.</li>' % (nj["ambigus"], pc(bas_n))) if bas_n and nj.get("ambigus") else ""
    NOUVEAU = ('<div class="borne" style="border-left-color:var(--v2)"><b>Deux tableaux, deux courbes séparées.</b> '
      'Le <b>nouveau tableau</b> compare les écrans neufs élément par élément (l’ancien les forçait à 0 %%). '
      'Sa base était de <b>%s</b> (%s sur %s). À la campagne %s, <b>%s des éléments sont sans écart ouvert (règle du Juge)%s</b> : %s sur %s relevés, %s écarts restants. '
      'Ce n’est <b>pas</b> « %s mesurés en campagne » : c’est une <b>borne haute</b>, car la plupart des éléments conformes ne sont pas encore confirmés par un test. '
      'Le nouveau tableau devient la <b>référence à partir de la campagne n° 9</b> ; l’ancien tableau (%s) est gardé à côté pour la continuité.'
      '<ul style="margin:8px 0 0;padding-left:20px;list-style:disc">%s%s</ul>'
      '<p class="sous" style="margin:8px 0 4px">Nouveau tableau (écrans neufs comparés élément par élément) : base %s, puis %s.%s</p>%s'
      '<p class="sous" style="margin:8px 0 0">La courbe « ancien tableau » (écrans absents forcés à 0 %%) est celle de « L’historique des mesures » plus bas_n ; on ne mélange pas les deux, et aucun des deux chiffres ne se lit sans l’autre.</p></div>') % (
      pc(b0["note"]), b0["conformes"], b0["releves"], last["label"], pc(last["note"]), FOURCH, last["conformes"], last["releves"], last["ecarts"],
      pc(last["note"]), pc(note), CONF9, AMBI,
      pc(b0["note"]), " puis ".join("%s à la %s" % (pc(q["note"]), q["label"]) for q in nj["points"]), nj["sections"], _courbe_n())
except Exception as _e:
    NOUVEAU = ""
    print("encart non construit :", _e)
STATS = ""
if cur.get("pas") is not None:
    STATS = '<p class="sous" style="margin:0 0 12px">Cette campagne : <b>%d écarts résolus</b> · %d pas joués : %d verts, %d en échec, %d bloqués (il manque encore du code).</p>' % (cur.get("resolus", 0), cur["pas"], cur["pas_verts"], cur["pas_rouges"], cur["pas_bloques"])
if cur.get("texte"): STATS += '<p class="sous" style="margin:0 0 12px">%s</p>' % cur["texte"]
ENLIGNE = '<p class="sous" style="margin:0 0 12px">Les campagnes de mesure portent sur le Livrable 3, en construction ; la version en ligne est le Livrable 2bis (5a94a54e).</p>' if cur.get("label") else ""
html = HEAD + EXTRA + f'''<h1>Conformité à Boond</h1>
<p class="sous">{STAMP} · à chaque livraison, ce tableau est recalculé et la date de mesure change</p>
<span class="date">Mesurée le {date}{QUAND} sur {SURQUOI} · Boond relevé à l'écran du {periode}</span>{MENTION}{ENLIGNE}{STATS}

<p class="sous" style="margin:0 0 6px"><b>Ancien tableau</b> (écrans absents forcés à 0 %) — référence de continuité ; le nouveau tableau est présenté juste en dessous, les deux se lisent ensemble.</p>
<div class="note-g"><div class="gros">{fr("%.1f" % note)}<small> %</small></div>
<div class="col"><span class="bar grand"><i style="width:{note:.1f}%"></i></span><p class="sous" style="margin:6px 0 0">{conf} éléments conformes sur {tot} relevés dans Boond</p></div></div>
<p class="borne"><b>C'est une borne haute.</b> Un écart compte pour un seul élément, alors qu'une ligne d'écart en couvre souvent plusieurs (« dix champs absents », « treize écrans »). La vraie conformité est donc probablement un peu plus basse.</p>

{NOUVEAU}
{COMPTEURS}
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
<table><tr><th>Section</th><th class="nm">Conforme</th><th></th></tr>{"".join(brow(p, n) for p, n in bas)}</table>
<h2>L'historique des mesures — ancien tableau (écrans absents forcés à 0 %)</h2>
{COURBE}
<table><tr><th>Date de mesure</th><th>Version d'Ava</th><th class="nm">Éléments relevés</th><th class="nm">Conformité</th><th></th></tr>{HIST_ROWS}</table>
<p class="sous">Une nouvelle ligne s'ajoute à chaque campagne de mesure et à chaque livraison.</p>
<h2>Comment c'est compté</h2>
<table><tr><td class="e">1</td><td>Un « élément » est une chose lue dans Boond : un champ, une colonne, un bouton, un onglet, une carte, un message de liste vide, un lien, une entrée de menu.</td></tr>
<tr><td class="e">2</td><td>Chaque écart du rapport compte pour un élément. Conformes = éléments relevés − écarts. Pourcentage = conformes ÷ relevés.</td></tr>
<tr><td class="e">3</td><td>Un écran qui n'existe pas chez Ava vaut 0 %, avec tous ses éléments en écart.</td></tr>
<tr><td class="e">4</td><td>Les éléments qu'on ne peut pas relever sans rien envoyer ni rien modifier dans Boond sont retirés du calcul ({NR} à ce jour).</td></tr>
<tr><td class="e">5</td><td>Le tableau de bord et ses widgets ne sont pas comptés : c'est le seul écart permis (D-252).</td></tr></table>
</main></body></html>
'''
open(os.path.join(HUB, "conformite-boond.html"), "w", encoding="utf-8", newline="").write(html)
print("ok", note, len(hist), "mesure(s)")

#!/usr/bin/env python3
"""Deux compteurs de conformité pour le hub : CODÉ et JUGÉ.

CODÉ  = nombre d'écarts déclarés FERMÉS par une session Code au journal (lignes « CODE … → … FERMÉ(S) »), comptés une seule fois.
JUGÉ  = nombre d'écarts passés au VERT par une campagne du Juge (ligne « RÉSOLUS » de chaque RAPPORT_REJEU.md).
Le compteur CODÉ n'est JAMAIS présenté comme une note : la note officielle est celle du Juge.

Usage : python -X utf8 outils/compteurs_conformite.py        (écrit compteurs_conformite.json et affiche le résumé)
Utilisé par conformite_tableau.py et recopier_todo.py (fonction bloc_html()).
Lecture seule sur le journal, les fichiers d'écarts et les rapports de rejeu.
"""
import re, os, json, datetime, sys

HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HUB, "..", ".."))
CONF = os.path.join(ROOT, "audits-independants", "conformite")
JOURNAL = os.path.join(ROOT, "audits-independants", "JOURNAL_AUDIT.md")
REJ = os.path.join(ROOT, ".claude", "worktrees", "focused-shamir-7a606a", "test", "scenarios", "rejeux")
HIST = os.path.join(HUB, "conformite_historique.json")
OUT = os.path.join(HUB, "compteurs_conformite.json")

PRE_OLD = r"(?:A|B|C2|F|AC|ML|K)"
PRE_NEW = ["NK", "NM", "NR", "NF", "NV", "NB", "NQ", "NG", "NH", "NT"]
ALLPRE = ["C2", "AC", "ML"] + PRE_NEW + ["A", "B", "F", "K", "N"]


def univers():
    ids = set()
    ID = re.compile(r"^[*\s]*(" + PRE_OLD + r"-\d{3})")
    for l in open(os.path.join(CONF, "ECARTS_SAISIE_FICHES_2026-10-18.md"), encoding="utf-8"):
        if not l.startswith("|"): continue
        c = [x.strip() for x in re.split(r" \| ", l.strip().strip("|"))]
        if len(c) >= 5:
            m = ID.match(c[3])
            if m: ids.add(m[1])
    anciens = len(ids) + 21
    ids |= {"N-%03d" % i for i in range(1, 22)}
    new = set()
    NEW = re.compile(r"^(" + "|".join(PRE_NEW) + r")-(\d{3})(?!\d)(?!-OK)")
    for l in open(os.path.join(CONF, "ECARTS_ECRANS_NEUFS_2026-10-20.md"), encoding="utf-8"):
        if not l.startswith("|"): continue
        c = [x.strip() for x in l.strip().strip("|").split("|")]
        m = NEW.match(c[0]) if c else None
        if m: new.add("%s-%s" % (m[1], m[2]))
    return ids | new, anciens, len(new)


def depuis_journal(U):
    """id -> (date iso, heure) de la première ligne Code qui le déclare fermé."""
    L = open(JOURNAL, encoding="utf-8").read().splitlines()
    ferme = {}
    tok = re.compile(r"(?P<pre>" + "|".join(ALLPRE) + r")-(?P<a>\d{3})(?:(?:\.\.|\s+à\s+|-)(?:(?P=pre)-)?(?P<b>\d{3}))?")
    cont = re.compile(r"\s*[/,]\s*(?:(?P<pre>" + "|".join(ALLPRE) + r")-)?(?P<a>\d{3})(?:(?:\.\.|\s+à\s+|-)(?:(?:" + "|".join(ALLPRE) + r")-)?(?P<b>\d{3}))?")
    fam = re.compile(r"(?<![A-Z0-9-])(" + "|".join(PRE_NEW) + r")(?=\s*[\(,;:+/)]|\s+\()")
    STOP = re.compile(r"(?i)\b(reste|restent|non ferm|pas ferm|ouvert|à faire|reste à)\b|⛔|⚠")
    for l in L:
        c = l.split("|")
        if len(c) < 4 or not l.startswith("| "): continue
        d, h, who = c[1].strip(), c[2].strip(), c[3].strip()
        m = re.match(r"^(\d\d)/(\d\d)/(\d{4})", d)
        if not m or not who.startswith("CODE"): continue
        iso = "%s-%s-%s" % (m[3], m[2], m[1])
        if iso < "2026-10-18": continue
        if not re.match(r"^\d\d:\d\d", h): h = "23:59"  # heure absente au journal : on suppose la fin de journée (lecture prudente)
        for f in re.finditer(r"FERM[ÉE]S?\b", l):
            seg = l[f.end(): f.end() + 700]
            s = STOP.search(seg)
            if s: seg = seg[:s.start()]
            pos = 0
            while pos < len(seg):
                t = tok.search(seg, pos)
                fm = fam.search(seg, pos)
                if fm and (not t or fm.start() < t.start()):
                    for i in U:
                        if i.startswith(fm[1] + "-") and not i.endswith("OK"): ferme.setdefault(i, (iso, h))
                    pos = fm.end(); continue
                if not t: break
                pre, a, b = t["pre"], int(t["a"]), t["b"]
                nums = list(range(a, int(b) + 1)) if b else [a]
                pos = t.end()
                while True:
                    cm = cont.match(seg, pos)
                    if not cm: break
                    a2 = int(cm["a"]); b2 = cm["b"]
                    nums += list(range(a2, int(b2) + 1)) if b2 else [a2]
                    pos = cm.end()
                for n in nums:
                    i = "%s-%03d" % (pre, n)
                    if i in U: ferme.setdefault(i, (iso, h))
    return ferme


def juge():
    """Pour chaque rapport de rejeu : (date iso, heure, version, résolus). On garde le dernier rapport par version."""
    res = []
    for dn in sorted(os.listdir(REJ)):
        m = re.match(r"^(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})_(.+)$", dn)
        p = os.path.join(REJ, dn, "RAPPORT_REJEU.md")
        if not m or not os.path.exists(p): continue
        t = open(p, encoding="utf-8").read()
        r = re.search(r"écarts RÉSOLUS[^:]*: (\d+)", t)
        n = re.search(r"APRÈS marquage RÉSOLU \| \*\*([\d.]+) %", t)
        if r and n:
            res.append({"dossier": dn, "iso": "%s-%s-%s" % (m[1], m[2], m[3]), "heure": "%s:%s" % (m[4], m[5]), "version": m[6], "resolus": int(r[1]), "note": float(n[1])})
    return res


def calcul():
    U, anciens, nouveaux = univers()
    ferme = depuis_journal(U)
    rj = juge()
    hist = json.load(open(HIST, encoding="utf-8"))
    series = []
    for h in hist:
        lab = h.get("label", "")
        if not lab.startswith("campagne"): continue
        d, mo, y = h["date"].split("/")
        hh = h.get("heure", "").replace("h", ":") or "00:00"
        iso = "%s-%s-%s" % (y, mo, d)
        codes = sum(1 for (di, he) in ferme.values() if (di, he) <= (iso, hh))
        tok_ = h["version"].split()[0]
        cand = [r for r in rj if tok_ in r["dossier"]]
        jug = cand[-1]["resolus"] if cand else h.get("resolus")
        series.append({"label": lab.replace("campagne n° ", "n° "), "heure": hh, "date": h["date"], "code": codes, "juge": jug})
    out = {"total": len(U), "anciens": anciens, "nouveaux": nouveaux, "code": len(ferme), "juge": rj[-1]["resolus"] if rj else None,
           "juge_campagne": series[-1]["label"] if series else "", "series": series,
           "mesure": datetime.datetime.now().strftime("%d/%m/%Y %Hh%M")}
    json.dump(out, open(OUT, "w", encoding="utf-8", newline=""), ensure_ascii=False, indent=1)
    return out


def spark(vals, labels, couleur, W=240, Hh=64):
    pts = [(i, v) for i, v in enumerate(vals) if v is not None]
    if not pts: return ""
    mx = max(v for _, v in pts) or 1
    n = len(vals)
    X = lambda i: 12 + (W - 24) * (i / (n - 1) if n > 1 else 0.5)
    Y = lambda v: Hh - 14 - (Hh - 30) * v / mx
    o = ['<svg viewBox="0 0 %d %d" style="width:100%%;max-width:260px;display:block" role="img" aria-label="courbe">' % (W, Hh)]
    if len(pts) > 1: o.append('<polyline points="%s" fill="none" stroke="%s" stroke-width="2"/>' % (" ".join("%.0f,%.0f" % (X(i), Y(v)) for i, v in pts), couleur))
    for i, v in pts:
        o.append('<circle cx="%.0f" cy="%.0f" r="3.5" fill="%s"/>' % (X(i), Y(v), couleur))
    o.append('<text x="%.0f" y="%d" fill="var(--t1)" font-size="11" font-weight="700" text-anchor="end">%d</text>' % (X(pts[-1][0]) + 2, 11, pts[-1][1]))
    o.append("</svg>")
    return "".join(o)


def bloc_html(o=None):
    o = o or calcul()
    s = o["series"]
    ecart = max(0, o["code"] - (o["juge"] or 0))
    cod = spark([x["code"] for x in s], [x["label"] for x in s], "var(--v2)")
    jug = spark([x["juge"] for x in s], [x["label"] for x in s], "var(--vert)")
    labs = " · ".join(x["label"] for x in s)
    return f'''<style>.cpt{{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin:12px 0 4px}}.cpt>div{{background:var(--carte);border:1px solid var(--bord);border-radius:10px;padding:12px 14px}}.cpt b.v{{display:block;font-size:34px;line-height:1.1}}.cpt .t{{font-size:12px;letter-spacing:.05em;text-transform:uppercase;color:var(--t2);font-weight:600}}.cpt .def{{font-size:13px;color:var(--t2);margin:4px 0 8px}}.cpt .lim{{font-size:12px;color:var(--t3);margin:0}}@media (max-width:640px){{.cpt{{grid-template-columns:1fr}}}}</style>
<div class="cpt" id="compteurs">
<div><span class="t">Codé</span><b class="v">{o["code"]}<small style="font-size:16px;font-weight:400"> / {o["total"]}</small></b><p class="def">Écarts que les sessions Code ont déclarés fermés au journal, comptés une seule fois. Rien n’est encore prouvé : ce n’est pas une note.</p>{cod}</div>
<div><span class="t">Jugé</span><b class="v">{o["juge"]}<small style="font-size:16px;font-weight:400"> / {o["total"]}</small></b><p class="def">Écarts passés au vert par une campagne du Juge ({o["juge_campagne"]}). C’est ce qui compte pour la note officielle.</p>{jug}</div>
</div>
<p class="sous" style="margin:6px 0 2px"><b>{ecart}</b> écarts sont codés mais pas encore prouvés. Le grand chiffre est celui d’aujourd’hui ; chaque courbe donne la valeur au moment de chaque campagne ({labs}). Total : {o["anciens"]} écarts anciens + {o["nouveaux"]} des écrans neufs. Mesuré le {o["mesure"]}.</p>
<p class="sous" style="margin:0 0 14px">Le compteur « codé » est lu dans le journal des sessions : c’est un minimum, la lecture sera affinée.</p>'''


if __name__ == "__main__":
    o = calcul()
    print("total", o["total"], "(anciens", o["anciens"], "+ nouveaux", o["nouveaux"], ") | codé", o["code"], "| jugé", o["juge"], "(" + o["juge_campagne"] + ")")
    for x in o["series"]: print(" ", x["label"], x["date"], x["heure"], "codé", x["code"], "jugé", x["juge"])

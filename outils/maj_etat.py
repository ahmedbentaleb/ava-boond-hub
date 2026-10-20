#!/usr/bin/env python3
"""Régénère les passages CHIFFRÉS de « Où en sommes-nous » depuis les mêmes sources que la page Conformité.

Usage (depuis le dossier du hub) :  python -X utf8 outils/maj_etat.py
Lit   : conformite_nouveau.json (chiffre prudent, borne haute, courbe du nouveau tableau, « Livrable 3 »)
        conformite_historique.json (courbe de l'ancien tableau, dernière campagne)
Écrit : etat.html — trois blocs entre repères <!--AUTO:...--> : la phrase d'ouverture, la carte de conformité, la ligne des campagnes ;
        + l'heure de mise à jour (heure de Casablanca = heure de la machine, UTC+0).
Aucun chiffre n'est écrit à la main dans ces blocs : à chaque campagne, on met à jour conformite_nouveau.json, on lance ce script.
"""
import json, os, re, datetime
HUB = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
rd = lambda p: open(os.path.join(HUB, p), encoding="utf-8").read()
fr = lambda x: ("%.1f" % x).replace(".", ",")
nj = json.loads(rd("conformite_nouveau.json")); hist = json.loads(rd("conformite_historique.json"))
camp = [h for h in hist if h.get("label", "").startswith("campagne")]
last_h = camp[-1]; last_n = nj["points"][-1]; b0 = nj["base"]
bas = nj.get("bas_txt") or "%.0f" % nj["bas"]; haut = "%.0f" % last_n["note"]
num = last_h["label"].replace("campagne ", "")
ancien = " ; ".join("%s : %s %%" % (h["label"].replace("campagne ", ""), fr(h["note"])) for h in camp)
nouveau = ", ".join(["base %s %%" % fr(b0["note"])] + ["%s : %s %%" % (p["label"], fr(p["note"])) for p in nj["points"]])
tx = json.loads(rd("etat_texte.json"))

GRAND = f'''<p class="grand"><b>Aujourd’hui Ava ressemble à Boond à {bas} % ; la cible est 100 % des éléments mesurables.</b> Il reste {last_n["ecarts"]} différences à fermer.</p>
<p class="sous">Les éléments qu’on ne peut pas vérifier chez Boond (module facturation absent du compte, envois réels de mails, PDF à déposer) sont listés à part avec la raison. Ce {bas} % est le chiffre prudent ({nj["prudent_conformes"]} éléments sur {last_n["releves"]}, sans les cas ambigus ; il était de {nj["prudent_precedent"]} à la campagne précédente) : il peut monter jusqu’à {haut} % ({fr(last_n["note"])} % d’éléments sans différence ouverte, règle du Juge). Seuls {nj["verts"]} éléments sur {last_n["releves"]} ({fr(nj["verts_pct"])} %) sont déjà confirmés par un test réussi, les autres sont conformes par comparaison. L’<b>ancienne façon de compter</b> (les écrans neufs comptaient 0) donne {fr(last_h["note"])} % ; elle est gardée pour l’historique. {tx["livrable3"]} <b>Hamada a autorisé le BRAIN à le remplacer entièrement</b> (D-330), sauf pour la base de démo, les gestes à la main, le serveur réel, les secrets, les noms de domaine et les comptes.</p>'''
CARTE = f'''<div class="chiffre"><b>{bas} %</b><span>d’Ava ressemble à Boond (chiffre prudent, campagne {num}) ; peut monter jusqu’à {haut} % quand les tests seront resserrés ; objectif 100 % des éléments mesurables</span></div>'''
LIGNE = f'''<b>Campagnes de mesure sur le Livrable 3</b> : le Juge joue ses scénarios (par rôle, grisé, cliquable) et recalcule la note. <b>Ancien tableau</b> (écrans absents forcés à 0 %) : {ancien}. <b>Nouveau tableau</b> (écrans neufs comptés élément par élément) : {nouveau} ({fr(last_n["note"])} % d’éléments sans différence ouverte, {last_n["conformes"]} sur {last_n["releves"]} ; {last_n["ecarts"]} différences à fermer). Chiffre prudent : {fr(nj["bas"])} %. Le nouveau tableau est la référence ; l’ancien est gardé pour la continuité.'''
STATUT = tx["statut_campagne"].replace("{num}", num)

def bloc(s, nom, contenu):
    a, b = "<!--AUTO:%s-->" % nom, "<!--/AUTO:%s-->" % nom
    if a in s: return re.sub(re.escape(a) + ".*?" + re.escape(b), lambda m: a + contenu + b, s, count=1, flags=re.S)
    raise SystemExit("repère manquant : " + nom)

e = rd("etat.html")
e = bloc(e, "grand", GRAND); e = bloc(e, "carte", CARTE); e = bloc(e, "ligne", LIGNE); e = bloc(e, "statut", STATUT)
J = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]; n = datetime.datetime.now()
ST = "Mis à jour le %s %s à %s (heure de Casablanca)" % (J[n.weekday()], n.strftime("%d/%m/%Y"), n.strftime("%Hh%M"))
e = re.sub(r"Mis à jour le [^(]*\(heure de Casablanca\)", ST, e, count=1)
open(os.path.join(HUB, "etat.html"), "w", encoding="utf-8", newline="").write(e)
print("etat.html régénérée :", bas, "% (jusqu'à", haut, "%)", ST)

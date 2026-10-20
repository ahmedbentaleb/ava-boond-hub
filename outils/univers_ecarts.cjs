#!/usr/bin/env node
// COPIE du recompte de Conformité (lecture seule, sans --ecrire-tete) + une ligne finale pour le hub.
// Recompte de conformité. Usage : node recompte.js [TABLEAU_CONFORMITE.md] [ECARTS_SAISIE_FICHES_2026-10-18.md] [ECARTS_ECRANS_NEUFS_2026-10-20.md] [--ecrire-tete]
// Sans argument : lit les trois fichiers dans le dossier du script.
// Option --ecrire-tete : réécrit, dans le fichier des écrans neufs, le tableau de tête (totaux par ensemble) et la répartition par section.
const ECRIRE = process.argv.includes('--ecrire-tete');
const fs = require('fs'), path = require('path');
const args = process.argv.slice(2).filter(a => !a.startsWith('--'));
const tab = args[0] || path.join(__dirname, 'TABLEAU_CONFORMITE.md');
const src = args[1] || path.join(__dirname, 'ECARTS_SAISIE_FICHES_2026-10-18.md');
const neufs = args[2] || path.join(__dirname, 'ECARTS_ECRANS_NEUFS_2026-10-20.md');
const md = fs.readFileSync(tab, 'utf8');
const FENCE = String.fromCharCode(96).repeat(3);
const lignesDe = t => t.split(/\r?\n/);
const bloc = nom => {
  const d = md.indexOf(FENCE + 'csv ' + nom + '\n');
  if (d < 0) throw new Error('bloc csv ' + nom + ' introuvable');
  const debut = md.indexOf('\n', d) + 1, fin = md.indexOf(FENCE, debut);
  return lignesDe(md.slice(debut, fin)).filter(l => l.trim() && !l.startsWith('#'));
};
const cellules = l => l.replace(/^\|\s*/, '').replace(/\s*\|\s*$/, '').split(' | ');
// 1. Identifiants d'écart de l'ancien fichier : ligne de tableau dont la 4e colonne commence par l'identifiant
const PREF = '(?:A|B|C2|F|AC|ML|K)';
const ID = new RegExp('^[*\\s]*(' + PREF + '-\\d{3})\\b');
const defs = {};
for (const l of lignesDe(fs.readFileSync(src, 'utf8'))) {
  if (!l.startsWith('|')) continue;
  const c = cellules(l);
  if (c.length < 5) continue;
  const m = c[3].match(ID);
  if (m && !defs[m[1]]) defs[m[1]] = c[3];
}
// 1 bis. Fichier fusionné des écrans neufs : 1re colonne = identifiant, 5e = verdict (le verdict fait foi, la forme est contrôlée)
const neuf = {}, occ = {}, formeNonConforme = [], prefixes = {}, preDe = {}, annotes = new Set();
for (const l of lignesDe(fs.readFileSync(neufs, 'utf8'))) {
  if (!l.startsWith('|')) continue;
  const c = cellules(l);
  if (c.length < 5) continue;
  const m = c[0].match(/^[*\s]*(N[A-Z]\d?-[A-Z0-9-]+)/);
  if (!m) continue;
  const id = m[1], v = c[4].toLowerCase().replace(/\*/g, '');
  const genre = v.startsWith('écart') ? 'ecart' : v.startsWith('conforme') ? 'ok' : v.startsWith('non relevable') ? 'nr' : '?';
  const forme = /^N[A-Z]\d?-\d{3}$/.test(id) ? 'ecart' : /^N[A-Z]\d?-\d{3}-OK$|^N[A-Z]\d?-OK-\d{2}$/.test(id) ? 'ok' : 'nr';
  const pre = /^NR-\d{2}$/.test(id) ? 'NK' : id.split('-')[0];
  occ[id] = (occ[id] || 0) + 1;
  if (forme !== genre) formeNonConforme.push(id + ' (forme ' + forme + ', verdict ' + genre + ')');
  if (c.slice(5).join(' | ').includes('retiré le 20/10/2026 : doublon de')) annotes.add(id);
  if (!neuf[id]) {
    neuf[id] = genre; preDe[id] = pre;
    if (genre === 'ecart') defs[id] = id + ' ' + c[4];
  }
}
// 2. Exclusions : remplacé (bloc remplaces), doublon, tombé, résolu (marqueur RÉSOLU), non relevable (bloc nr, portée « exclu »)
const RANGE = /^(.*?)(\d{2,3})(-OK)?\.\.(?:(.*?)(\d{2,3})(?:-OK)?)$/;
const developper = spec => (spec || '').split(',').map(s => s.trim()).filter(Boolean).flatMap(t => {
  const r = t.match(RANGE);
  if (!r) return [t];
  const o = [];
  for (let i = +r[2]; i <= +r[5]; i++) o.push(r[1] + String(i).padStart(r[2].length, '0') + (r[3] || ''));
  return o;
});
const nrLignes = bloc('nr').map(l => l.split(';'));
const nrIds = new Set(nrLignes.filter(f => f[2] === 'exclu').flatMap(f => developper(f[1])));
const nrNeufs = new Set(nrLignes.map(f => f[1]).filter(x => /^N[A-Z]\d?-[A-Z0-9-]+$/.test(x)));
const remplaces = new Set(bloc('remplaces').flatMap(l => developper(l.split(';')[0])));
// Doublons entre ensembles (D-389, 20/10/2026) : identifiant retiré ; identifiant(s) gardé(s) ; ensemble ; élément ; règle. Exclus du comptage (écarts ET conformes).
const doublonsLignes = bloc('doublons').map(l => l.split(';'));
const doublons = new Set(doublonsLignes.map(f => f[0]));
const statut = id => !defs[id] ? 'INCONNU' : remplaces.has(id) ? 'remplacé' : doublons.has(id) ? 'doublon D-389' : /doublon de/i.test(defs[id]) ? 'doublon'
  : /tomb(é|e)/i.test(defs[id]) ? 'tombé' : /RÉSOLU/.test(defs[id]) ? 'résolu'
  : nrIds.has(id) ? 'non relevable' : 'valide';
// 3. Sections : écarts = identifiants valides (borne : jamais plus que les relevés) ; écran absent : tout est en écart
// Colonne 6 (facultative) : identifiants des conformes ; relevés = écarts valides + conformes (contrôlé)
const vus = {}, vusOk = {}, incoherentes = [], S = [];
for (const l of bloc('inventaire')) {
  const [section, objet, type, rel, spec, conf] = l.split(';');
  const absent = spec.startsWith('ABSENT:');
  const ids = developper(spec.replace(/^ABSENT:/, ''));
  const oks = developper(conf);
  const cnt = {};
  ids.forEach(id => { const s = statut(id); cnt[s] = (cnt[s] || 0) + 1; vus[id] = (vus[id] || 0) + 1; });
  oks.forEach(id => { vusOk[id] = (vusOk[id] || 0) + 1; });
  const oksValides = oks.filter(id => !doublons.has(id));
  const releves = +rel, valides = cnt.valide || 0;
  if (conf !== undefined && releves !== valides + oksValides.length) incoherentes.push(section + ' (' + releves + ' relevés, ' + valides + ' écarts + ' + oksValides.length + ' conformes)');
  const ecarts = absent ? releves : Math.min(valides, releves);
  const neufId = id => /^N[A-Z]\d?-/.test(id);
  S.push({ section, objet, type, releves, ecarts, absent, borne: !absent && valides > releves, nEc: ids.filter(id => neufId(id) && statut(id) === 'valide').length, nOk: oksValides.filter(neufId).length });
}
const pct = (c, r) => r ? (100 * c / r).toFixed(1) + ' %' : '-';
console.log('Section | Relevés | Écarts | Conformes | %');
S.forEach(s => console.log([s.section, s.releves, s.ecarts, s.releves - s.ecarts,
  pct(s.releves - s.ecarts, s.releves) + (s.absent ? ' (écran absent)' : '') + (s.borne ? ' (borné)' : '')].join(' | ')));
console.log('\nSous-totaux : type | relevés | écarts | conformes | %');
const T = {};
S.forEach(s => { const t = T[s.type] = T[s.type] || { r: 0, e: 0 }; t.r += s.releves; t.e += s.ecarts; });
let R = 0, E = 0;
for (const k in T) {
  R += T[k].r; E += T[k].e;
  console.log([k, T[k].r, T[k].e, T[k].r - T[k].e, pct(T[k].r - T[k].e, T[k].r)].join(' | '));
}
console.log(['NOTE GLOBALE', R, E, R - E, pct(R - E, R)].join(' | '));
const P = S.filter(s => !s.absent), Pr = P.reduce((a, s) => a + s.releves, 0), Pe = P.reduce((a, s) => a + s.ecarts, 0);
console.log(['dont écrans présents chez Ava', Pr, Pe, Pr - Pe, pct(Pr - Pe, Pr)].join(' | '));
console.log(['dont écrans absents chez Ava', R - Pr, E - Pe, 0, '0.0 %'].join(' | '));
// 4. Contrôles de couverture
const tous = Object.keys(defs);
const non = tous.filter(i => !vus[i] && !remplaces.has(i)), deux = tous.filter(i => vus[i] > 1), inc = Object.keys(vus).filter(i => !defs[i]);
const encore = [...remplaces].filter(i => vus[i]);
const par = {};
tous.forEach(i => { const s = statut(i); par[s] = (par[s] || 0) + 1; });
console.log('\nIdentifiants lus : ' + tous.length + ' | par statut : ' + JSON.stringify(par));
console.log('Non rattachés : ' + (non.join(' ') || 'aucun') + ' | rattachés deux fois : ' + (deux.join(' ') || 'aucun')
  + ' | inconnus : ' + (inc.join(' ') || 'aucun') + ' | remplacés encore comptés : ' + (encore.join(' ') || 'aucun'));
console.log('Sections aux écarts bornés : ' + (S.filter(s => s.borne).map(s => s.section).join(' ; ') || 'aucune'));
// 5. Écrans neufs : comptes par préfixe, doublons, rattachement de chaque identifiant à une section
for (const id of Object.keys(neuf)) {
  const p = prefixes[preDe[id]] = prefixes[preDe[id]] || { ecart: 0, ok: 0, nr: 0, retire: 0 };
  if (doublons.has(id)) p.retire++; else p[neuf[id]]++;
}
console.log('\nÉcrans neufs (fichier fusionné, doublons D-389 retirés) : préfixe | écarts | conformes | non relevables | retirés (doublons)');
let NE = 0, NO = 0, NN = 0, NRT = 0;
for (const k of Object.keys(prefixes)) {
  const p = prefixes[k];
  NE += p.ecart; NO += p.ok; NN += p.nr; NRT += p.retire;
  console.log([k, p.ecart, p.ok, p.nr, p.retire].join(' | '));
}
console.log(['Total comptés', NE, NO, NN, NRT].join(' | '));
const dEc = [...doublons].filter(i => neuf[i] === 'ecart').length, dOk = [...doublons].filter(i => neuf[i] === 'ok').length;
console.log('Doublons D-389 : ' + doublons.size + ' identifiants retirés (' + dEc + ' écarts, ' + dOk + ' conformes) | inconnus ou non relevables : ' + ([...doublons].filter(i => !neuf[i] || neuf[i] === 'nr').join(' ') || 'aucun')
  + ' | non annotés dans le fichier des écrans neufs : ' + ([...doublons].filter(i => !annotes.has(i)).join(' ') || 'aucun')
  + ' | annotés sans être dans le bloc doublons : ' + ([...annotes].filter(i => !doublons.has(i)).join(' ') || 'aucun')
  + ' | gardé retiré à son tour : ' + (doublonsLignes.flatMap(f => f[1].split(',')).filter(i => doublons.has(i)).join(' ') || 'aucun'));
const dbl = Object.keys(occ).filter(i => occ[i] > 1);
const sansSection = Object.keys(neuf).filter(i => neuf[i] === 'ecart' ? !vus[i] && !remplaces.has(i) : neuf[i] === 'ok' ? !vusOk[i] && !remplaces.has(i) : !nrNeufs.has(i));
const deuxOk = Object.keys(vusOk).filter(i => vusOk[i] > 1 || !neuf[i]);
console.log('Identifiants neufs : ' + Object.keys(neuf).length + ' (dont ' + doublons.size + ' retirés comme doublons)' + ' | doublons : ' + (dbl.join(' ') || 'aucun')
  + ' | forme ≠ verdict : ' + (formeNonConforme.join(' ; ') || 'aucun')
  + ' | sans section : ' + (sansSection.join(' ') || 'aucun') + ' | conformes en double ou inconnus : ' + (deuxOk.join(' ') || 'aucun')
  + ' | relevés ≠ écarts + conformes : ' + (incoherentes.join(' ; ') || 'aucun'));
// 5 bis. Honnêteté : toutes les conformités ci-dessous viennent d'une COMPARAISON (relevé Boond contre écran Ava, sans scénario) ; aucune d'un scénario vert
const SCENARIO_VERT = 0;
console.log('Conformes par comparaison : ' + (R - E) + ' | par scénario vert : ' + SCENARIO_VERT + ' | note de départ : ' + pct(R - E, R));
// 6. Non relevables : lignes, éléments (colonne 5 facultative, 1 par défaut) et portée
const nbElem = f => f[4] ? +f[4] : 1;
const parPortee = {};
nrLignes.forEach(f => { parPortee[f[2]] = parPortee[f[2]] || { lignes: 0, elements: 0 }; parPortee[f[2]].lignes++; parPortee[f[2]].elements += nbElem(f); });
console.log('Éléments non relevables listés à part : ' + nrLignes.reduce((a, f) => a + nbElem(f), 0) + ' éléments sur ' + nrLignes.length + ' lignes | par portée : ' + JSON.stringify(parPortee));

// 7. Option --ecrire-tete : réécrit le tableau de tête et la répartition par section du fichier des écrans neufs
if (ECRIRE) {
  const etiquettes = { NK: 'Cliquable (NK)', NR: 'Saisie contrat RH (NR)', NF: 'Fiche contrat RH (NF)', NV: 'Fiche avenant (NV)', NB: 'Saisie achat (NB)', NQ: 'Saisie produit (NQ)', NM: 'Mails (NM)', NG: 'Groupement (NG)', NH: 'Facture fournisseur (NH)', NT: 'Profil type (NT)', NA: 'Fiche achat (NA)', NP: 'Fiche produit (NP)', NC: 'Fiches des 3 contrats RH, hors NF (NC)', NG2: 'Fiche groupement (NG2)', NT2: 'Fiche profil type (NT2)' };
  const tete = ['| Ensemble | Éléments comptés | Écarts | Conformes | Non relevables | Retirés (doublons D-389) |', '|---|---|---|---|---|---|'];
  for (const k of Object.keys(etiquettes)) {
    const p = prefixes[k] || { ecart: 0, ok: 0, nr: 0, retire: 0 };
    tete.push('| ' + etiquettes[k] + ' | ' + (p.ecart + p.ok + p.nr) + ' | ' + p.ecart + ' | ' + p.ok + ' | ' + p.nr + ' | ' + p.retire + ' |');
  }
  tete.push('| **Total** | **' + (NE + NO + NN) + '** | **' + NE + '** | **' + NO + '** | **' + NN + '** | **' + NRT + '** |');
  const neufNr = f => /^N[A-Z]\d?-/.test(f[1]);
  const rep2 = S.filter(x => x.nEc + x.nOk > 0 || nrLignes.some(f => f[0] === x.section && neufNr(f)));
  const sect = ['| Section du tableau | Écarts | Conformes | Non relevables | Éléments énumérés |', '|---|---|---|---|---|'];
  let tE = 0, tO = 0, tN = 0;
  for (const x of rep2) {
    const nr = nrLignes.filter(f => f[0] === x.section && neufNr(f)).length;
    tE += x.nEc; tO += x.nOk; tN += nr;
    sect.push('| ' + x.section + ' | ' + x.nEc + ' | ' + x.nOk + ' | ' + nr + ' | ' + (x.nEc + x.nOk + nr) + ' |');
  }
  sect.push('| **Total** | **' + tE + '** | **' + tO + '** | **' + tN + '** | **' + (tE + tO + tN) + '** |');
  let t = fs.readFileSync(neufs, 'utf8');
  const remplacerTableau = (debut, lignes) => {
    const L = t.split('\n'); const i = L.findIndex(l => l.startsWith(debut));
    if (i < 0) throw new Error('tableau introuvable : ' + debut);
    let j = i; while (j < L.length && L[j].startsWith('|')) j++;
    L.splice(i, j - i, ...lignes); t = L.join('\n');
  };
  remplacerTableau('| Ensemble | Éléments', tete);
  remplacerTableau('| Section du tableau | Écarts', sect);
  fs.writeFileSync(neufs, t);
  console.log('Tableau de tête et répartition par section réécrits dans ' + path.basename(neufs) + ' : ' + (NE + NO + NN) + ' éléments comptés (' + NE + ' écarts, ' + NO + ' conformes, ' + NN + ' non relevables), ' + NRT + ' retirés');
}

// Ajout du Rapporteur (hub) : écrit sur la sortie la liste des identifiants dont le statut est « valide » (= écart ouvert), pour les compteurs. Ne modifie aucun fichier.
process.stdout.write("@@VALIDES@@" + JSON.stringify(tous.filter(i => statut(i) === "valide")) + "@@FIN@@");

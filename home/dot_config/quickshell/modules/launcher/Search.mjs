// GENERATED from Search.mts by scripts/build-quickshell-ts.sh - do not edit.
// Shared launcher search engine (Apps, Clipboard, Library, Music).
//
// SOURCE OF TRUTH: edit this file, then run `scripts/build-quickshell-ts.sh`
// to regenerate Search.mjs (which QML imports and which is committed, so
// `chezmoi apply` never needs a build).
//
//   match(fields, query, opts) -> null | { score, positions, typo }
//
// - Text is normalised first (accents stripped, Unicode dashes/quotes
//   folded to ASCII, lowercased) so "jhene" finds "Jhené" and "a-ha" finds
//   "a‐ha".
// - The query is split on whitespace and EVERY word must match some field
//   (in any order) - "fire fox", "sys mon", "karol wow".
// - Each word is scored with an fzf-v2-style optimal alignment (modified
//   Smith-Waterman): bonuses for word starts / camelCase / runs of
//   consecutive letters, affine gap penalties. Unlike a greedy left-most
//   scan this finds the best alignment, so acronyms ("vsc" -> Visual
//   Studio Code) and word-prefixes rank properly.
// - A word that doesn't match at all can still match with a typo
//   (Damerau-Levenshtein against each word of the field, prefix-aware),
//   ranked well below real matches: "discrod" -> Discord, "firfox" ->
//   Firefox.
// - `strict` mode (for long free text like clipboard entries) only accepts
//   contiguous substrings - scattered-letter matches across a paragraph
//   are almost always noise.
//
// Scores are normalised to roughly 0..130 per query (100 = every word is a
// perfect word-prefix run, + bonuses for exact/prefix-of-field), so callers
// can add usage boosts on a known scale.
// ---------- normalisation ----------
const _cache = {};
let _cacheSize = 0;
function _normChar(c) {
    let n = c;
    if (c.charCodeAt(0) > 127) {
        n = c.normalize("NFKD").replace(/[̀-ͯ]/g, "");
        if (/[‐-―−﹘﹣－]/.test(n))
            n = "-";
        else if (/[‘’‚‛′]/.test(n))
            n = "'";
        else if (/[“-‟″]/.test(n))
            n = '"';
    }
    return n.toLowerCase();
}
function _prep(input) {
    const text = input == null ? "" : String(input);
    const hit = _cache[text];
    if (hit)
        return hit;
    let s = "";
    const map = [];
    const cls = [];
    for (let i = 0; i < text.length; i++) {
        const c = text[i];
        const n = _normChar(c);
        const k = /[0-9]/.test(c) ? 3
            : (c !== c.toLowerCase()) ? 2
                : (c !== c.toUpperCase() || /[a-z0-9]/.test(n)) ? 1
                    : 0;
        for (let j = 0; j < n.length; j++) {
            s += n[j];
            map.push(i);
            cls.push(k);
        }
    }
    const out = { s, map, cls };
    if (_cacheSize > 4000) {
        for (const key in _cache)
            delete _cache[key];
        _cacheSize = 0;
    }
    _cache[text] = out;
    _cacheSize++;
    return out;
}
export function normalize(text) {
    return _prep(text).s;
}
export function tokenize(query) {
    return normalize(query).split(/\s+/).filter(t => t !== "");
}
// ---------- fuzzy alignment (fzf v2 style) ----------
const MATCH = 16;
const GAP_START = -3;
const GAP_EXT = -1;
const BONUS_BOUNDARY = 8;
const BONUS_CAMEL = 7;
const BONUS_CONSEC = 4;
const FIRST_MULT = 2;
const MAX_DP = 256; // longer haystacks fall back to substring-only
function _bonus(p, i) {
    const cur = p.cls[i];
    if (cur === 0)
        return 0;
    const prev = i === 0 ? 0 : p.cls[i - 1];
    if (prev === 0)
        return BONUS_BOUNDARY;
    if (prev === 1 && cur === 2)
        return BONUS_CAMEL;
    if (prev !== 3 && cur === 3)
        return BONUS_CAMEL;
    return 0;
}
// Best score a token of length m could get: all consecutive at a boundary.
function _maxScore(m) {
    return m * (MATCH + BONUS_BOUNDARY) + BONUS_BOUNDARY * (FIRST_MULT - 1);
}
function _align(p, tok) {
    const t = p.s;
    const n = t.length;
    const m = tok.length;
    if (m === 0)
        return { score: 0, pos: [] };
    if (m > n)
        return null;
    // Quick subsequence check before allocating anything.
    let ti = 0;
    for (let qi = 0; qi < m; qi++) {
        ti = t.indexOf(tok[qi], ti);
        if (ti < 0)
            return null;
        ti++;
    }
    if (n > MAX_DP)
        return _substring(p, tok);
    const bonus = new Array(n);
    for (let j = 0; j < n; j++)
        bonus[j] = _bonus(p, j);
    const NEG = -1e9;
    let prevRow = new Array(n).fill(NEG);
    let prevRun = new Array(n).fill(0);
    const back = []; // back[i][j] = index of q[i-1] match, -1 none
    // Row 0
    for (let j = 0; j < n; j++) {
        if (t[j] === tok[0]) {
            prevRow[j] = MATCH + bonus[j] * FIRST_MULT;
            prevRun[j] = bonus[j];
        }
    }
    back.push(new Array(n).fill(-1));
    for (let i = 1; i < m; i++) {
        const row = new Array(n).fill(NEG);
        const run = new Array(n).fill(0);
        const bk = new Array(n).fill(-1);
        let gapBest = NEG; // best M[i-1][k] + gap penalty for arriving at j
        let gapArg = -1;
        const c = tok[i];
        for (let j = i; j < n; j++) {
            // Extend the running best gapped predecessor to column j.
            if (gapBest > NEG)
                gapBest += GAP_EXT;
            if (j >= 2 && prevRow[j - 2] > NEG) {
                const cand = prevRow[j - 2] + GAP_START;
                if (cand >= gapBest) {
                    gapBest = cand;
                    gapArg = j - 2;
                }
            }
            if (t[j] !== c)
                continue;
            let best = NEG, arg = -1, r = 0;
            if (prevRow[j - 1] > NEG) {
                const rb = Math.max(prevRun[j - 1], bonus[j], BONUS_CONSEC);
                const v = prevRow[j - 1] + MATCH + Math.max(bonus[j], rb);
                if (v > best) {
                    best = v;
                    arg = j - 1;
                    r = bonus[j] >= BONUS_BOUNDARY ? bonus[j] : rb;
                }
            }
            if (gapBest > NEG) {
                const v = gapBest + MATCH + bonus[j];
                if (v > best) {
                    best = v;
                    arg = gapArg;
                    r = bonus[j];
                }
            }
            row[j] = best;
            run[j] = r;
            bk[j] = arg;
        }
        prevRow = row;
        prevRun = run;
        back.push(bk);
    }
    let bestJ = -1, bestScore = NEG;
    for (let j = 0; j < n; j++) {
        if (prevRow[j] > bestScore) {
            bestScore = prevRow[j];
            bestJ = j;
        }
    }
    if (bestJ < 0 || bestScore <= NEG)
        return null;
    const pos = new Array(m);
    let j = bestJ;
    for (let i = m - 1; i >= 0; i--) {
        pos[i] = j;
        j = back[i][j];
    }
    return { score: bestScore, pos };
}
// Contiguous-only match: best occurrence (prefers word boundaries).
function _substring(p, tok) {
    const t = p.s;
    const m = tok.length;
    let best = null;
    let idx = t.indexOf(tok);
    let guard = 0;
    while (idx >= 0 && guard++ < 50) {
        const b = _bonus(p, idx);
        const score = m * MATCH + b * FIRST_MULT + (m - 1) * Math.max(b, BONUS_CONSEC);
        if (!best || score > best.score) {
            const pos = [];
            for (let k = 0; k < m; k++)
                pos.push(idx + k);
            best = { score, pos };
        }
        idx = t.indexOf(tok, idx + 1);
    }
    return best;
}
// ---------- typo tolerance ----------
// Damerau-Levenshtein (optimal string alignment), bailing out above `max`.
function _dl(a, b, max) {
    const al = a.length, bl = b.length;
    if (Math.abs(al - bl) > max)
        return max + 1;
    let prev2 = null;
    let prev = new Array(bl + 1);
    for (let j = 0; j <= bl; j++)
        prev[j] = j;
    for (let i = 1; i <= al; i++) {
        const cur = new Array(bl + 1);
        cur[0] = i;
        let rowMin = cur[0];
        for (let j = 1; j <= bl; j++) {
            const cost = a[i - 1] === b[j - 1] ? 0 : 1;
            let v = Math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost);
            if (prev2 && i > 1 && j > 1 && a[i - 1] === b[j - 2] && a[i - 2] === b[j - 1])
                v = Math.min(v, prev2[j - 2] + 1);
            cur[j] = v;
            if (v < rowMin)
                rowMin = v;
        }
        if (rowMin > max)
            return max + 1;
        prev2 = prev;
        prev = cur;
    }
    return prev[bl];
}
function _allowedTypos(len) {
    return len < 4 ? 0 : len < 8 ? 1 : 2;
}
// Token vs each word of the field; a word may be longer than the token
// (the user hasn't finished typing), so compare against its prefixes too.
function _typo(p, tok) {
    const max = _allowedTypos(tok.length);
    if (max === 0)
        return null;
    const re = /[a-z0-9]+/g;
    let mm;
    let best = null;
    while ((mm = re.exec(p.s)) !== null) {
        const w = mm[0];
        if (w.length < tok.length - max)
            continue;
        let d = max + 1;
        for (let L = Math.max(1, tok.length - max); L <= Math.min(w.length, tok.length + max); L++) {
            d = Math.min(d, _dl(tok, w.slice(0, L), max));
            if (d === 0)
                break;
        }
        if (d <= max && (!best || d < best.d)) {
            const pos = [];
            for (let k = 0; k < Math.min(w.length, tok.length); k++)
                pos.push(mm.index + k);
            best = { d, pos };
        }
    }
    if (!best)
        return null;
    // Well below any real match of the same length.
    return { score: _maxScore(tok.length) * (best.d === 1 ? 0.55 : 0.4), pos: best.pos };
}
/**
 * Score `fields` against `query`. Every query word must match some field.
 * The first field is the display field; match positions are reported for
 * it (for highlighting) even when another field won the score.
 * Plain-string fields weigh 1 (first) / 0.6 (others).
 */
export function match(fields, query, opts = {}) {
    const strict = !!opts.strict;
    const typos = opts.typos !== undefined ? opts.typos : !strict;
    const minQuality = opts.minQuality !== undefined ? opts.minQuality : 0.3;
    const tokens = Array.isArray(query) ? query : tokenize(query);
    if (tokens.length === 0)
        return { score: 0, positions: [], typo: false };
    const fs = [];
    for (let i = 0; i < fields.length; i++) {
        const f = fields[i];
        if (f == null)
            continue;
        const text = typeof f === "string" ? f : f.text;
        if (!text)
            continue;
        const w = typeof f === "string" ? (i === 0 ? 1 : 0.6) : (f.weight || 1);
        fs.push({ idx: i, p: _prep(text), w });
    }
    if (fs.length === 0)
        return null;
    let total = 0;
    let anyTypo = false;
    const positions = [];
    const full = tokens.join(" ");
    for (const tok of tokens) {
        const max = _maxScore(tok.length);
        let best = null;
        let dispPos = null; // display-field match, for highlighting even if another field won
        for (const f of fs) {
            const r = strict ? _substring(f.p, tok) : _align(f.p, tok);
            if (!r)
                continue;
            let q = r.score / max;
            // Each run of consecutive matched letters that starts mid-word
            // (not at a word start / camelCase hump) is a sign of a
            // coincidental scatter rather than intent: "vsc" across "VLC
            // media player" vs. the V-S-C word starts of "Visual Studio Code".
            let runs = 1;
            for (let k = 0; k < r.pos.length; k++) {
                const runStart = k === 0 || r.pos[k] !== r.pos[k - 1] + 1;
                if (!runStart)
                    continue;
                if (k > 0)
                    runs++;
                if (_bonus(f.p, r.pos[k]) === 0)
                    q -= k === 0 ? 0.08 : 0.15;
                else if (k > 0)
                    q -= 0.04; // even word-start jumps cost a little
            }
            // Many separate runs = letters fished out of a long string.
            if (runs > 3)
                q -= 0.1 * (runs - 3);
            // A scattered match spread thinly is noise ("pav" in
            // "VLC media player (VCD)"); keep it only if reasonably tight.
            if (q < minQuality)
                continue;
            if (f.idx === 0)
                dispPos = r.pos;
            q *= f.w;
            if (!best || q > best.q)
                best = { q, f, pos: r.pos, typo: false };
        }
        if (!best && typos) {
            for (const f of fs) {
                const r = _typo(f.p, tok);
                if (!r)
                    continue;
                const q = (r.score / max) * f.w;
                if (!best || q > best.q)
                    best = { q, f, pos: r.pos, typo: true };
            }
        }
        if (!best)
            return null;
        total += Math.min(best.q, 1.2);
        if (best.typo)
            anyTypo = true;
        const hl = best.f.idx === 0 ? best.pos : dispPos;
        if (hl && fs[0].idx === 0) {
            for (const k of hl)
                positions.push(fs[0].p.map[k]);
        }
    }
    let score = (total / tokens.length) * 100;
    // Whole-query bonuses against the display field.
    const disp = fs[0].idx === 0 ? fs[0].p.s : "";
    if (disp) {
        if (disp === full)
            score += 30;
        else if (disp.startsWith(full))
            score += 18;
        else if (disp.indexOf(" " + full) >= 0 || disp.indexOf("-" + full) >= 0)
            score += 8;
        // Shorter names win near-ties ("Zed" over "Zed Preview").
        score += Math.max(0, 6 - disp.length / 6);
    }
    return { score, positions, typo: anyTypo };
}
function _esc(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}
/** Qt StyledText with the matched characters emphasised (underlined + `color`). */
export function highlight(text, positions, color) {
    const src = text || "";
    if (!positions || positions.length === 0)
        return _esc(src);
    const set = new Set(positions);
    let out = "", open = false;
    for (let i = 0; i < src.length; i++) {
        const on = set.has(i);
        if (on && !open) {
            out += "<u><font color=\"" + String(color) + "\">";
            open = true;
        }
        else if (!on && open) {
            out += "</font></u>";
            open = false;
        }
        out += _esc(src[i]);
    }
    if (open)
        out += "</font></u>";
    return out;
}
// ---------- usage learning (frecency + query associations) ----------
const HALF_LIFE_MS = 1000 * 60 * 60 * 24 * 14; // 2 weeks
export function decayed(value, since, now) {
    if (!value || !since)
        return 0;
    return value * Math.pow(0.5, Math.max(0, now - since) / HALF_LIFE_MS);
}
/**
 * Decayed launch count. Older entries without `rank` are migrated from
 * count/lastUsed.
 */
export function frecency(u, now) {
    if (!u)
        return 0;
    const rank = u.rank !== undefined ? u.rank : Math.min(u.count || 0, 20);
    return decayed(rank, u.lastUsed, now);
}
/** 0..30 boost from launch history. */
export function frecencyBoost(u, now) {
    const f = frecency(u, now);
    return f > 0 ? Math.min(30, 10 * Math.log2(1 + f)) : 0;
}
/**
 * Prefix keys a launch is learned under: "f", "fi", "fir" ... (max 8), so
 * typing just "f" later already prefers what "fir" opened.
 */
export function learnKeys(query) {
    const q = tokenize(query).join(" ");
    const keys = [];
    for (let i = 1; i <= Math.min(q.length, 8); i++)
        keys.push(q.slice(0, i));
    return keys;
}
/** 0..70 boost for `id`: its share of past picks after typing this query. */
export function assocBoost(assoc, query, id, now) {
    if (!assoc)
        return 0;
    const key = tokenize(query).join(" ").slice(0, 8);
    const bucket = assoc[key];
    if (!bucket)
        return 0;
    let total = 0, mine = 0;
    for (const k in bucket) {
        const v = decayed(bucket[k].v, bucket[k].t, now);
        total += v;
        if (k === id)
            mine = v;
    }
    if (mine <= 0)
        return 0;
    // Share of past picks for this exact query, scaled by confidence.
    return 70 * (mine / total) * Math.min(1, total / 2);
}
const MAX_ASSOC_KEYS = 400;
/** Returns a new assoc object with this launch recorded (and pruned). */
export function recordAssoc(assoc, query, id, now) {
    const out = Object.assign({}, assoc || {});
    for (const key of learnKeys(query)) {
        const bucket = Object.assign({}, out[key] || {});
        const prev = bucket[id];
        bucket[id] = { v: decayed(prev ? prev.v : 0, prev ? prev.t : now, now) + 1, t: now };
        out[key] = bucket;
    }
    // Prune faded entries (copying, never mutating the caller's state).
    for (const key of Object.keys(out)) {
        const b = Object.assign({}, out[key]);
        let live = false;
        for (const k in b) {
            if (decayed(b[k].v, b[k].t, now) < 0.05)
                delete b[k];
            else
                live = true;
        }
        if (live)
            out[key] = b;
        else
            delete out[key];
    }
    // Cap total keys, dropping the least recently used.
    const remaining = Object.keys(out);
    if (remaining.length > MAX_ASSOC_KEYS) {
        const lastUse = (key) => Math.max(...Object.values(out[key]).map(e => e.t));
        remaining.sort((a, b) => lastUse(a) - lastUse(b));
        for (let i = 0; i < remaining.length - MAX_ASSOC_KEYS; i++)
            delete out[remaining[i]];
    }
    return out;
}

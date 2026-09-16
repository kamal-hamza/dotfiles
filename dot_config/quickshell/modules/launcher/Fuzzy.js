.pragma library

// Shared fuzzy scorer used by Apps/Clipboard search. Returns -1 when
// query isn't even a subsequence of text (no match at all), otherwise a
// score where higher is better - exact match > prefix match > substring
// match (bonus at word boundaries) > scattered subsequence match (bonus
// for longer consecutive runs, penalty for gaps and match position).
function score(text, query) {
    if (!query) return 0;
    text = (text || "").toLowerCase();
    query = query.toLowerCase();
    if (query === "") return 0;
    if (text === "") return -1;

    if (text === query) return 1000;
    if (text.startsWith(query)) return 500 + Math.max(0, 100 - text.length);

    const idx = text.indexOf(query);
    if (idx >= 0) {
        const wordBoundary = idx === 0 || /[\s\-_./]/.test(text[idx - 1]);
        return 300 + (wordBoundary ? 50 : 0) - idx;
    }

    let ti = 0;
    let consecutive = 0;
    let bestConsecutive = 0;
    let gaps = 0;
    let first = -1;
    for (let qi = 0; qi < query.length; qi++) {
        const found = text.indexOf(query[qi], ti);
        if (found === -1) return -1;
        if (first < 0) first = found;
        if (found === ti) consecutive++;
        else { gaps += found - ti; consecutive = 1; }
        bestConsecutive = Math.max(bestConsecutive, consecutive);
        ti = found + 1;
    }
    return 50 + bestConsecutive * 10 - gaps - first;
}

function matches(text, query) {
    return score(text, query) >= 0;
}

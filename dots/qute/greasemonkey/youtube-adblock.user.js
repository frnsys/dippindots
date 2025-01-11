// ==UserScript==
// @name           Hide YouTube ad elements
// @match          *://*.youtube.com/*
// ==/UserScript==

function hide_ads() {
  let promos = document.getElementsByTagName("ytd-ad-slot-renderer");
  for (let promo of promos) {
    promo.style.display = "none";
  }
}

hide_ads()
//Also rerun the code each time document change (i.e new posts are added when user scroll down)
document.addEventListener("DOMNodeInserted", hide_ads);

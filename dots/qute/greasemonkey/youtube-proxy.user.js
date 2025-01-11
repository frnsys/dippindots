// ==UserScript==
// @name           Redirect YouTube videos to Piped
// @match          https://www.youtube.com/watch*
// @run-at         document-start
// @grant          window.onurlchange
// ==/UserScript==

(function() {
  location.href = location.href.replace("www.youtube.com/","piped.video/");
})();

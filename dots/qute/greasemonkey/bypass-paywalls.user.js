// ==UserScript==
// @name         Paywall Bypass Script (12ft.io, Google Cache, PaywallBuster.com)
// @namespace    http://tampermonkey.net/
// @version      1.2.2
// @description  Mobile and desktop-friendly paywall bypass with dropdown menu and right-click options. Added Mobile + Desktop support.
// @author       sharmanhall
// @license      MIT
// @icon         data:image/png;base64,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
// @match       *://*.adelaidenow.com.au/*
// @match       *://*.adweek.com/*
// @match       *://*.afr.com/*
// @match       *://*.ambito/*
// @match       *://*.ampproject.org/*
// @match       *://*.baltimoresun.com/*
// @match       *://*.barrons.com/*
// @match       *://*.bizjournals.com/*
// @match       *://*.bloomberg.com/*
// @match       *://*.bloombergquint.com/*
// @match       *://*.bostonglobe.com/*
// @match       *://*.brisbanetimes.com.au/*
// @match       *://*.britannica.com/*
// @match       *://*.businessinsider.com/*
// @match       *://*.caixinglobal.com/*
// @match       *://*.cen.acs.org/*
// @match       *://*.centralwesterndaily.com.au/*
// @match       *://*.chicagobusiness.com/*
// @match       *://*.chicagotribune.com/*
// @match       *://*.corriere.it/*
// @match       *://*.courant.com/*
// @match       *://*.couriermail.com.au/*
// @match       *://*.dailypress.com/*
// @match       *://*.dailytelegraph.com.au/*
// @match       *://*.delfi.ee/*
// @match       *://*.demorgen.be/*
// @match       *://*.denverpost.com/*
// @match       *://*.df.cl/*
// @match       *://*.dynamed.com/*
// @match       *://*.economist.com/*
// @match       *://*.elmercurio.com/*
// @match       *://*.elmundo.es/*
// @match       *://*.elu24.ee/*
// @match       *://*.entreprenal.com/*
// @match       *://*.examiner.com.au/*
// @match       *://*.expansion.com/*
// @match       *://*.fd.nl/*
// @match       *://*.financialpost.com/*
// @match       *://*.fnlondon.com/*
// @match       *://*.foreignpolicy.com/*
// @match       *://*.fortune.com/*
// @match       *://*.ft.com/*
// @match       *://*.gelocal.it/*
// @match       *://*.genomeweb.com/*
// @match       *://*.glassdoor.com/*
// @match       *://*.globes.co.il/*
// @match       *://*.groene.nl/*
// @match       *://*.haaretz.co.il/*
// @match       *://*.haaretz.com/*
// @match       *://*.harpers.org/*
// @match       *://*.hbr.org/*
// @match       *://*.hbrchina.org/*
// @match       *://*.heraldsun.com.au/*
// @match       *://*.historyextra.com/*
// @match       *://*.humo.be/*
// @match       *://*.ilmanifesto.it/*
// @match       *://*.inc.com/*
// @match       *://*.inquirer.com/*
// @match       *://*.interest.co.nz/*
// @match       *://*.investorschronicle.co.uk/*
// @match       *://*.irishtimes.com/*
// @match       *://*.japantimes.co.jp/*
// @match       *://*.journalnow.com/*
// @match       *://*.kansascity.com/*
// @match       *://*.labusinessjournal.com/*
// @match       *://*.lanacion.com.ar/*
// @match       *://*.lastampa.it/*
// @match       *://*.latercera.com/*
// @match       *://*.latimes.com/*
// @match       *://*.lavoixdunord.fr/*
// @match       *://*.lecho.be/*
// @match       *://*.leparisien.fr/*
// @match       *://*.lesechos.fr/*
// @match       *://*.loebclassics.com/*
// @match       *://*.lrb.co.uk/*
// @match       *://*.mcall.com/*
// @match       *://*.medium.com/*
// @match       *://*.medscape.com/*
// @match       *://*.mercurynews.com/*
// @match       *://*.mv-voice.com/*
// @match       *://*.nationalpost.com/*
// @match       *://*.netdna-ssl.com/*
// @match       *://*.news-gazette.com/*
// @match       *://*.newstatesman.com/*
// @match       *://*.newyorker.com/*
// @match       *://*.nrc.nl/*
// @match       *://*.ntnews.com.au/*
// @match       *://*.nydailynews.com/*
// @match       *://*.nymag.com/*
// @match       *://*.nytimes.com/*
// @match       *://*.nzherald.co.nz/*
// @match       *://*.nzz.ch/*
// @match       *://*.ocregister.com/*
// @match       *://*.orlandosentinel.com/*
// @match       *://*.outbrain.com/*
// @match       *://*.paloaltoonline.com/*
// @match       *://*.parool.nl/*
// @match       *://*.piano.io/*
// @match       *://*.poool.fr/*
// @match       *://*.postimees.ee/*
// @match       *://*.qiota.com/*
// @match       *://*.qz.com/*
// @match       *://*.repubblica.it/*
// @match       *://*.republic.ru/*
// @match       *://*.reuters.com/*
// @match       *://*.sandiegouniontribune.com/*
// @match       *://*.scientificamerican.com/*
// @match       *://*.scmp.com/*
// @match       *://*.seattletimes.com/*
// @match       *://*.seekingalpha.com/*
// @match       *://*.slate.com/*
// @match       *://*.smh.com.au/*
// @match       *://*.sofrep.com/*
// @match       *://*.spectator.co.uk/*
// @match       *://*.spectator.com.au/*
// @match       *://*.spectator.us/*
// @match       *://*.speld.nl/*
// @match       *://*.startribune.com/*
// @match       *://*.statista.com/*
// @match       *://*.stuff.co.nz/*
// @match       *://*.sueddeutsche.de/*
// @match       *://*.sun-sentinel.com/*
// @match       *://*.techinasia.com/*
// @match       *://*.technologyreview.com/*
// @match       *://*.telegraaf.nl/*
// @match       *://*.telegraph.co.uk/*
// @match       *://*.the-tls.co.uk/*
// @match       *://*.theadvocate.com.au/*
// @match       *://*.theage.com.au/*
// @match       *://*.theathletic.co.uk/*
// @match       *://*.theathletic.com/*
// @match       *://*.theatlantic.com/*
// @match       *://*.theaustralian.com.au/*
// @match       *://*.thediplomat.com/*
// @match       *://*.theglobeandmail.com/*
// @match       *://*.theherald.com.au/*
// @match       *://*.thehindu.com/*
// @match       *://*.themarker.com/*
// @match       *://*.themercury.com.au/*
// @match       *://*.thenation.com/*
// @match       *://*.thenational.scot/*
// @match       *://*.theolivepress.es/*
// @match       *://*.thesaturdaypaper.com.au/*
// @match       *://*.thestar.com/*
// @match       *://*.thewrap.com/*
// @match       *://*.tijd.be/*
// @match       *://*.time.com/*
// @match       *://*.tinypass.com/*
// @match       *://*.towardsdatascience.com/*
// @match       *://*.trouw.nl/*
// @match       *://*.vanityfair.com/*
// @match       *://*.vn.nl/*
// @match       *://*.volkskrant.nl/*
// @match       *://*.washingtonpost.com/*
// @match       *://*.wired.com/*
// @match       *://*.wsj.com/*
// @match       *://*.zeit.de/*
// @match       *://*.usatoday.com/*
// @match       *://*.time.com/*
// @match       *://*.theatlantic.com/*
// @match       *://*.americanbanker.com/*
// @match       *://*.japantimes.co.jp/*
// @match       *://*.wsj.com/*
// @match       *://*.cnbc.com/*
// @match       *://*.financialpost.com/*
// @match       *://*.wired.com/*
// @match       *://*.seekingalpha.com/*
// @match       *://*.ipolitics.ca/*
// @match       *://*.discovermagazine.com/*
// @match       *://*.faz.net/*
// @match       *://*.rp-online.de/*
// @match       *://*.spiegel.de/*
// @match       *://*.tagesspiegel.de/*
// @match       *://*.welt.de/*
// @match       *://*.wz.de/*
// @match       *://*.rp.pl/*
// @match       *://*.wyborcza.pl/*
// @match       *://*.tagesanzeiger.ch/*
// @match       *://*.elpais.com/*
// @match       *://*.english.elpais.com/*
// @grant        GM_registerMenuCommand
// @grant        GM_addStyle
// @grant        GM_addElement
// @downloadURL https://update.greasyfork.org/scripts/495817/Paywall%20Bypass%20Script%20%2812ftio%2C%20Google%20Cache%2C%20PaywallBustercom%29.user.js
// @updateURL https://update.greasyfork.org/scripts/495817/Paywall%20Bypass%20Script%20%2812ftio%2C%20Google%20Cache%2C%20PaywallBustercom%29.meta.js
// ==/UserScript==

(function() {
    'use strict';

    // Constants
    const _12FT_PREFIX = "https://12ft.io/proxy?ref=pro&q=";
    const _12FT_ORIGIN = new URL(_12FT_PREFIX).origin;
    const PAYWALLBUSTER_PREFIX = "https://paywallbuster.com/q/";
    const PAYWALLBUSTER_ORIGIN = new URL(PAYWALLBUSTER_PREFIX).origin;

    // Add right-click menu options
    GM_registerMenuCommand("Bypass with 12ft", () => bypassPage());
    GM_registerMenuCommand("Bypass with PaywallBuster", () => bypassWithPaywallBuster());
    GM_registerMenuCommand("Archive Today", () => archivePage('https://archive.today/newest/'));
    GM_registerMenuCommand("Archive Is", () => archivePage('https://archive.is/newest/'));
    GM_registerMenuCommand("Archive Ph", () => archivePage('https://archive.ph/newest/'));
    GM_registerMenuCommand("Remove Paywall", () => archivePage('https://removepaywall.com/search?url='));
    GM_registerMenuCommand("Google Cache", () => archivePage('https://webcache.googleusercontent.com/search?q=cache:'));
    GM_registerMenuCommand("Yandex Cache", () => archivePage('https://www.yandex.ru/search/?site='));
    //GM_registerMenuCommand("Cached View -- Broken", () => archivePage('https://cachedview.foundtt.com/'));
    GM_registerMenuCommand("Yahoo Cache", () => archivePage('https://search.yahoo.com/search?p='));
    GM_registerMenuCommand("Bing Cache", () => archivePage('https://www.bing.com/search?q=url:'));
    GM_registerMenuCommand("Similar Web", () => archivePage('https://www.similarweb.com/ru/website/'));

    // Add styles for floating button and dropdown
    GM_addStyle(`
        #bypassContainer {
            position: fixed;
            bottom: 10px;
            right: 10px;
            z-index: 99999999999;
            font-family: Arial, sans-serif;
        }
        #bypassButton {
            background: #333;
            color: white;
            border: none;
            padding: 8px 12px;
            cursor: pointer;
            font-size: 14px;
            display: flex;
            align-items: center;
            opacity: 0.8;
            border-radius: 4px;
            min-width: 150px;
        }
        #bypassButton:hover {
            opacity: 1;
        }
        #bypassButton img {
            width: 20px;
            margin-right: 8px;
        }
        #bypassDropdown {
            display: none;
            position: absolute;
            bottom: 100%;
            right: 0;
            background: white;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 5px;
            width: 200px;
        }
        #bypassDropdown.show {
            display: block;
        }
        .bypass-option {
            padding: 10px 15px;
            cursor: pointer;
            color: #333;
            border-bottom: 1px solid #eee;
            font-size: 14px;
        }
        .bypass-option:last-child {
            border-bottom: none;
        }
        .bypass-option:hover {
            background: #f5f5f5;
        }
        @media (max-width: 768px) {
            #bypassButton {
                padding: 10px 15px;
                font-size: 16px;
            }
            .bypass-option {
                padding: 12px 15px;
                font-size: 16px;
            }
        }
    `);

    // Create container and button elements
    const container = document.createElement('div');
    container.id = 'bypassContainer';

    const button = document.createElement('button');
    button.id = 'bypassButton';
    button.innerHTML = '<img src="data:image/png;charset=utf-8;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAMAAAD04JH5AAAASFBMVEUAAAD////////////////////////////////////////////////////////////////////////////////////////////neHiwAAAAF3RSTlMAECAwQFBfYG9wf4CPkJ+gr7C/z9Df7yIhVIsAAAW1SURBVHic7VvZtpswDDTb5ZIUeuMU9P9/2nNMCF5mQAbap8xbwFi2pJHkJeaDDz744IMPPvjgYpRV07Zt29Z1af43irZ/TuLh+dPV5lrU/SQC31S3pyBMQ2OugpMu8kzfFK0VjvH7Cmu8pIvII35V3CbZxngz57BKF5F79LLdEy8iMp5whkC6iIQ2LbeU7+OgEmLpIlL5778105/xU5hcAOkSkKD4kQw880aApQckKEfJQsYImPSABLnyRQajwoZ0nwT58kU6s4tt6R4JjsiXaSck7UpfSVAckb9tBI30lQS/5Bgqg6GU/iZBKwfRY/k4kyHMJCj18SfChKkoaswk+M0bPIdhsBsOApNCJWo4ElADTPfXBGuqU2iDRtRwTsQm6If7O2kzogH0oobZUECYqFmeQE6gTakvEhD1RoVCQRwVxaI8EtT4VaLbB24HasRC1LhzCiQzI5Zq0wGQKSE01AVT7y4FAgygEzUqOtzUtESxYAB5JMCtUZYRCDAARAL7B338pJRBAU4ggBPGfJn6psA+/ACtHVB4ISaotxtOtpszJqTmnYXth0lBAnyakFevGvv6Hafgxw3zQVRrkQCfNpxJMNnOd2Q8/IqxG7kAjhdgadmHU5+Bh2+M6UYAWHDjeAHocu9K8BB9DEbPQeKFdrVOSaAGidjaxQkjgRokEFujA+ZwzmYHUUBrdMAGZDU1AFEArIcQcH4yepAa55dRAmacDBJ8C4Z6twhOQE8Ctm7Qe/F06nO2cBzVCjhJArZw1FLgLAlugqGNAWdJwORPGfuVZ0jwJQSK7ZE3TpCAylduEM04TgIqf8zZpMPViIYEVH6OA7BqREECKj8rj7Gl9f53XH5OImfVyD4JiPzRDjkEMKwa2SUB4r9bYuRDEPa0COSP7RHpB0mQyp9yFf/GERIMSfvx+EkRJMG09UWRyv9TvF9W7iAxo56DJNhKZUW6lF7kF7c1rKsrqlwSlKn8l/7DA7VNJXrA1Qj3KLRxX6I3Wg3gaoSeuyH5M2WrKKdpCxJcjTAfqoD8OfMlI9MmZFiNMPtVKHPPtV8yMm1CgNUIUd8XrBycB6QbCc6Nvoc3WJiEfWIS4PQzt01N42KpRzGDkUECUn46CwQKsF1VVo1TzPqQkUJPAlb+On/1o5m3HvDyDIssahIg+W3bNvNYyXl7gx/70JJgAM1WrXozDZbkXu8svepIUAzbzbyZBqr2emeRRUWCAu7kelrt0MOgdxpZYM8RCUos39MqUbVHMRaYcTUSkoCeGzut9tZa6+nxaa219sfcrLVeFJjc45RduCQP7MXPrd1rvDlhcZZPHQFWI4G9KirfkYBskve41DUJ4Dh9e1X82Na5G9kh7aBzAUeAX3sk+NqRzw6AauhcaTTcIwFffS10IwdABXSuNMXskICFf4/ueIdwws6VSwKF/DwSpCXBJgk25P/UtVf5s3jjmYfVmFskgOHfw+pRNXoYmoeUQ5jE86nonnycCQI3W82TV424TvZPmNeg7+3V+6pWZIKNI6n9E+bVB4iqvS7IZRZCYteJ7oR59tc46b7M43WRVY3MnehOmJ1qq/R3Y3QkgCSe7aW7ZuFWP14061+/K3OaBLprFs5f7+nvaHoHSKC8a+RU+0h+x4k6ryR3nSjvGjnVPpPfTqA3vaySfO5Ed9docfoFriQvLiEBu5gUApKgTkmQVZLPJCCXciIsTh/8bl9W9KZH5GM7zyTQsTAmwTJzZ8VzJNBd4ItJ8KK/lgTYzq5T5WWnmASvsS+usICRANvZdaq77LQ4/YJl5osrLMjcvc8Eq0Y8/bJceA3YutQbwNRWZZmxd5sHtgUQh9mMc8w8sC2AOJZmnePlwCNs8Dwm0r/yxJgEK6JYdvg8YweMBAmVr/v7TQhWkieB7ur/IC3YKvyCEVzx5x+EzcKvXC/7ao8vrkbZ3PthuLf/LAx9kIu/KxNpLm8PllAAAAAASUVORK5CYII="> Bypass Paywall (12ft.io)';

        const dropdown = document.createElement('div');
    dropdown.id = 'bypassDropdown';

    // Add dropdown options
    const options = [
        { text: '12ft.io', action: bypassPage },
        { text: 'PaywallBuster', action: bypassWithPaywallBuster },
        { text: 'Archive.today', action: () => archivePage('https://archive.today/newest/') },
        { text: 'Archive.is', action: () => archivePage('https://archive.is/newest/') },
        { text: 'Archive.ph', action: () => archivePage('https://archive.ph/newest/') },
        { text: 'RemovePaywall', action: () => archivePage('https://removepaywall.com/search?url=') },
        { text: 'Google Cache', action: () => archivePage('https://webcache.googleusercontent.com/search?q=cache:') },
        { text: 'Yandex Cache', action: () => archivePage('https://www.yandex.ru/search/?site=') },
        //{ text: 'CachedView -- Broken', action: () => archivePage('https://cachedview.foundtt.com/') },
        { text: 'Yahoo Cache', action: () => archivePage('https://search.yahoo.com/search?p=') },
        { text: 'Bing Cache', action: () => archivePage('https://www.bing.com/search?q=url:') },
        { text: 'Similar Web', action: () => archivePage('https://www.similarweb.com/ru/website/') },
    ];

    options.forEach(option => {
        const div = document.createElement('div');
        div.className = 'bypass-option';
        div.textContent = option.text;
        div.addEventListener('click', (e) => {
            e.stopPropagation();
            option.action();
            dropdown.classList.remove('show');
        });
        dropdown.appendChild(div);
    });

    // Add elements to container
    container.appendChild(button);
    container.appendChild(dropdown);
    document.body.appendChild(container);

    // Toggle dropdown on button click
    button.addEventListener('click', (e) => {
        e.stopPropagation();
        const currentUrl = window.location.href;
        if (currentUrl.startsWith(_12FT_ORIGIN) || currentUrl.startsWith(PAYWALLBUSTER_ORIGIN)) {
            goBack();
        } else {
            dropdown.classList.toggle('show');
        }
    });

    // Close dropdown when clicking outside
    document.addEventListener('click', () => {
        dropdown.classList.remove('show');
    });

    // Function to bypass paywall with 12ft.io
    function bypassPage() {
        const currentUrl = window.location.href;
        if (isValidProtocol(currentUrl)) {
            window.location.href = _12FT_PREFIX + currentUrl;
        }
    }

    // Function to bypass paywall with PaywallBuster
    function bypassWithPaywallBuster() {
        const currentUrl = window.location.href;
        if (isValidProtocol(currentUrl)) {
            window.location.href = PAYWALLBUSTER_PREFIX + currentUrl;
        }
    }

    // Function to go back to original URL
    function goBack() {
        const currentUrl = window.location.href;
        const originalUrl = new URL(currentUrl).searchParams.get("q");
        if (originalUrl) {
            window.location.href = originalUrl;
        }
    }

    // Check if the protocol is valid (http or https)
    function isValidProtocol(url) {
        return new URL(url).protocol.startsWith("http");
    }

    // Remove banner on 12ft.io
    function removeBanner() {
        const banner = document.getElementById('ad');
        if (banner) {
            banner.remove();
        }
    }

    // Function to open archive pages
    function archivePage(baseURL) {
        const currentUrl = window.location.href;
        if (isValidProtocol(currentUrl)) {
            window.location.href = baseURL + encodeURIComponent(currentUrl);
        }
    }

    // Mutation observer to remove banner if it appears
    const observer = new MutationObserver((mutations) => {
        for (const mutation of mutations) {
            if (mutation.addedNodes.length) {
                removeBanner();
            }
        }
    });

    observer.observe(document.body, { childList: true, subtree: true });

    // Initial banner removal
    removeBanner();

    // Remove duplicate button inside iframe
    function removeDuplicateButton() {
        const iframe = document.getElementById('proxy-frame');
        if (iframe) {
            const iframeDocument = iframe.contentDocument || iframe.contentWindow.document;
            const duplicateButton = iframeDocument.getElementById('bypassButton');
            if (duplicateButton) {
                duplicateButton.remove();
            }
        }
    }

    window.addEventListener('load', removeDuplicateButton);
})();

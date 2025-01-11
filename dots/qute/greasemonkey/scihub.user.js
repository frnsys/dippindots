// ==UserScript==
// @name         Bypass paywalls for scientific documents
// @namespace    StephenP
// @version      3.4.3.1
// @description  Bypass paywalls for scientific documents by downloading them from sci-hub instead of paying something like 50 bucks for each paper. This script adds download buttons on Google Scholar, Scopus and Web Of Science, which lead to sci-hub.tw. In this way you can get free access to scientific papers even if you (or your university) can't afford their prices.
// @author       StephenP
// @include      http://scholar.google.*/scholar?*
// @match        http://www.scopus.com/record/display.uri?*
// @match        http://apps.webofknowledge.com/full_record.do?*
// @match        http://apps.webofknowledge.com/InterService.do?*
// @match        http://apps.webofknowledge.com/CitedFullRecord.do?*
// @include      https://scholar.google.*/scholar?*
// @match        https://www.scopus.com/record/display.uri?*
// @match        https://www.scopus.com/*
// @match        https://apps.webofknowledge.com/full_record.do?*
// @match        https://apps.webofknowledge.com/InterService.do?*
// @match        https://apps.webofknowledge.com/CitedFullRecord.do?*
// @contributionURL https://buymeacoffee.com/stephenp_greasyfork
// Following permissions are necessary to keep the sci-hub domain updated: once a day, the script checks if Sci-Hub can be reached at the known domain:
// if it can't be reached, the script retrieves the new domain (if it's been updated) from Sci-Hub's official VK account.
// @grant        GM.setValue
// @grant        GM.getValue
// @grant        GM.deleteValue
// @grant        GM.xmlHttpRequest
// @connect      vk.com
// @connect      *
// "connect *" is used as Sci-hub's domain can change, and the script needs to check whatever it thinks is the sci-hub's domain to see if it's valid.
// @license AGPL-3.0-or-later
// @downloadURL https://update.greasyfork.org/scripts/35521/Bypass%20paywalls%20for%20scientific%20documents.user.js
// @updateURL https://update.greasyfork.org/scripts/35521/Bypass%20paywalls%20for%20scientific%20documents.meta.js
// ==/UserScript==
/*
    Copyright (C) 2021  StephenP

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
(async function(){
  var sciHubDomain=await getSciHubDomain();
  if(sciHubDomain.toString().split(".").length>=2){//the last check, to verify if the result of getSciHubDomain is actually a web domain.
  	start(sciHubDomain);
  }
  else{
    start("https://sci-hub.ru/");//fallback to default domain
  }
})();
async function getSciHubDomain(){
  var url=await GM.getValue("scihubDomain", "none");
  let date=new Date();
	const tsNow=date.getDate().toString()+"/"+date.getMonth().toString()+"/"+date.getFullYear().toString();
  var tsOld=await GM.getValue("lastSync", false);
  if((url==="none")||(tsNow!==tsOld)){
    if(!(await isSciHubReachable(url))){
      var newUrl=await setSciHubDomain(url);
      if(!(await isSciHubReachable(newUrl))){
        console.log("%cOld sci-hub domain ("+url+") is not available and no new domain has been found", "color: red; background-color: white; font-size: 2em");
        GM.deleteValue("lastSync");
      	return url;
      }
      else{
        let dateb=new Date();
        GM.setValue("lastSync",dateb.getDate().toString()+"/"+dateb.getMonth().toString()+"/"+dateb.getFullYear().toString());
        return newUrl;
      }
    }
    else{
      let datec=new Date();
      GM.setValue("lastSync",datec.getDate().toString()+"/"+datec.getMonth().toString()+"/"+datec.getFullYear().toString());
      return url;
    }
  }
  else{
    console.log("%cSci-hub domain has been already checked today and it was working. The script will keep using "+url, "color: green; background-color: white; font-size: 2em");
  	return url;
  }
}
async function setSciHubDomain(oldUrl){
  return new Promise((resolve, reject) =>{
    console.log("%cRequesting new sci-hub domain from official sci-hub's vk account", "color: orange; background-color: white; font-size: 2em");
    GM.xmlHttpRequest({
      method: "GET",
      url: "https://vk.com/sci_hub",
      onload: function(response) {
        let parser = new DOMParser();
        let doc = parser.parseFromString(response.responseText, "text/html");
        var url="not available";
        var possibleLinks=doc.querySelectorAll(".group_info_row.info a");
        if(possibleLinks.length==1){
          url=possibleLinks[0].textContent;
        }
        else if(possibleLinks.length>1){
          url=doc.querySelector('.group_info_row.info a[href*="sci-hub"]').textContent;
        }
        if(!oldUrl.includes(url)){
          console.log("%cNew sci-hub domain has been retrieved: "+url, "color: green; background-color: white; font-size: 2em");
          GM.setValue("scihubDomain","https://"+url+"/");
        }
        resolve("https://"+url+"/");
      },
      onerror: function(response){
        resolve(oldUrl);
      }
    });
  });
}
async function isSciHubReachable(d){
  if(d==="none"){
    return false;
  }
  else{
    return new Promise((resolve, reject) =>{
      console.log("%cTesting if sci-hub can be reached", "color: orange; background-color: white; font-size: 2em");
      GM.xmlHttpRequest({
        method: "GET",
        url: d+"donate",
        onload: function(response) {
          if((response.responseText.includes("12PCbUDS4ho7vgSccmixKTHmq9qL2mdSns"))||(response.responseText.includes("bc1q7eqheemcu6xpgr42vl0ayel6wj087nxdfjfndf"))){//if it's not the original sci-hub page, it's most likely not to show the real bitcoin addresses for donations. This is not a failsafe method, as a fake page could display another address and keep the real ones hidden.
            console.log("%cSci-hub is available, no need to update the domain.", "color: green; background-color: white; font-size: 2em");
            resolve(true);
          }
          else{
            console.log("%cSci-hub domain available, but there isn't the sci-hub website there. I'll try to update the domain.", "color: orange; background-color: white; font-size: 2em");
            resolve(false);
          }
        },
        onerror: function(response) {
          console.log("%cSci-hub domain not available, I'll try to update the domain.", "color: orange; background-color: white; font-size: 2em");
          resolve(false);
        }
      });
    });
  }
}
function start(sciHubUrl) {
    'use strict';
    console.log("%cCurrent Sci-Hub domain: "+sciHubUrl, "color: green; background-color: white; font-size: 2em");
    var documentId;
    var site=window.location.href.toString();
    var i;
    if(site.includes("://www.scopus.com/")){
      try{
        var fullDocument=document.createElement("LI");
        fullDocument.innerHTML="Full text from Sci-Hub";
        fullDocument.style.cursor="pointer";
        fullDocument.style.color="#ff6c00";
        console.log("::Bypass paywalls for scientific documents:: Obtaining document id...");
        documentId=document.getElementById("recordDOI").innerHTML;
        console.log("::Bypass paywalls for scientific documents:: Document id is "+documentId);
        fullDocument.addEventListener('click',function(){window.open(sciHubUrl+documentId)});
        console.log("::Bypass paywalls for scientific documents:: Finding a place where to put the Sci-Hub button...");
        document.getElementById('quickLinks').children[0].appendChild(fullDocument);
        console.log("::Bypass paywalls for scientific documents:: Sci-Hub button placed!");
        var donateBtn=document.createElement("LI");
        donateBtn.innerHTML="Donate to Sci-Hub";
        donateBtn.style.cursor="pointer";
        donateBtn.addEventListener('click',function(){donate(sciHubUrl)});
        console.log("::Bypass paywalls for scientific documents:: Finding a place where to put the donation button...");
        document.getElementById('quickLinks').children[0].appendChild(donateBtn);
        console.log("::Bypass paywalls for scientific documents:: Donation button placed!");
      }
      catch(err){
        console.log("::Bypass paywalls for scientific documents:: Error! "+err);
      }
    }
    else if(site.includes("://apps.webofknowledge.com/")){
        var mode;
        var genericID=document.getElementsByClassName("block-record-info block-record-info-source")[0].getElementsByClassName("FR_label");
      	for(i=0;i<=genericID.length;i++){
          if((genericID[i].innerHTML==="DOI:")||(genericID[i].innerHTML==="PMID:")){
            documentId=genericID[i].parentNode.children[1].innerHTML;
            console.log(documentId);
            break;
          }
        }
        if(documentId!==undefined){
            addButtonWOS(sciHubUrl,documentId);
        }
    }
    else if(site.includes("://scholar.google.")){
        var resourcesList=document.getElementById('gs_res_ccl_mid');
        var results=resourcesList.children.length;
        var gs_ggs_gs_fl;
        for(i=0;i<results;i++){
            try{
                if(resourcesList.children[i].getElementsByClassName("gs_ggs gs_fl").length==0){
                    gs_ggs_gs_fl=document.createElement("div");
                    gs_ggs_gs_fl.setAttribute("class","gs_ggs gs_fl");
                  	gs_ggs_gs_fl.appendChild(document.createElement("div"));
                  	gs_ggs_gs_fl.children[0].setAttribute("class","gs_ggsd");
                  	gs_ggs_gs_fl.children[0].appendChild(document.createElement("div"));
                  	gs_ggs_gs_fl.children[0].children[0].setAttribute("class","gs_or_ggsm");
                    resourcesList.children[i].insertBefore(gs_ggs_gs_fl,resourcesList.children[i].firstChild);
                    addButtonScholar(sciHubUrl,resourcesList.children[i].firstChild);
                }
                else{
                    addButtonScholar(sciHubUrl,resourcesList.children[i].firstChild);
                }
            }
            catch(err){
                console.error(err+"//"+resourcesList.children[i].lastElementChild.innerHTML);
            }
        }
    }
}
function addButtonWOS(sciHubUrl,documentId){
    try{
        var site=window.location.href.toString();
        const fTBtn=document.getElementsByClassName("solo_full_text")[0];
        var sciHubBtn = fTBtn.cloneNode(true);
        var list=document.getElementsByClassName("l-columns-item")[0];
        sciHubBtn.setAttribute("alt","Break the walls and free the knowledge that publishers taken hostage\!");
        sciHubBtn.setAttribute("title","Break the walls and free the knowledge that publishers taken hostage\!");
        sciHubBtn.setAttribute("id","sciHubBtn");
        sciHubBtn.getElementsByTagName('A')[0].innerHTML="Search on Sci-Hub";
        sciHubBtn.getElementsByTagName('A')[0].removeAttribute("href");
      sciHubBtn.getElementsByTagName('A')[0].removeAttribute("onclick");
        sciHubBtn.getElementsByTagName('A')[0].addEventListener("click",function(){window.open(sciHubUrl+documentId);});
        sciHubBtn.style.cursor="pointer";
        fTBtn.children[0].style.marginLeft="0";
        sciHubBtn.style.marginRight="0";
        list.insertAdjacentHTML('beforeend','<li><a style="font-size: 12px; margin-left: 10px; color: green; text-decoration: underline;" href="javascript:;">Donate to Sci-Hub project</a></li>');
        list.lastChild.lastChild.removeAttribute("href");
        list.lastChild.lastChild.addEventListener("click", function(){donate(sciHubUrl);});
        list.lastChild.lastChild.style.cursor="pointer";
        fTBtn.parentNode.insertBefore(sciHubBtn, fTBtn);
        //list.insertBefore(sciHubBtn,list.lastChild);
    }
    catch(err){
        console.log(err);
    }
    //setAttribute('onclick',donate(sciHubUrl));
}
function addButtonScholar(sciHubUrl,linkDiv){
  //alert(linkDiv.innerHTML);
    var link;
    try{
      link=linkDiv.getElementsByTagName("A")[0].href;
    }
  	catch(err){
      link=linkDiv.parentNode.getElementsByClassName("gs_rt")[0].getElementsByTagName("A")[0].href;
		}
    if(link.includes("scholar?output")){
      link=linkDiv.parentNode.getElementsByClassName("gs_rt")[0].getElementsByTagName("A")[0].href;
    }
  	if(link!=undefined){
      var creatingElement;
      if((link!=undefined)&&(link.search("patents.google")==-1)){
        creatingElement=document.createElement("a");
        creatingElement.innerHTML='<a>Search on Sci-Hub</a>';
        linkDiv.getElementsByClassName("gs_or_ggsm")[0].appendChild(creatingElement);
        linkDiv.getElementsByClassName("gs_or_ggsm")[0].lastChild.addEventListener("click", function(){window.open(sciHubUrl+link);});
        linkDiv.getElementsByClassName("gs_or_ggsm")[0].lastChild.style.cursor="pointer";
        //setAttribute("onclick",'window.open(\"'+sciHubUrl+link+'\");');
      }
    }

  	document.head.innerHTML = document.head.innerHTML.replace(/13px 8px 9px 8px/g, '0px 8px 0px 8px');
}
function donate(sciHubUrl){
    window.open(sciHubUrl+'#donate');
}

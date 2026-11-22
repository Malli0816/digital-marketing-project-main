(function(){
 var KEY='dms_chat_v1',API='/api/chat',msgs=[],open=false;
 try{msgs=JSON.parse(sessionStorage.getItem(KEY)||'[]')}catch(e){}
 function el(t,c,h){var e=document.createElement(t);if(c)e.className=c;if(h!=null)e.innerHTML=h;return e}
 var file=(location.pathname.split('/').pop()||'index.html').toLowerCase();
 var pageNames={'index.html':'Home','service-local-seo.html':'Local SEO','service-video-editing.html':'Video Editing','service-ai-promotional-videos.html':'AI Promotional Videos'};
 var pageName=pageNames[file]||(document.title.split('|')[0]||'').trim()||'this';
 var greeter=el('div','page-greeter'),greeting=el('span','page-greeter-message'),character=el('img','page-greeter-character');
 greeter.setAttribute('role','status');greeter.setAttribute('aria-live','polite');greeter.setAttribute('aria-atomic','true');
 character.src='assets/assistant-character.svg';character.alt='';character.setAttribute('aria-hidden','true');
 var greetingText="Hi! You are on the "+pageName+" page.";
 greeting.textContent=greetingText;
 greeter.appendChild(greeting);greeter.appendChild(character);document.body.appendChild(greeter);greeter.classList.add('is-intro');
 setTimeout(function(){greeter.classList.remove('is-intro')},4800);
 if('speechSynthesis' in window&&'SpeechSynthesisUtterance' in window){
  var utterance=new SpeechSynthesisUtterance(greetingText),speech=window.speechSynthesis,attempts=0,voiceTimer=null,leaving=false;
  var female=/female|woman|zira|hazel|susan|samantha|victoria|aria|jenny|heera|neerja|swara|priya|kavya|sara|libby|sonia/i;
  utterance.rate=.92;utterance.pitch=1.18;
  function speakFemale(){
   if(leaving)return;
   var voices=speech.getVoices(),voice=voices.find(function(v){return /zira/i.test(v.name)&&/^en/i.test(v.lang)})||voices.find(function(v){return /^en-in/i.test(v.lang)&&female.test(v.name)})||voices.find(function(v){return /^en/i.test(v.lang)&&female.test(v.name)});
   if(!voice){if(attempts++<15)voiceTimer=setTimeout(speakFemale,100);return}
   speech.cancel();utterance.voice=voice;utterance.lang=voice.lang;speech.speak(utterance)
  }
  speakFemale();
  window.addEventListener('pagehide',function(){leaving=true;if(voiceTimer)clearTimeout(voiceTimer);speech.cancel()});
 }
 var btn=el('button','chatbtn','<span>🤖</span><span class="t">Ask AI</span><i class="dot"></i>');btn.setAttribute('aria-label','Open AI chat');
 var box=el('div','chat');box.setAttribute('role','dialog');box.setAttribute('aria-label','AI assistant');
 box.innerHTML='<div class="ch"><div class="bot">🤖</div><div><b>DMS AI Assistant</b><small>● Online. Ask me anything</small></div><button aria-label="Close chat">×</button></div><div class="cm" aria-live="polite"></div><div class="qr"></div><form class="cf"><input type="text" maxlength="600" placeholder="Type your question..." aria-label="Message"><button type="submit" aria-label="Send">➤</button></form>';
 document.body.appendChild(box);document.body.appendChild(btn);
 var cm=box.querySelector('.cm'),qr=box.querySelector('.qr'),inp=box.querySelector('input'),busy=false;
 ['Our services','Get a free audit','How much does it cost?','Contact details'].forEach(function(q){var b=el('button','',q);b.type='button';b.onclick=function(){send(q)};qr.appendChild(b)});
 function esc(s){return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')}
 function fmt(s){return esc(s).replace(/\*\*(.+?)\*\*/g,'<b>$1</b>').replace(/(https?:\/\/[^\s<]+)/g,'<a href="$1" target="_blank" rel="noopener">$1</a>').replace(/\b([a-z-]+\.html)\b/g,'<a href="$1">$1</a>').replace(/\n/g,'<br>')}
 function add(role,text,save){var b=el('div','b '+role,fmt(text));cm.appendChild(b);cm.scrollTop=cm.scrollHeight;
  if(save){msgs.push({role:role==='me'?'user':'assistant',content:text});try{sessionStorage.setItem(KEY,JSON.stringify(msgs.slice(-30)))}catch(e){}}}
 function faq(t){t=t.toLowerCase();
  var R=[[/(^|\W)(hi|hello|hey|namaste)(\W|$)/,'Hello! 👋 I am the Digimarketingsolutions assistant. Ask me about our services, pricing, or how we can grow your business.'],
  [/seo|google rank|search engine/,'Our **SEO** service covers keyword research, technical fixes, content and link building to rank you higher on Google. Details: service-seo.html'],
  [/social|instagram|facebook|youtube|reel/,'We manage **social media marketing**: content calendars, reels, community replies and influencer outreach. Details: service-social-media.html'],
  [/ads|ppc|google ads|meta ads|campaign/,'Our **paid ads** team runs Google, YouTube, Instagram and Facebook campaigns tuned weekly for the lowest cost per lead. Details: service-paid-ads.html'],
  [/content|blog|video|copy/,'We create blogs, landing pages, videos and case studies in **content marketing**. Details: service-content-marketing.html'],
  [/email|newsletter/,'We build **email and WhatsApp** automation to welcome, nurture and win back customers. Details: service-email-whatsapp.html'],
  [/website|web design|develop|landing/,'We design fast, mobile-friendly **websites** that turn visitors into enquiries. Details: service-web-design.html'],
  [/service|offer|what do you do/,'We offer **SEO, Social Media, Paid Ads, Content Marketing, Email and WhatsApp Marketing and Website Design**. See all: services.html'],
  [/price|cost|charge|fee|package|budget|quote/,'Pricing depends on your goals and the channels you need. Share your requirement on contact.html or WhatsApp +91 6281312546 and we will send a free custom quote.'],
  [/audit|free|consult|strategy|demo/,'You can book a **free audit** on contact.html. We review your site, competitors and ads, then share quick wins.'],
  [/contact|phone|call|mobile|number|mail|whatsapp/,'📞 +91 6281312546\n📧 digimarketingsolutions16@gmail.com\n📍 Near Ameerpet, Hyderabad\nOr use contact.html'],
  [/address|location|where|office|ameerpet|hyderabad/,'We are at **Near Ameerpet, Hyderabad**. Open Mon to Sat, 10am to 7pm.'],
  [/thank|thanks|bye/,'You are welcome! 😊 Reach us anytime on WhatsApp +91 6281312546.']];
  for(var i=0;i<R.length;i++)if(R[i][0].test(t))return R[i][1];
  return 'I can help with our services, pricing and contact details. For a detailed answer, please WhatsApp us on +91 6281312546 or use contact.html.'}
 function send(text){text=(text||'').trim();if(!text||busy)return;busy=true;qr.style.display='none';add('me',text,true);inp.value='';
  var t=el('div','b bot typing','<span></span><span></span><span></span>');cm.appendChild(t);cm.scrollTop=cm.scrollHeight;
  var ctl=new AbortController(),to=setTimeout(function(){ctl.abort()},30000);
  fetch(API,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({messages:msgs.slice(-12)}),signal:ctl.signal})
  .then(function(r){if(!r.ok)throw 0;return r.json()}).then(function(j){if(!j.reply)throw 0;return j.reply})
  .catch(function(){return faq(text)})
  .then(function(a){clearTimeout(to);t.remove();add('bot',a,true);busy=false})}
 box.querySelector('form').onsubmit=function(e){e.preventDefault();send(inp.value)};
 function show(o){open=o;box.classList.toggle('open',o);btn.style.display=o?'none':'flex';greeter.classList.toggle('is-hidden',o);if(o){cm.scrollTop=cm.scrollHeight;setTimeout(function(){inp.focus()},50)}}
 btn.onclick=function(){show(true)};box.querySelector('.ch button').onclick=function(){show(false)};
 if(!msgs.length){add('bot','Hi! 👋 I am the AI assistant of **Digimarketingsolutions**. Ask me anything: marketing, our services, pricing, or any general question.',true)}
 else{msgs.forEach(function(m){add(m.role==='user'?'me':'bot',m.content,false)});qr.style.display='none'}
 show(open);
})();

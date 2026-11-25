(function(){
 var $=function(s){return Array.prototype.slice.call(document.querySelectorAll(s))};
 var bar=document.getElementById('progress'),hd=document.querySelector('header.site'),top=document.getElementById('top');
 function onScroll(){var h=document.documentElement,max=h.scrollHeight-h.clientHeight,y=h.scrollTop||document.body.scrollTop;
  bar.style.width=(max>0?y/max*100:0)+'%';hd.classList.toggle('small',y>20);top.classList.toggle('show',y>500)}
 addEventListener('scroll',onScroll,{passive:true});onScroll();
 top.addEventListener('click',function(){scrollTo({top:0,behavior:'smooth'})});
 // scroll reveal (plays on scroll down and again on scroll up)
 var io=new IntersectionObserver(function(es){es.forEach(function(e){e.target.classList.toggle('in',e.isIntersecting)})},{threshold:.12});
 $('.rv').forEach(function(e,i){e.style.transitionDelay=(i%3)*90+'ms';io.observe(e)});
 // counters
 var co=new IntersectionObserver(function(es){es.forEach(function(e){if(!e.isIntersecting)return;var el=e.target,t=+el.dataset.n,s=0;
  (function st(){s+=Math.ceil(t/45);if(s>t)s=t;el.textContent=s+(el.dataset.s||'');if(s<t)requestAnimationFrame(st)})();co.unobserve(el)})},{threshold:.6});
 $('[data-n]').forEach(function(e){co.observe(e)});
 // cursor effects: soft spotlight inside cards + gentle hero mesh drift (native cursor is kept)
 $('.card').forEach(function(c){c.addEventListener('mousemove',function(e){var q=c.getBoundingClientRect();c.style.setProperty('--mx',(e.clientX-q.left)+'px');c.style.setProperty('--my',(e.clientY-q.top)+'px')})});
 var hero=document.querySelector('.hero');
 if(hero)hero.addEventListener('mousemove',function(e){var q=hero.getBoundingClientRect(),x=(e.clientX-q.left)/q.width-.5,y=(e.clientY-q.top)/q.height-.5;
  $('.mesh').forEach(function(m,i){var k=i?-50:50;m.style.translate=(x*k)+'px '+(y*k)+'px'})});
 // mobile menu
 var b=document.querySelector('.burger'),n=document.querySelector('nav');
 var serviceItem=document.querySelector('.has-sub'),serviceToggle=serviceItem&&serviceItem.querySelector('.services-toggle');
 b.addEventListener('click',function(){
  var o=n.classList.toggle('open');b.setAttribute('aria-expanded',o);
  if(!o&&serviceToggle){serviceItem.classList.remove('open');serviceToggle.setAttribute('aria-expanded','false')}
 });
 if(serviceToggle)serviceToggle.addEventListener('click',function(){
  var o=serviceItem.classList.toggle('open');serviceToggle.setAttribute('aria-expanded',o);
 });
 // contact form: emailed to the business inbox + saved on the server as a backup
 var f=document.getElementById('cf');
 if(f)f.addEventListener('submit',function(e){e.preventDefault();
  var ok=document.getElementById('ok'),bad=document.getElementById('bad'),btn=f.querySelector('button'),d={};
  new FormData(f).forEach(function(v,k){d[k]=v});if(d._honey)return;delete d._honey;
  d._subject='New website enquiry from '+(d.name||'a visitor');d._template='table';d._captcha='false';
  btn.disabled=true;btn.textContent='Sending...';ok.style.display=bad.style.display='none';
  var hdr={'Content-Type':'application/json',Accept:'application/json'};
  var p1=fetch('https://formsubmit.co/ajax/digimarketingsolutions16@gmail.com',{method:'POST',headers:hdr,body:JSON.stringify(d)}).then(function(r){return r.json()}).then(function(j){return String(j.success)==='true'}).catch(function(){return false});
  var p2=fetch('/api/contact',{method:'POST',headers:hdr,body:JSON.stringify(d)}).then(function(r){return r.ok}).catch(function(){return false});
  Promise.all([p1,p2]).then(function(a){if(a[0]||a[1]){f.reset();ok.style.display='block'}else bad.style.display='block';btn.disabled=false;btn.textContent='Send message'});
 });
 // show the welcome offer once per tab, after time on page or meaningful scroll
 var offerKey='dms_offer_seen_v1',offerSeen=false;
 try{offerSeen=sessionStorage.getItem(offerKey)==='1'}catch(e){}
 if(!offerSeen){
  var offer=document.createElement('div'),offerTimer,previousFocus;
  offer.className='offer-overlay';
  offer.innerHTML='<section class="offer-dialog" role="dialog" aria-modal="true" aria-labelledby="offer-title" aria-describedby="offer-description" tabindex="-1">'+
   '<button class="offer-close" type="button" aria-label="Close offer">×</button>'+
   '<div class="offer-visual"><img src="assets/marketing-growth.svg" alt="Digital marketing growth chart"><span class="offer-visual-tag">SMARTER DIGITAL GROWTH</span><div class="offer-metric"><b>More reach.</b><span>Better leads. Real growth.</span></div></div>'+
   '<div class="offer-content"><span class="offer-eyebrow">A little welcome bonus</span><h2 id="offer-title">Let’s grow your business.</h2><p id="offer-description">Get <strong>5% off</strong> your digital marketing service and a free growth consultation with our team.</p>'+
   '<div class="offer-code"><span>Your welcome code</span><strong>GROW5</strong></div>'+
   '<a class="offer-claim" href="contact.html">Claim your 5% discount <span aria-hidden="true">→</span></a>'+
   '<div class="offer-contact"><a class="offer-whatsapp" href="https://wa.me/916281312546?text=Hi%2C%20I%27d%20like%20to%20claim%20the%205%25%20discount%20with%20code%20GROW5" target="_blank" rel="noopener">💬 WhatsApp us</a><a class="offer-call" href="tel:+916281312546">📞 Call us</a></div>'+
   '<small class="offer-note">Mention code GROW5 when you get in touch.</small></div></section>';
  document.body.appendChild(offer);
  var dialog=offer.querySelector('.offer-dialog'),closeButton=offer.querySelector('.offer-close');
  function closeOffer(){
   offer.classList.remove('is-open');document.body.classList.remove('offer-open');
   document.removeEventListener('keydown',offerKeydown);
   if(previousFocus&&typeof previousFocus.focus==='function')previousFocus.focus();
  }
  function offerKeydown(e){
   if(e.key==='Escape'){closeOffer();return}
   if(e.key!=='Tab')return;
   var focusable=dialog.querySelectorAll('a[href],button:not([disabled])'),first=focusable[0],last=focusable[focusable.length-1];
   if(e.shiftKey&&document.activeElement===first){e.preventDefault();last.focus()}
   else if(!e.shiftKey&&document.activeElement===last){e.preventDefault();first.focus()}
  }
  function showOffer(){
   if(offerSeen)return;
   offerSeen=true;
   try{sessionStorage.setItem(offerKey,'1')}catch(e){}
   clearTimeout(offerTimer);previousFocus=document.activeElement;
   document.body.classList.add('offer-open');offer.classList.add('is-open');
   closeButton.focus();document.addEventListener('keydown',offerKeydown);
  }
  closeButton.addEventListener('click',closeOffer);
  offer.addEventListener('click',function(e){if(e.target===offer)closeOffer()});
  offerTimer=setTimeout(showOffer,12000);
  addEventListener('scroll',function(){
   var max=document.documentElement.scrollHeight-window.innerHeight;
   if(max>0&&(window.scrollY||document.documentElement.scrollTop)/max>=.35)showOffer();
  },{passive:true});
 }
})();

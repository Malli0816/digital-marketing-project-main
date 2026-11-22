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
})();

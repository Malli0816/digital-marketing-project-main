(function(){
 var $=function(s){return Array.prototype.slice.call(document.querySelectorAll(s))};
 var bar=document.getElementById('progress'),hd=document.querySelector('header'),top=document.getElementById('top');
 function onScroll(){var h=document.documentElement,max=h.scrollHeight-h.clientHeight,y=h.scrollTop||document.body.scrollTop;
  bar.style.width=(max>0?y/max*100:0)+'%';hd.classList.toggle('small',y>30);top.classList.toggle('show',y>500);
  $('[data-speed]').forEach(function(e){e.style.transform='translateY('+(y*e.dataset.speed)+'px)'})}
 addEventListener('scroll',onScroll,{passive:true});onScroll();
 top.addEventListener('click',function(){scrollTo({top:0,behavior:'smooth'})});
 // scroll reveal: replays when scrolling down and back up
 var io=new IntersectionObserver(function(es){es.forEach(function(e){e.target.classList.toggle('in',e.isIntersecting)})},{threshold:.12});
 $('.rv').forEach(function(e,i){e.style.transitionDelay=(i%4)*90+'ms';io.observe(e)});
 document.documentElement.classList.add('js');
 // counters
 var co=new IntersectionObserver(function(es){es.forEach(function(e){if(!e.isIntersecting)return;var el=e.target,t=+el.dataset.n,s=0;
  (function st(){s+=Math.ceil(t/50);if(s>t)s=t;el.textContent=s+(el.dataset.s||'');if(s<t)requestAnimationFrame(st)})();co.unobserve(el)})},{threshold:.6});
 $('[data-n]').forEach(function(e){co.observe(e)});
 // cursor: dot, ring, glow, parallax, magnetic buttons
 var g=document.getElementById('glow'),d=document.getElementById('cdot'),r=document.getElementById('cring'),rx=0,ry=0,mx=0,my=0;
 if(matchMedia('(hover:hover)').matches){document.body.classList.add('cc');
  addEventListener('mousemove',function(e){mx=e.clientX;my=e.clientY;d.style.left=mx+'px';d.style.top=my+'px';g.style.left=mx+'px';g.style.top=my+'px';
   var x=mx/innerWidth-.5,y=my/innerHeight-.5;$('[data-depth]').forEach(function(el){var k=+el.dataset.depth;el.style.translate=(x*k)+'px '+(y*k)+'px'})});
  (function loop(){rx+=(mx-rx)*.18;ry+=(my-ry)*.18;r.style.left=rx+'px';r.style.top=ry+'px';requestAnimationFrame(loop)})();
  document.addEventListener('mouseover',function(e){r.classList.toggle('big',!!e.target.closest('a,button,input,select,textarea,.card'))});
  $('.btn').forEach(function(b){b.addEventListener('mousemove',function(e){var q=b.getBoundingClientRect();b.style.translate=((e.clientX-q.left-q.width/2)*.2)+'px '+((e.clientY-q.top-q.height/2)*.3)+'px'});b.addEventListener('mouseleave',function(){b.style.translate=''})});
 }
 // 3D tilt
 $('.card').forEach(function(c){
  c.addEventListener('mousemove',function(e){var q=c.getBoundingClientRect(),x=(e.clientX-q.left)/q.width-.5,y=(e.clientY-q.top)/q.height-.5;
   c.style.transform='perspective(700px) rotateY('+x*10+'deg) rotateX('+-y*10+'deg) translateY(-5px)'});
  c.addEventListener('mouseleave',function(){c.style.transform=''})});
 // rotating hero word
 var w=document.getElementById('word');
 if(w){var L=['customers','sales','followers','leads'],i=0;setInterval(function(){i=(i+1)%L.length;w.style.opacity=0;setTimeout(function(){w.textContent=L[i];w.style.opacity=1},250)},2200);w.style.transition='opacity .25s'}
 // mobile menu
 var b=document.querySelector('.burger'),u=document.querySelector('nav ul');
 b.addEventListener('click',function(){var o=u.classList.toggle('open');b.setAttribute('aria-expanded',o)});
 // contact form -> emailed to the business inbox via FormSubmit
 var f=document.getElementById('cf');
 if(f)f.addEventListener('submit',function(e){e.preventDefault();
  var ok=document.getElementById('ok'),bad=document.getElementById('bad'),btn=f.querySelector('button'),data={};
  new FormData(f).forEach(function(v,k){data[k]=v});
  data._subject='New website enquiry from '+(data.name||'a visitor');data._template='table';data._captcha='false';
  btn.disabled=true;btn.textContent='Sending...';ok.style.display=bad.style.display='none';
  fetch('https://formsubmit.co/ajax/digimarketingsolutions16@gmail.com',{method:'POST',headers:{'Content-Type':'application/json',Accept:'application/json'},body:JSON.stringify(data)})
  .then(function(x){return x.json()}).then(function(j){if(String(j.success)!=='true')throw 0;f.reset();ok.style.display='block'})
  .catch(function(){bad.style.display='block'}).then(function(){btn.disabled=false;btn.textContent='Send message 🚀'});
 });
})();

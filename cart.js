(function(){
 var KEY='dms_service_cart_v1';
 var CATALOG={
  'seo':{name:'SEO',price:20000,unit:'month',label:'₹20,000/month'},
  'local-seo':{name:'Local SEO',price:15000,unit:'month',label:'₹15,000/month'},
  'social-media':{name:'Social Media Marketing',price:20000,unit:'month',label:'₹20,000/month'},
  'paid-ads':{name:'Paid Ads Management',price:15000,unit:'month',label:'₹15,000/month; ad spend separate',note:'Advertising spend is separate.'},
  'content-marketing':{name:'Content Marketing Article',price:2500,unit:'article',label:'₹2,500/article'},
  'email-whatsapp':{name:'Email and WhatsApp Marketing',price:10000,unit:'month',label:'₹10,000/month'},
  'web-design':{name:'Website Design and Development',price:35000,unit:'project',label:'₹35,000/project'},
  'video-editing':{name:'Video Editing',price:1000,unit:'video',label:'From ₹1,000/video',note:'Final price depends on video length and editing scope.'},
  'ai-video':{name:'AI Promotional Video',price:2500,unit:'video',label:'From ₹2,500/video',note:'Final price depends on the promotional brief and production scope.'}
 };
 function readCart(){
  var raw,items;
  try{raw=localStorage.getItem(KEY)}catch(e){throw new Error('Browser storage is unavailable. Enable local storage to use the cart.')}
  if(!raw)return [];
  try{items=JSON.parse(raw)}catch(e){throw new Error('The saved cart could not be read. Clear your browser storage and try again.')}
  if(!Array.isArray(items))throw new Error('The saved cart has an invalid format. Clear your browser storage and try again.');
  return items.filter(function(item){return item&&CATALOG[item.id]&&Number.isInteger(item.quantity)&&item.quantity>0&&item.quantity<=99});
 }
 function writeCart(items){
  try{localStorage.setItem(KEY,JSON.stringify(items));return true}
  catch(e){console.error('Could not save cart',e);return false}
 }
 function formatMoney(value){
  try{return new Intl.NumberFormat('en-IN',{style:'currency',currency:'INR',maximumFractionDigits:0}).format(value)}
  catch(e){return '₹'+Number(value).toLocaleString('en-IN')}
 }
 function node(tag,className,text){
  var el=document.createElement(tag);
  if(className)el.className=className;
  if(text!=null)el.textContent=text;
  return el;
 }
 function showError(text){
  var message=document.getElementById('cart-message');
  if(message){message.textContent=text;message.hidden=false}
  else console.error(text);
 }
 function addItem(button){
  var id=button.getAttribute('data-service-id'),product=CATALOG[id];
  if(!product){showError('This service is not available in the cart.');return}
  var items;
  try{items=readCart()}catch(e){showError(e.message);return}
  var found=items.filter(function(item){return item.id===id})[0];
  if(found)found.quantity=Math.min(99,found.quantity+1);
  else items.push({id:id,quantity:1});
  if(!writeCart(items)){showError('The cart could not be saved. Check your browser storage settings and try again.');return}
  window.location.href='cart.html';
 }
 function groupedTotals(items){
  var totals={};
  items.forEach(function(item){
   var product=CATALOG[item.id];
   if(product)totals[product.unit]=(totals[product.unit]||0)+(product.price*item.quantity);
  });
  return totals;
 }
 function renderBreakdown(target,items){
  target.textContent='';
  var heading=node('h3','', 'Estimated cost by billing unit');
  target.appendChild(heading);
  var list=node('ul','');
  var totals=groupedTotals(items),units=Object.keys(totals);
  units.forEach(function(unit){
   var li=node('li','');
   li.appendChild(node('span','',unit.charAt(0).toUpperCase()+unit.slice(1)+' subtotal'));
   li.appendChild(node('strong','',formatMoney(totals[unit])+' / '+unit));
   list.appendChild(li);
  });
  target.appendChild(list);
  target.appendChild(node('p','cart-notice','Estimates only. Monthly, project and per-item amounts are shown separately. Final scope and any applicable GST are confirmed in a written proposal. No online payment is available, and nothing is charged here.'));
 }
 function renderCart(){
  var container=document.getElementById('cart-items'),summary=document.getElementById('cart-summary'),actions=document.getElementById('cart-actions');
  if(!container||!summary)return;
  var items;
  try{items=readCart()}catch(e){showError(e.message);return}
  container.textContent='';summary.textContent='';
  if(!items.length){
   container.appendChild(node('p','', 'Your cart is empty. Browse the services and add the ones you are interested in.'));
   actions.hidden=true;
   return;
  }
  actions.hidden=false;
  items.forEach(function(item){
   var product=CATALOG[item.id],row=node('article','cart-item'),info=node('div',''),controls=node('div','cart-controls');
   info.appendChild(node('h3','',product.name));
   info.appendChild(node('p','',product.label+' × '+item.quantity+' ('+product.unit+(item.quantity===1?'':'s')+')'));
   if(product.note)info.appendChild(node('p','price-note',product.note));
   controls.appendChild(node('button','cart-quantity','−'));
   controls.lastChild.type='button';controls.lastChild.setAttribute('aria-label','Remove one '+product.name);controls.lastChild.setAttribute('data-cart-action','decrease');controls.lastChild.setAttribute('data-service-id',item.id);
   controls.appendChild(node('span','',String(item.quantity)));
   controls.appendChild(node('button','cart-quantity','+'));
   controls.lastChild.type='button';controls.lastChild.setAttribute('aria-label','Add one '+product.name);controls.lastChild.setAttribute('data-cart-action','increase');controls.lastChild.setAttribute('data-service-id',item.id);
   controls.appendChild(node('button','cart-remove','Remove'));
   controls.lastChild.type='button';controls.lastChild.setAttribute('data-cart-action','remove');controls.lastChild.setAttribute('data-service-id',item.id);
   row.appendChild(info);row.appendChild(controls);container.appendChild(row);
  });
  renderBreakdown(summary,items);
 }
 var addButtons=document.querySelectorAll('[data-add-to-cart]');
 addButtons.forEach(function(button){button.addEventListener('click',function(){addItem(button)})});
 var cartItems=document.getElementById('cart-items');
 if(cartItems)cartItems.addEventListener('click',function(event){
  var button=event.target.closest('[data-cart-action]');
  if(!button)return;
  var items;
  try{items=readCart()}catch(e){showError(e.message);return}
  var id=button.getAttribute('data-service-id'),action=button.getAttribute('data-cart-action');
  items=items.reduce(function(result,item){
   if(item.id!==id){result.push(item);return result}
   if(action==='increase')item.quantity=Math.min(99,item.quantity+1);
   else if(action==='decrease')item.quantity-=1;
   if(action!=='remove'&&item.quantity>0)result.push(item);
   return result;
  },[]);
  if(!writeCart(items)){showError('The cart could not be updated. Check your browser storage settings and try again.');return}
  renderCart();
 });
 renderCart();
 var paymentSummary=document.getElementById('payment-summary');
 if(paymentSummary){
  var paymentItems;
  try{paymentItems=readCart()}catch(e){showError(e.message);return}
  if(paymentItems.length)renderBreakdown(paymentSummary,paymentItems);
  else paymentSummary.appendChild(node('p','', 'Your cart is empty. Add a service before reviewing payment details.'));
 }
})();

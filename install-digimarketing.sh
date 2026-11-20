#!/usr/bin/env bash
# One-file installer: creates every website file and deploys it with nginx.
# Usage on the Azure VM:  sudo bash install-digimarketing.sh
set -euo pipefail
BASE="$(pwd)/digimarketing"
mkdir -p "$BASE/site/css" "$BASE/site/js" "$BASE/deploy"
cat > "$BASE/deploy/deploy.sh" <<'DMS_EOF'
#!/usr/bin/env bash
# Run on the Azure Ubuntu/Debian VM:  sudo bash deploy/deploy.sh   (from the folder containing site/ and deploy/)
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
WEB=/var/www/digimarketing
echo "==> Installing nginx"
apt-get update -y && apt-get install -y nginx
echo "==> Copying website to $WEB"
mkdir -p "$WEB"; rm -rf "${WEB:?}"/*
cp -r "$HERE/site/." "$WEB/"
chown -R www-data:www-data "$WEB"
find "$WEB" -type d -exec chmod 755 {} \; ; find "$WEB" -type f -exec chmod 644 {} \;
echo "==> Configuring nginx"
cp "$HERE/deploy/nginx-dms.conf" /etc/nginx/sites-available/digimarketing
ln -sf /etc/nginx/sites-available/digimarketing /etc/nginx/sites-enabled/digimarketing
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/lumio
nginx -t
systemctl enable nginx; systemctl restart nginx
if command -v ufw >/dev/null 2>&1; then ufw allow 'Nginx Full' || true; ufw allow OpenSSH || true; fi
IP=$(curl -s -m 3 -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2021-02-01&format=text" || true)
echo "==> Done. Open http://${IP:-<your-VM-public-IP>}/"
echo "    Allow inbound port 80 in the Azure Network Security Group."
DMS_EOF
cat > "$BASE/deploy/nginx-dms.conf" <<'DMS_EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /var/www/digimarketing;
    index index.html;

    # Redirects: alternate URLs go to the real pages
    rewrite ^/home/?$                /index.html    permanent;
    rewrite ^/(about|about-us)/?$    /about.html    permanent;
    rewrite ^/(service|services)/?$  /services.html permanent;
    rewrite ^/(project|projects|portfolio)/?$ /projects.html permanent;
    rewrite ^/(contact|contact-us)/?$ /contact.html permanent;

    location / { try_files $uri $uri/ =404; }
    location ~* \.(css|js|svg|png|jpg|jpeg|webp|woff2)$ { expires 1h; add_header Cache-Control "public"; }
    types { text/css css; application/javascript js; text/html html; }
    gzip on; gzip_types text/css application/javascript image/svg+xml;
    add_header X-Content-Type-Options nosniff;
    error_page 404 /index.html;
}
DMS_EOF
cat > "$BASE/site/about.html" <<'DMS_EOF'
<!DOCTYPE html>
<html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>About us | Digimarketingsolutions</title><meta name="description" content="About Digimarketingsolutions, a digital marketing team near Ameerpet, Hyderabad.">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E🚀%3C/text%3E%3C/svg%3E">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@600;800&family=DM+Sans:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css"></head><body>
<div id="progress"></div><div id="glow"></div><div id="cdot"></div><div id="cring"></div>
<header><div class="wrap nav"><a class="logo" href="index.html">Digi<i>marketing</i>solutions</a>
<button class="burger" aria-label="Menu" aria-expanded="false">☰</button>
<nav><ul>
<li><a href="index.html" >Home</a></li>
<li><a href="about.html" class="on">About us</a></li>
<li><a href="services.html" >Services</a></li>
<li><a href="projects.html" >Projects</a></li>
<li><a href="contact.html" class="navbtn ">Contact us</a></li>
</ul></nav></div></header>
<main>
<section class="pagehead"><div class="wrap"><span class="tag">About us 👋</span><h1 class="rv">A small team with big campaigns.</h1><p class="rv" style="margin-top:22px;font-size:1.2rem">Digimarketingsolutions began with one belief: marketing should be measurable, honest and a little bit fun. We work from Ameerpet, Hyderabad, and help businesses across India.</p></div></section>
<section><div class="wrap split"><div class="rv l"><h2>Our story 📖</h2><br><p>We started by helping local shops get found on Google. Today we run campaigns for clinics, schools, cafes, startups and online stores, and we still begin every project by listening.</p><br><a class="btn" href="projects.html">See our projects</a></div>
<div class="rv r"><div class="dash" style="box-shadow:12px 12px 0 var(--pink)"><small>🎯 What drives us</small><h3 style="margin:10px 0">Real results, clear reports, friendly people.</h3><div class="bars"><b style="height:40%"></b><b style="height:62%"></b><b style="height:55%"></b><b style="height:90%"></b></div></div></div></div>
<div class="wrap"><div class="grid"><div class="card rv"><span class="ic">🧭</span><h3>Mission</h3><p>Help growing businesses reach the right people at the right cost.</p></div>
<div class="card rv"><span class="ic">🤝</span><h3>Honesty</h3><p>Clear reports, plain language and no lock-in contracts.</p></div>
<div class="card rv"><span class="ic">⚡</span><h3>Speed</h3><p>Test fast, keep what works, drop what does not.</p></div></div></div></section>
<section class="dark"><div class="wrap"><span class="tag">Our process</span><h2 class="rv">How we work</h2><div class="steps">
<div class="rv l"><b>Audit 🔎</b> We study your site, rivals and customers.</div><div class="rv r"><b>Plan 🗺️</b> You get a roadmap with goals and budget.</div>
<div class="rv l"><b>Launch 🚀</b> Campaigns go live on the channels that fit.</div><div class="rv r"><b>Improve 📈</b> Monthly reviews and weekly tuning.</div></div></div></section>
<section class="team"><div class="wrap center"><span class="tag">The team</span><h2 class="rv">The people behind your growth</h2><div class="grid">
<div class="card rv"><div class="av" style="background:var(--pink)">A</div><h3>Aarav Reddy</h3><p>Founder and strategy</p></div>
<div class="card rv"><div class="av" style="background:var(--teal)">S</div><h3>Sneha Rao</h3><p>Head of SEO</p></div>
<div class="card rv"><div class="av" style="background:var(--ink)">K</div><h3>Karthik Varma</h3><p>Paid media lead</p></div>
<div class="card rv"><div class="av" style="background:#e0a800">M</div><h3>Meera Nair</h3><p>Creative director</p></div></div></div></section>
<section style="padding-top:0"><div class="wrap center"><span class="tag">Reviews</span><h2 class="rv">Happy customers 💬</h2><div class="grid" style="text-align:left"><div class="card testi rv"><div class="stars">★★★★★</div><p>Our online orders tripled in three months. They explain everything in simple words and always pick up the phone.</p><div class="who"><div class="av" style="background:var(--pink)">R</div><div><b>Ritika Sharma</b><small>Owner, Style Studio</small></div></div></div>
<div class="card testi rv"><div class="stars">★★★★★</div><p>Our clinic now shows up first on Google. We get new patient calls every single day. Highly recommended!</p><div class="who"><div class="av" style="background:var(--teal)">D</div><div><b>Dr. Venkat Rao</b><small>CarePlus Clinic</small></div></div></div>
<div class="card testi rv"><div class="stars">★★★★★</div><p>The Instagram reels brought a new crowd to our cafe. The team is creative, quick and very professional.</p><div class="who"><div class="av" style="background:var(--blue)">F</div><div><b>Farhan Ali</b><small>Founder, Brew Corner</small></div></div></div></div></div></section>
<div class="wrap"><div class="cta-band rv z"><h2>Ready to grow your business? 🌱</h2><p>Tell us your goal. We reply within one working day with a free plan.</p><div class="row" style="justify-content:center"><a class="btn alt" href="contact.html">Book a free strategy call</a><a class="btn wa" href="https://wa.me/916281312546" target="_blank" rel="noopener">💬 Chat on WhatsApp</a></div></div></div>
</main>
<footer><div class="wrap"><div class="fgrid">
<div><a class="logo" href="index.html" style="color:#fff">Digi<i>marketing</i>solutions</a><p style="margin-top:12px">Digital marketing that turns clicks into customers. 🚀</p>
<div class="socials"><a href="https://instagram.com/digimarketingsolutions.in" target="_blank" rel="noopener">📸 Instagram</a><a href="https://facebook.com/digimarketingsolutions.in" target="_blank" rel="noopener">👍 Facebook</a><a href="https://youtube.com/@digimarketingsolutions.in" target="_blank" rel="noopener">▶️ YouTube</a></div></div>
<div><h4>Pages</h4><ul><li><a href="index.html">Home</a></li><li><a href="about.html">About us</a></li><li><a href="services.html">Services</a></li><li><a href="projects.html">Projects</a></li><li><a href="contact.html">Contact us</a></li></ul></div>
<div><h4>Services</h4><ul><li><a href="services.html#seo">SEO</a></li><li><a href="services.html#social">Social media</a></li><li><a href="services.html#ads">Paid ads</a></li><li><a href="services.html#content">Content</a></li></ul></div>
<div><h4>Contact</h4><ul><li>📧 <a href="mailto:digimarketingsolutions16@gmail.com">digimarketingsolutions16@gmail.com</a></li><li>📞 <a href="tel:+916281312546">+91 6281312546</a></li><li>📍 Near Ameerpet, Hyderabad</li></ul></div>
</div><div class="copy">© <script>document.write(new Date().getFullYear())</script> Digimarketingsolutions. All rights reserved.</div></div></footer>
<a class="waf" href="https://wa.me/916281312546?text=Hi%20Digimarketingsolutions%2C%20I%20want%20to%20know%20more%20about%20your%20services" target="_blank" rel="noopener" aria-label="Chat on WhatsApp">💬</a>
<button id="top" aria-label="Back to top">⬆</button>
<script src="js/main.js"></script></body></html>
DMS_EOF
cat > "$BASE/site/contact.html" <<'DMS_EOF'
<!DOCTYPE html>
<html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Contact us | Digimarketingsolutions</title><meta name="description" content="Contact Digimarketingsolutions for a free marketing audit.">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E🚀%3C/text%3E%3C/svg%3E">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@600;800&family=DM+Sans:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css"></head><body>
<div id="progress"></div><div id="glow"></div><div id="cdot"></div><div id="cring"></div>
<header><div class="wrap nav"><a class="logo" href="index.html">Digi<i>marketing</i>solutions</a>
<button class="burger" aria-label="Menu" aria-expanded="false">☰</button>
<nav><ul>
<li><a href="index.html" >Home</a></li>
<li><a href="about.html" >About us</a></li>
<li><a href="services.html" >Services</a></li>
<li><a href="projects.html" >Projects</a></li>
<li><a href="contact.html" class="navbtn on">Contact us</a></li>
</ul></nav></div></header>
<main>
<section class="pagehead"><div class="wrap"><span class="tag">Contact us 📞</span><h1 class="rv">Let's talk about your growth.</h1></div></section>
<section style="padding-top:30px"><div class="wrap split" style="align-items:start"><div class="rv l"><h2>Send us a message ✉️</h2><br>
<form id="cf"><input name="name" required placeholder="Your name" aria-label="Name"><input name="email" type="email" required placeholder="Email address" aria-label="Email">
<input name="phone" type="tel" placeholder="Phone number" aria-label="Phone">
<select name="service" aria-label="Service"><option>SEO</option><option>Social media</option><option>Paid ads</option><option>Content</option><option>Website design</option><option>Not sure yet</option></select>
<textarea name="message" required placeholder="Tell us about your goals" aria-label="Message"></textarea><button class="btn" type="submit">Send message 🚀</button></form>
<div class="msg good" id="ok">✅ Thank you! We received your message and will reply within one working day.</div>
<div class="msg bad" id="bad">⚠️ Could not send right now. Please WhatsApp us on +91 6281312546 or email digimarketingsolutions16@gmail.com.</div></div>
<div class="rv r"><div class="card"><h3>Visit or call us</h3><ul class="info"><li>📍 <span>Near Ameerpet, Hyderabad</span></li><li>📧 <a href="mailto:digimarketingsolutions16@gmail.com">digimarketingsolutions16@gmail.com</a></li><li>📞 <a href="tel:+916281312546">+91 6281312546</a></li><li>🕘 Mon to Sat, 10am to 7pm</li></ul>
<div class="row" style="margin-top:18px"><a class="btn wa" href="https://wa.me/916281312546" target="_blank" rel="noopener">💬 WhatsApp</a><a class="btn alt" href="tel:+916281312546">📞 Call now</a></div>
<div class="socials" style="color:var(--ink)"><a style="background:var(--paper)" href="https://instagram.com/digimarketingsolutions.in" target="_blank" rel="noopener">📸 Instagram</a><a style="background:var(--paper)" href="https://facebook.com/digimarketingsolutions.in" target="_blank" rel="noopener">👍 Facebook</a><a style="background:var(--paper)" href="https://youtube.com/@digimarketingsolutions.in" target="_blank" rel="noopener">▶️ YouTube</a></div></div>
<div class="map"><iframe title="Map" loading="lazy" src="https://maps.google.com/maps?q=Ameerpet,Hyderabad&output=embed"></iframe></div></div></div></section>
</main>
<footer><div class="wrap"><div class="fgrid">
<div><a class="logo" href="index.html" style="color:#fff">Digi<i>marketing</i>solutions</a><p style="margin-top:12px">Digital marketing that turns clicks into customers. 🚀</p>
<div class="socials"><a href="https://instagram.com/digimarketingsolutions.in" target="_blank" rel="noopener">📸 Instagram</a><a href="https://facebook.com/digimarketingsolutions.in" target="_blank" rel="noopener">👍 Facebook</a><a href="https://youtube.com/@digimarketingsolutions.in" target="_blank" rel="noopener">▶️ YouTube</a></div></div>
<div><h4>Pages</h4><ul><li><a href="index.html">Home</a></li><li><a href="about.html">About us</a></li><li><a href="services.html">Services</a></li><li><a href="projects.html">Projects</a></li><li><a href="contact.html">Contact us</a></li></ul></div>
<div><h4>Services</h4><ul><li><a href="services.html#seo">SEO</a></li><li><a href="services.html#social">Social media</a></li><li><a href="services.html#ads">Paid ads</a></li><li><a href="services.html#content">Content</a></li></ul></div>
<div><h4>Contact</h4><ul><li>📧 <a href="mailto:digimarketingsolutions16@gmail.com">digimarketingsolutions16@gmail.com</a></li><li>📞 <a href="tel:+916281312546">+91 6281312546</a></li><li>📍 Near Ameerpet, Hyderabad</li></ul></div>
</div><div class="copy">© <script>document.write(new Date().getFullYear())</script> Digimarketingsolutions. All rights reserved.</div></div></footer>
<a class="waf" href="https://wa.me/916281312546?text=Hi%20Digimarketingsolutions%2C%20I%20want%20to%20know%20more%20about%20your%20services" target="_blank" rel="noopener" aria-label="Chat on WhatsApp">💬</a>
<button id="top" aria-label="Back to top">⬆</button>
<script src="js/main.js"></script></body></html>
DMS_EOF
cat > "$BASE/site/css/style.css" <<'DMS_EOF'
:root{--ink:#1b1a47;--paper:#f4f1ff;--pink:#ff3d8b;--sun:#ffd23f;--teal:#1fd1b5;--blue:#5b6cff;--r:22px}
*{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth}
body{font-family:'DM Sans',system-ui,-apple-system,'Segoe UI',Arial,sans-serif;font-size:17px;line-height:1.65;color:var(--ink);background:var(--paper);overflow-x:hidden}
h1,h2,h3,h4{font-family:'Bricolage Grotesque','DM Sans',Arial,sans-serif;line-height:1.1;letter-spacing:-.02em}
h1{font-size:clamp(2.4rem,6vw,4.8rem)}h2{font-size:clamp(1.9rem,4vw,3.1rem)}h3{font-size:1.35rem}
a{color:inherit;text-decoration:none}img,svg{max-width:100%}ul{list-style:none}
.wrap{max-width:1180px;margin:0 auto;padding:0 24px}
section{padding:90px 0;position:relative}
p{max-width:64ch}
.center{text-align:center}.center p{margin-left:auto;margin-right:auto}
.tag{display:inline-block;background:var(--ink);color:var(--sun);padding:6px 16px;border-radius:99px;font-weight:700;font-size:.85rem;margin-bottom:14px}
:focus-visible{outline:3px solid var(--pink);outline-offset:3px}
#progress{position:fixed;top:0;left:0;height:4px;width:0;background:linear-gradient(90deg,var(--pink),var(--sun),var(--teal));z-index:300}
#glow{position:fixed;left:-500px;top:-500px;width:360px;height:360px;border-radius:50%;pointer-events:none;z-index:0;transform:translate(-50%,-50%);background:radial-gradient(circle,rgba(255,61,139,.2),transparent 65%)}
#cdot,#cring{position:fixed;left:-100px;top:-100px;pointer-events:none;z-index:400;border-radius:50%;transform:translate(-50%,-50%)}
#cdot{width:8px;height:8px;background:var(--pink)}
#cring{width:38px;height:38px;border:2px solid var(--ink);transition:width .2s,height .2s,background .2s,border-color .2s}
#cring.big{width:70px;height:70px;background:rgba(255,210,63,.35);border-color:var(--pink)}
@media(hover:none){#glow,#cdot,#cring{display:none}}
header{position:sticky;top:0;z-index:200;padding:18px 0;transition:.3s}
header.small{background:rgba(244,241,255,.92);backdrop-filter:blur(12px);padding:9px 0;box-shadow:0 6px 30px rgba(27,26,71,.1)}
.nav{display:flex;align-items:center;justify-content:space-between;gap:16px}
.logo{font-family:'Bricolage Grotesque',Arial,sans-serif;font-weight:800;font-size:1.45rem}.logo i{color:var(--pink);font-style:normal}
nav ul{display:flex;gap:4px;align-items:center}
nav a{display:block;padding:8px 15px;border-radius:99px;font-weight:500;transition:.25s}
nav a:hover,nav a.on{background:var(--ink);color:#fff}
nav a.navbtn{background:var(--pink);color:#fff;font-weight:700}
.burger{display:none;background:none;border:0;font-size:1.9rem;cursor:pointer;color:var(--ink)}
.btn{display:inline-block;padding:14px 28px;border-radius:99px;background:var(--pink);color:#fff;font-weight:700;border:0;cursor:pointer;font-size:1rem;font-family:inherit;transition:transform .2s,box-shadow .2s;box-shadow:0 7px 0 #b81c5c}
.btn:hover{transform:translateY(4px);box-shadow:0 3px 0 #b81c5c}
.btn.alt{background:var(--sun);color:var(--ink);box-shadow:0 7px 0 #c79a00}.btn.alt:hover{box-shadow:0 3px 0 #c79a00}
.btn.wa{background:#25d366;box-shadow:0 7px 0 #168a43}.btn.wa:hover{box-shadow:0 3px 0 #168a43}
.row{display:flex;gap:18px;flex-wrap:wrap}
.hero{padding:50px 0 100px;overflow:hidden}
.herogrid{display:grid;grid-template-columns:1.1fr .9fr;gap:40px;align-items:center;position:relative;z-index:1}
.hero p.lead{font-size:1.2rem;margin:22px 0 32px}
.hl{display:inline-block;background:var(--sun);padding:0 .15em;transform:rotate(-1.5deg)}
#word{color:var(--pink)}
.orb{position:absolute;border-radius:50%;z-index:0}
.o1{width:340px;height:340px;background:var(--teal);right:-80px;top:20px;opacity:.55}
.o2{width:160px;height:160px;background:var(--pink);left:-50px;bottom:30px;opacity:.5}
.o3{width:90px;height:90px;background:var(--sun);left:46%;top:60px}
.visual{position:relative;min-height:400px}
.dash{background:#fff;border:3px solid var(--ink);border-radius:26px;padding:26px;box-shadow:12px 12px 0 var(--ink);position:relative;z-index:1}
.dash .bars{display:flex;align-items:flex-end;gap:12px;height:170px;margin:14px 0}
.dash .bars b{flex:1;border-radius:10px 10px 0 0;background:linear-gradient(var(--pink),var(--sun));animation:grow 1.6s ease-out backwards;transform-origin:bottom}
.dash .bars b:nth-child(even){background:linear-gradient(var(--blue),var(--teal))}
@keyframes grow{from{transform:scaleY(0)}}
.dash small{font-weight:700;opacity:.7}
.chip{position:absolute;z-index:3;background:#fff;border:2px solid var(--ink);border-radius:16px;padding:10px 16px;font-weight:700;box-shadow:5px 5px 0 var(--ink);animation:bob 4s ease-in-out infinite}
.chip b{color:var(--pink);font-size:1.35rem;display:block;line-height:1.1}
.c1{left:-26px;top:20px}.c2{right:-14px;top:150px;animation-delay:-1.3s}.c3{left:20px;bottom:-26px;animation-delay:-2.3s}
@keyframes bob{50%{transform:translateY(-12px)}}
.marquee{background:var(--ink);color:var(--paper);overflow:hidden;white-space:nowrap;padding:16px 0;font-family:'Bricolage Grotesque',Arial,sans-serif;font-weight:700;font-size:1.3rem}
.marquee div{display:inline-block;animation:slide 30s linear infinite}
.marquee span{margin:0 24px;color:var(--sun)}
@keyframes slide{to{transform:translateX(-50%)}}
.grid{display:grid;gap:26px;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));margin-top:46px}
.card{display:block;background:#fff;border-radius:var(--r);padding:32px;border:2px solid var(--ink);transition:transform .15s,box-shadow .3s}
.card:hover{box-shadow:9px 9px 0 var(--ink)}
.card .ic{font-size:2.4rem;display:block;margin-bottom:12px}
.card p{margin-top:8px;font-size:.98rem}
.more{display:inline-block;margin-top:14px;font-weight:700;color:var(--pink)}
.dark{background:var(--ink);color:var(--paper)}.dark .tag{background:var(--sun);color:var(--ink)}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:28px;text-align:center}
.stats strong{display:block;font-family:'Bricolage Grotesque',Arial,sans-serif;font-weight:800;font-size:clamp(2.4rem,5.5vw,4rem);color:var(--sun)}
.split{display:grid;grid-template-columns:1fr 1fr;gap:50px;align-items:center}
.pagehead{padding:60px 0 20px}
.steps{display:grid;gap:18px;margin-top:36px;counter-reset:s}
.steps div{counter-increment:s;background:#fff;color:var(--ink);border-left:8px solid var(--pink);border-radius:14px;padding:20px 24px 20px 78px;position:relative}
.steps div:before{content:counter(s);position:absolute;left:24px;top:10px;font-family:'Bricolage Grotesque',Arial,sans-serif;font-weight:800;font-size:2.3rem;color:var(--teal)}
.av{width:84px;height:84px;border-radius:50%;margin:0 auto 12px;display:grid;place-items:center;font-family:'Bricolage Grotesque',Arial,sans-serif;font-weight:800;font-size:1.9rem;color:#fff}
.team .card{text-align:center}
.thumb{height:190px;border-radius:16px;margin:-12px -12px 18px;display:grid;place-items:center;font-size:4.2rem;position:relative;overflow:hidden;border:2px solid var(--ink)}
.thumb:after{content:"";position:absolute;inset:auto -20% -40% -20%;height:70%;background:rgba(255,255,255,.28);border-radius:50%}
.g1{background:linear-gradient(135deg,#ff3d8b,#ffd23f)}.g2{background:linear-gradient(135deg,#5b6cff,#1fd1b5)}.g3{background:linear-gradient(135deg,#1b1a47,#ff3d8b)}
.g4{background:linear-gradient(135deg,#1fd1b5,#ffd23f)}.g5{background:linear-gradient(135deg,#ffd23f,#5b6cff)}.g6{background:linear-gradient(135deg,#ff3d8b,#5b6cff)}
.thumb .res{position:absolute;left:12px;bottom:12px;z-index:1;background:#fff;border:2px solid var(--ink);border-radius:10px;padding:2px 10px;font-size:.85rem;font-weight:700}
.pill{display:inline-block;background:var(--paper);border:1px solid var(--ink);border-radius:99px;padding:1px 12px;font-size:.8rem;font-weight:700;margin-bottom:8px}
.testi{position:relative}.testi:before{content:"“";position:absolute;right:22px;top:-6px;font-size:6rem;color:var(--pink);font-family:Georgia,serif}
.stars{color:#f5a300;letter-spacing:2px;margin-bottom:8px}
.who{display:flex;gap:12px;align-items:center;margin-top:18px}.who .av{width:48px;height:48px;font-size:1.1rem;margin:0}
.who small{display:block;opacity:.7}
form{display:grid;gap:14px}
input,textarea,select{font:inherit;padding:13px 17px;border-radius:14px;border:2px solid var(--ink);background:#fff;width:100%;color:var(--ink)}
textarea{min-height:130px;resize:vertical}
.msg{display:none;padding:16px 20px;border-radius:14px;font-weight:700;margin-top:14px}
.msg.good{background:var(--teal)}.msg.bad{background:var(--sun)}
.info li{margin:10px 0;display:flex;gap:12px}
.map{border:2px solid var(--ink);border-radius:var(--r);overflow:hidden;margin-top:26px;height:280px}.map iframe{width:100%;height:100%;border:0}
.socials{display:flex;gap:10px;margin-top:16px;flex-wrap:wrap}
.socials a{display:inline-block;padding:8px 16px;border-radius:99px;background:rgba(255,255,255,.12);font-weight:700;transition:.25s}
.socials a:hover{background:var(--sun);color:var(--ink);transform:translateY(-3px)}
.cta-band{text-align:center;background:var(--pink);color:#fff;border-radius:34px;padding:64px 26px;max-width:1132px;margin:0 auto}
.cta-band p{margin:14px auto 26px}
footer{background:var(--ink);color:#cfcaf5;padding:64px 0 28px;margin-top:90px}
.fgrid{display:grid;grid-template-columns:1.8fr 1fr 1fr 1.5fr;gap:36px}
footer h4{color:#fff;margin-bottom:12px}footer li{margin:7px 0}footer a:hover{color:var(--sun)}
.copy{border-top:1px solid rgba(255,255,255,.15);margin-top:40px;padding-top:20px;font-size:.9rem}
.waf{position:fixed;right:22px;bottom:22px;z-index:250;width:62px;height:62px;border-radius:50%;background:#25d366;display:grid;place-items:center;font-size:1.9rem;box-shadow:0 8px 24px rgba(0,0,0,.3);animation:pulse 2s infinite}
@keyframes pulse{0%{box-shadow:0 0 0 0 rgba(37,211,102,.6)}100%{box-shadow:0 0 0 22px rgba(37,211,102,0)}}
#top{position:fixed;right:30px;bottom:98px;z-index:250;width:46px;height:46px;border-radius:50%;border:2px solid var(--ink);background:var(--sun);cursor:pointer;font-size:1.2rem;opacity:0;pointer-events:none;transition:.3s}
#top.show{opacity:1;pointer-events:auto}
.rv{opacity:0;transform:translateY(40px);transition:opacity .8s,transform .8s cubic-bezier(.2,.8,.2,1)}
.rv.l{transform:translateX(-60px)}.rv.r{transform:translateX(60px)}.rv.z{transform:scale(.88)}
.rv.in{opacity:1;transform:none}
.hero h1 .w{display:inline-block;animation:drop .9s cubic-bezier(.2,.9,.3,1.3) backwards}
@keyframes drop{from{opacity:0;transform:translateY(60px) rotate(6deg)}}
@media(max-width:900px){
.burger{display:block}
nav ul{position:absolute;top:100%;left:0;right:0;background:var(--paper);flex-direction:column;align-items:stretch;padding:14px 24px;display:none;box-shadow:0 20px 30px rgba(0,0,0,.12)}
nav ul.open{display:flex}
.herogrid,.split,.fgrid{grid-template-columns:1fr}.visual{margin-top:30px}.c1{left:0}.c2{right:0}
section{padding:60px 0}.card:hover{box-shadow:none}}
@media(prefers-reduced-motion:reduce){*{animation:none!important;transition:none!important}.rv{opacity:1;transform:none}}
@media(hover:hover){body.cc,body.cc a,body.cc button{cursor:none}}
DMS_EOF
cat > "$BASE/site/index.html" <<'DMS_EOF'
<!DOCTYPE html>
<html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Digital marketing agency in Hyderabad | Digimarketingsolutions</title><meta name="description" content="Digimarketingsolutions: SEO, social media, paid ads and content marketing in Hyderabad.">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E🚀%3C/text%3E%3C/svg%3E">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@600;800&family=DM+Sans:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css"></head><body>
<div id="progress"></div><div id="glow"></div><div id="cdot"></div><div id="cring"></div>
<header><div class="wrap nav"><a class="logo" href="index.html">Digi<i>marketing</i>solutions</a>
<button class="burger" aria-label="Menu" aria-expanded="false">☰</button>
<nav><ul>
<li><a href="index.html" class="on">Home</a></li>
<li><a href="about.html" >About us</a></li>
<li><a href="services.html" >Services</a></li>
<li><a href="projects.html" >Projects</a></li>
<li><a href="contact.html" class="navbtn ">Contact us</a></li>
</ul></nav></div></header>
<main>
<section class="hero"><div class="orb o1" data-speed=".15"></div><div class="orb o2" data-speed=".3"></div><div class="orb o3" data-depth="-60"></div>
<div class="wrap herogrid"><div><span class="tag">📍 Digital marketing agency, Hyderabad</span>
<h1><span class="w">Get</span> <span class="w">more</span> <span class="w hl">online</span><br><span class="w" id="word">customers</span></h1>
<p class="lead">We plan, launch and track campaigns on Google, Instagram and Facebook, so every rupee you spend brings back more. 📈</p>
<div class="row"><a class="btn" href="contact.html">Get a free audit 🎁</a><a class="btn alt" href="services.html">Our services</a></div></div>
<div class="visual"><div class="chip c1" data-depth="40">🔍 SEO traffic<b>+212%</b></div><div class="chip c2" data-depth="-50">📱 New leads<b>1,480</b></div><div class="chip c3" data-depth="55">💰 Ad return<b>5.4x</b></div>
<div class="dash" data-depth="-14"><small>📊 Monthly growth report</small><div class="bars"><b style="height:35%"></b><b style="height:50%"></b><b style="height:42%"></b><b style="height:68%"></b><b style="height:60%"></b><b style="height:85%"></b><b style="height:100%"></b></div><small>Jan &rarr; Jul &nbsp;🚀 Growing every month</small></div></div></div></section>
<div class="marquee"><div><span>✦</span>SEO 🔍<span>✦</span>Social media 📱<span>✦</span>Google ads 🎯<span>✦</span>Content ✍️<span>✦</span>Email 📧<span>✦</span>Analytics 📊
<span>✦</span>SEO 🔍<span>✦</span>Social media 📱<span>✦</span>Google ads 🎯<span>✦</span>Content ✍️<span>✦</span>Email 📧<span>✦</span>Analytics 📊
<span>✦</span>SEO 🔍<span>✦</span>Social media 📱<span>✦</span>Google ads 🎯<span>✦</span>Content ✍️<span>✦</span>Email 📧<span>✦</span>Analytics 📊
<span>✦</span>SEO 🔍<span>✦</span>Social media 📱<span>✦</span>Google ads 🎯<span>✦</span>Content ✍️<span>✦</span>Email 📧<span>✦</span>Analytics 📊</div></div>
<section><div class="wrap center"><span class="tag">What we do</span><h2 class="rv">Services built to grow your business</h2>
<div class="grid" style="text-align:left">
<a class="card rv" href="services.html#seo"><span class="ic">🔍</span><h3>SEO</h3><p>Rank higher on Google and bring in visitors ready to buy.</p><span class="more">Learn more &rarr;</span></a>
<a class="card rv" href="services.html#social"><span class="ic">📱</span><h3>Social media</h3><p>Posts, reels and community care that grow a loyal audience.</p><span class="more">Learn more &rarr;</span></a>
<a class="card rv" href="services.html#ads"><span class="ic">🎯</span><h3>Paid ads</h3><p>Google and Meta campaigns tuned weekly for the lowest cost per lead.</p><span class="more">Learn more &rarr;</span></a>
<a class="card rv" href="services.html#content"><span class="ic">✍️</span><h3>Content</h3><p>Blogs, videos and emails that explain your value and earn trust.</p><span class="more">Learn more &rarr;</span></a></div></div></section>
<section class="dark"><div class="wrap stats">
<div class="rv z"><strong data-n="250" data-s="+">0</strong>Brands grown 🏆</div><div class="rv z"><strong data-n="12" data-s="M+">0</strong>Monthly reach 👀</div>
<div class="rv z"><strong data-n="98" data-s="%">0</strong>Clients who stay 💜</div><div class="rv z"><strong data-n="7" data-s=" yrs">0</strong>In business 🎂</div></div></section>
<section><div class="wrap center"><span class="tag">Our work</span><h2 class="rv">Projects we are proud of</h2>
<div class="grid" style="text-align:left"><a class="card rv" href="contact.html"><div class="thumb g1">🛍️<span class="res">+320% sales</span></div><span class="pill">E-commerce</span><h3>Fashion store growth</h3><p>Meta and Google Shopping ads took a Hyderabad boutique from local to nationwide orders.</p></a>
<a class="card rv" href="contact.html"><div class="thumb g2">🏥<span class="res">+4x enquiries</span></div><span class="pill">Healthcare</span><h3>Clinic local SEO</h3><p>Google Business and SEO put a multi-speciality clinic on page one for "near me" searches.</p></a>
<a class="card rv" href="contact.html"><div class="thumb g3">🎓<span class="res">1,200 leads</span></div><span class="pill">Education</span><h3>Coaching institute leads</h3><p>Lead-form ads and WhatsApp follow-ups filled every batch before the term started.</p></a></div><br><a class="btn rv" href="projects.html">View all projects &rarr;</a></div></section>
<section style="padding-top:0"><div class="wrap center"><span class="tag">Reviews</span><h2 class="rv">What our customers say 💬</h2><div class="grid" style="text-align:left"><div class="card testi rv"><div class="stars">★★★★★</div><p>Our online orders tripled in three months. They explain everything in simple words and always pick up the phone.</p><div class="who"><div class="av" style="background:var(--pink)">R</div><div><b>Ritika Sharma</b><small>Owner, Style Studio</small></div></div></div>
<div class="card testi rv"><div class="stars">★★★★★</div><p>Our clinic now shows up first on Google. We get new patient calls every single day. Highly recommended!</p><div class="who"><div class="av" style="background:var(--teal)">D</div><div><b>Dr. Venkat Rao</b><small>CarePlus Clinic</small></div></div></div>
<div class="card testi rv"><div class="stars">★★★★★</div><p>The Instagram reels brought a new crowd to our cafe. The team is creative, quick and very professional.</p><div class="who"><div class="av" style="background:var(--blue)">F</div><div><b>Farhan Ali</b><small>Founder, Brew Corner</small></div></div></div></div></div></section>
<div class="wrap"><div class="cta-band rv z"><h2>Ready to grow your business? 🌱</h2><p>Tell us your goal. We reply within one working day with a free plan.</p><div class="row" style="justify-content:center"><a class="btn alt" href="contact.html">Book a free strategy call</a><a class="btn wa" href="https://wa.me/916281312546" target="_blank" rel="noopener">💬 Chat on WhatsApp</a></div></div></div>
</main>
<footer><div class="wrap"><div class="fgrid">
<div><a class="logo" href="index.html" style="color:#fff">Digi<i>marketing</i>solutions</a><p style="margin-top:12px">Digital marketing that turns clicks into customers. 🚀</p>
<div class="socials"><a href="https://instagram.com/digimarketingsolutions.in" target="_blank" rel="noopener">📸 Instagram</a><a href="https://facebook.com/digimarketingsolutions.in" target="_blank" rel="noopener">👍 Facebook</a><a href="https://youtube.com/@digimarketingsolutions.in" target="_blank" rel="noopener">▶️ YouTube</a></div></div>
<div><h4>Pages</h4><ul><li><a href="index.html">Home</a></li><li><a href="about.html">About us</a></li><li><a href="services.html">Services</a></li><li><a href="projects.html">Projects</a></li><li><a href="contact.html">Contact us</a></li></ul></div>
<div><h4>Services</h4><ul><li><a href="services.html#seo">SEO</a></li><li><a href="services.html#social">Social media</a></li><li><a href="services.html#ads">Paid ads</a></li><li><a href="services.html#content">Content</a></li></ul></div>
<div><h4>Contact</h4><ul><li>📧 <a href="mailto:digimarketingsolutions16@gmail.com">digimarketingsolutions16@gmail.com</a></li><li>📞 <a href="tel:+916281312546">+91 6281312546</a></li><li>📍 Near Ameerpet, Hyderabad</li></ul></div>
</div><div class="copy">© <script>document.write(new Date().getFullYear())</script> Digimarketingsolutions. All rights reserved.</div></div></footer>
<a class="waf" href="https://wa.me/916281312546?text=Hi%20Digimarketingsolutions%2C%20I%20want%20to%20know%20more%20about%20your%20services" target="_blank" rel="noopener" aria-label="Chat on WhatsApp">💬</a>
<button id="top" aria-label="Back to top">⬆</button>
<script src="js/main.js"></script></body></html>
DMS_EOF
cat > "$BASE/site/js/main.js" <<'DMS_EOF'
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
DMS_EOF
cat > "$BASE/site/projects.html" <<'DMS_EOF'
<!DOCTYPE html>
<html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Projects | Digimarketingsolutions</title><meta name="description" content="Case studies and recent digital marketing projects by Digimarketingsolutions.">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E🚀%3C/text%3E%3C/svg%3E">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@600;800&family=DM+Sans:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css"></head><body>
<div id="progress"></div><div id="glow"></div><div id="cdot"></div><div id="cring"></div>
<header><div class="wrap nav"><a class="logo" href="index.html">Digi<i>marketing</i>solutions</a>
<button class="burger" aria-label="Menu" aria-expanded="false">☰</button>
<nav><ul>
<li><a href="index.html" >Home</a></li>
<li><a href="about.html" >About us</a></li>
<li><a href="services.html" >Services</a></li>
<li><a href="projects.html" class="on">Projects</a></li>
<li><a href="contact.html" class="navbtn ">Contact us</a></li>
</ul></nav></div></header>
<main>
<section class="pagehead"><div class="wrap"><span class="tag">Our work 🏆</span><h1 class="rv">Projects and results.</h1><p class="rv" style="margin-top:22px;font-size:1.2rem">A few campaigns we have run. Each started with a goal and ended with numbers.</p></div></section>
<section style="padding-top:30px"><div class="wrap"><div class="grid"><a class="card rv" href="contact.html"><div class="thumb g1">🛍️<span class="res">+320% sales</span></div><span class="pill">E-commerce</span><h3>Fashion store growth</h3><p>Meta and Google Shopping ads took a Hyderabad boutique from local to nationwide orders.</p></a>
<a class="card rv" href="contact.html"><div class="thumb g2">🏥<span class="res">+4x enquiries</span></div><span class="pill">Healthcare</span><h3>Clinic local SEO</h3><p>Google Business and SEO put a multi-speciality clinic on page one for "near me" searches.</p></a>
<a class="card rv" href="contact.html"><div class="thumb g3">🎓<span class="res">1,200 leads</span></div><span class="pill">Education</span><h3>Coaching institute leads</h3><p>Lead-form ads and WhatsApp follow-ups filled every batch before the term started.</p></a>
<a class="card rv" href="contact.html"><div class="thumb g4">🍽️<span class="res">+180% footfall</span></div><span class="pill">Restaurant</span><h3>Cafe social buzz</h3><p>Reels and influencer collabs made a small cafe the talk of Ameerpet.</p></a>
<a class="card rv" href="contact.html"><div class="thumb g5">🏠<span class="res">320 site visits</span></div><span class="pill">Real estate</span><h3>Property campaign</h3><p>Targeted video ads brought serious buyers to a new apartment launch.</p></a>
<a class="card rv" href="contact.html"><div class="thumb g6">💻<span class="res">5.4x ROAS</span></div><span class="pill">SaaS startup</span><h3>Software demo bookings</h3><p>Search ads and email flows cut cost per demo by more than half.</p></a></div></div></section>
<section class="dark"><div class="wrap center"><span class="tag">Reviews</span><h2 class="rv">What clients say 💬</h2><div class="grid" style="text-align:left;color:var(--ink)"><div class="card testi rv"><div class="stars">★★★★★</div><p>Our online orders tripled in three months. They explain everything in simple words and always pick up the phone.</p><div class="who"><div class="av" style="background:var(--pink)">R</div><div><b>Ritika Sharma</b><small>Owner, Style Studio</small></div></div></div>
<div class="card testi rv"><div class="stars">★★★★★</div><p>Our clinic now shows up first on Google. We get new patient calls every single day. Highly recommended!</p><div class="who"><div class="av" style="background:var(--teal)">D</div><div><b>Dr. Venkat Rao</b><small>CarePlus Clinic</small></div></div></div>
<div class="card testi rv"><div class="stars">★★★★★</div><p>The Instagram reels brought a new crowd to our cafe. The team is creative, quick and very professional.</p><div class="who"><div class="av" style="background:var(--blue)">F</div><div><b>Farhan Ali</b><small>Founder, Brew Corner</small></div></div></div></div></div></section>
<div class="wrap"><div class="cta-band rv z"><h2>Ready to grow your business? 🌱</h2><p>Tell us your goal. We reply within one working day with a free plan.</p><div class="row" style="justify-content:center"><a class="btn alt" href="contact.html">Book a free strategy call</a><a class="btn wa" href="https://wa.me/916281312546" target="_blank" rel="noopener">💬 Chat on WhatsApp</a></div></div></div>
</main>
<footer><div class="wrap"><div class="fgrid">
<div><a class="logo" href="index.html" style="color:#fff">Digi<i>marketing</i>solutions</a><p style="margin-top:12px">Digital marketing that turns clicks into customers. 🚀</p>
<div class="socials"><a href="https://instagram.com/digimarketingsolutions.in" target="_blank" rel="noopener">📸 Instagram</a><a href="https://facebook.com/digimarketingsolutions.in" target="_blank" rel="noopener">👍 Facebook</a><a href="https://youtube.com/@digimarketingsolutions.in" target="_blank" rel="noopener">▶️ YouTube</a></div></div>
<div><h4>Pages</h4><ul><li><a href="index.html">Home</a></li><li><a href="about.html">About us</a></li><li><a href="services.html">Services</a></li><li><a href="projects.html">Projects</a></li><li><a href="contact.html">Contact us</a></li></ul></div>
<div><h4>Services</h4><ul><li><a href="services.html#seo">SEO</a></li><li><a href="services.html#social">Social media</a></li><li><a href="services.html#ads">Paid ads</a></li><li><a href="services.html#content">Content</a></li></ul></div>
<div><h4>Contact</h4><ul><li>📧 <a href="mailto:digimarketingsolutions16@gmail.com">digimarketingsolutions16@gmail.com</a></li><li>📞 <a href="tel:+916281312546">+91 6281312546</a></li><li>📍 Near Ameerpet, Hyderabad</li></ul></div>
</div><div class="copy">© <script>document.write(new Date().getFullYear())</script> Digimarketingsolutions. All rights reserved.</div></div></footer>
<a class="waf" href="https://wa.me/916281312546?text=Hi%20Digimarketingsolutions%2C%20I%20want%20to%20know%20more%20about%20your%20services" target="_blank" rel="noopener" aria-label="Chat on WhatsApp">💬</a>
<button id="top" aria-label="Back to top">⬆</button>
<script src="js/main.js"></script></body></html>
DMS_EOF
cat > "$BASE/site/services.html" <<'DMS_EOF'
<!DOCTYPE html>
<html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Services | Digimarketingsolutions</title><meta name="description" content="SEO, social media, paid ads, content and email marketing services.">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E🚀%3C/text%3E%3C/svg%3E">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@600;800&family=DM+Sans:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/style.css"></head><body>
<div id="progress"></div><div id="glow"></div><div id="cdot"></div><div id="cring"></div>
<header><div class="wrap nav"><a class="logo" href="index.html">Digi<i>marketing</i>solutions</a>
<button class="burger" aria-label="Menu" aria-expanded="false">☰</button>
<nav><ul>
<li><a href="index.html" >Home</a></li>
<li><a href="about.html" >About us</a></li>
<li><a href="services.html" class="on">Services</a></li>
<li><a href="projects.html" >Projects</a></li>
<li><a href="contact.html" class="navbtn ">Contact us</a></li>
</ul></nav></div></header>
<main>
<section class="pagehead"><div class="wrap"><span class="tag">Services 🛠️</span><h1 class="rv">Everything you need to grow online.</h1><p class="rv" style="margin-top:22px;font-size:1.2rem">Pick one service or combine them. Each comes with a monthly report you can understand.</p></div></section>
<section style="padding-top:30px"><div class="wrap"><div class="grid">
<div class="card rv" id="seo"><span class="ic">🔍</span><h3>SEO</h3><p>Keyword research, on-page fixes, link building and Google Business setup so customers find you first.</p></div>
<div class="card rv" id="social"><span class="ic">📱</span><h3>Social media</h3><p>Content calendars, reels, community replies and influencer outreach on Instagram, Facebook and YouTube.</p></div>
<div class="card rv" id="ads"><span class="ic">🎯</span><h3>Paid ads</h3><p>Google, YouTube, Instagram and Facebook campaigns with weekly optimisation.</p></div>
<div class="card rv" id="content"><span class="ic">✍️</span><h3>Content</h3><p>Blogs, landing pages, video scripts and case studies written for your buyers.</p></div>
<div class="card rv"><span class="ic">📧</span><h3>Email and WhatsApp</h3><p>Automated flows that welcome, nurture and win back customers.</p></div>
<div class="card rv"><span class="ic">🌐</span><h3>Website design</h3><p>Fast, mobile-friendly websites built to turn visitors into enquiries.</p></div></div></div></section>
<section class="dark"><div class="wrap"><span class="tag">Simple steps</span><h2 class="rv">From first call to first results</h2><div class="steps">
<div class="rv l"><b>Free audit 🎁</b> We find your quickest wins.</div><div class="rv r"><b>Custom plan 📝</b> Scope, timeline and price in writing.</div><div class="rv l"><b>Results in 90 days 📈</b> Most clients see steady growth within three months.</div></div></div></section>
<section><div class="wrap center"><h2 class="rv">See it in action</h2><br><a class="btn rv" href="projects.html">Browse our projects &rarr;</a></div></section>
<div class="wrap"><div class="cta-band rv z"><h2>Ready to grow your business? 🌱</h2><p>Tell us your goal. We reply within one working day with a free plan.</p><div class="row" style="justify-content:center"><a class="btn alt" href="contact.html">Book a free strategy call</a><a class="btn wa" href="https://wa.me/916281312546" target="_blank" rel="noopener">💬 Chat on WhatsApp</a></div></div></div>
</main>
<footer><div class="wrap"><div class="fgrid">
<div><a class="logo" href="index.html" style="color:#fff">Digi<i>marketing</i>solutions</a><p style="margin-top:12px">Digital marketing that turns clicks into customers. 🚀</p>
<div class="socials"><a href="https://instagram.com/digimarketingsolutions.in" target="_blank" rel="noopener">📸 Instagram</a><a href="https://facebook.com/digimarketingsolutions.in" target="_blank" rel="noopener">👍 Facebook</a><a href="https://youtube.com/@digimarketingsolutions.in" target="_blank" rel="noopener">▶️ YouTube</a></div></div>
<div><h4>Pages</h4><ul><li><a href="index.html">Home</a></li><li><a href="about.html">About us</a></li><li><a href="services.html">Services</a></li><li><a href="projects.html">Projects</a></li><li><a href="contact.html">Contact us</a></li></ul></div>
<div><h4>Services</h4><ul><li><a href="services.html#seo">SEO</a></li><li><a href="services.html#social">Social media</a></li><li><a href="services.html#ads">Paid ads</a></li><li><a href="services.html#content">Content</a></li></ul></div>
<div><h4>Contact</h4><ul><li>📧 <a href="mailto:digimarketingsolutions16@gmail.com">digimarketingsolutions16@gmail.com</a></li><li>📞 <a href="tel:+916281312546">+91 6281312546</a></li><li>📍 Near Ameerpet, Hyderabad</li></ul></div>
</div><div class="copy">© <script>document.write(new Date().getFullYear())</script> Digimarketingsolutions. All rights reserved.</div></div></footer>
<a class="waf" href="https://wa.me/916281312546?text=Hi%20Digimarketingsolutions%2C%20I%20want%20to%20know%20more%20about%20your%20services" target="_blank" rel="noopener" aria-label="Chat on WhatsApp">💬</a>
<button id="top" aria-label="Back to top">⬆</button>
<script src="js/main.js"></script></body></html>
DMS_EOF
echo "Files created in $BASE. Deploying..."
bash "$BASE/deploy/deploy.sh"

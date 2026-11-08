cd C:\Claude\LIL
# --- photos: 111\1..6 -> pix\s01..s06
Remove-Item pix\c* -ErrorAction SilentlyContinue
$files = Get-ChildItem pix\111 -File | Sort-Object { [int]([IO.Path]::GetFileNameWithoutExtension($_.Name) -replace '\D','0') }
$i=1; $names=@(); foreach($f in $files){ $n=('s{0:D2}{1}' -f $i,$f.Extension.ToLower()); Copy-Item $f.FullName "pix\$n"; $names += "'$n'"; $i++ }
Remove-Item pix\111 -Recurse -Force
$list = $names -join ','
$c = Get-Content index.html -Raw -Encoding UTF8
# --- JS
$c = [regex]::Replace($c,'const N=11,F=\[[^\]]*\]',"const N=$($files.Count),F=[$list]")
$c = $c.Replace('w0=0,cx=0;','wc=0,hc=0,cx=0;')
$newMeasure = "function measure(){W=stage.clientWidth;H=stage.clientHeight;const qh=H-(mob()?64:120);`n wc=mob()?Math.min(W*.6,qh*.88*.58):Math.min(W*.31,qh*.88*.58);hc=wc/.58;cx=mob()?W*.38:W*.25;`n cards.forEach(c=>{c.style.width=wc+'px';c.style.height=hc+'px'})}"
$c = [regex]::Replace($c,"(?s)function measure\(\)\{.*?'px'\}\)\}",[System.Text.RegularExpressions.MatchEvaluator]{param($m) $newMeasure})
$c = $c.Replace('x=w0*1.05*(1-s)/LN','x=wc*1.05*(1-s)/LN').Replace('x=-t*(cx+w0*.4)','x=-t*(cx+wc*.4)').Replace('const y=cy-w0/2+w0*(1-s)/2;','const y=cy-hc*s/2;').Replace('translate3d(${cx-w0/2+x}px','translate3d(${cx-wc/2+x}px')
# --- CSS: feathered photos, no frame
$mask='linear-gradient(to right,transparent,#000 24%,#000 76%,transparent),linear-gradient(to bottom,transparent,#000 18%,#000 82%,transparent)'
$c = $c.Replace('.card img{width:100%;height:100%;object-fit:cover;display:block;pointer-events:none;box-shadow:0 30px 60px #000a}',".card img{width:100%;height:100%;object-fit:cover;display:block;pointer-events:none;-webkit-mask-image:$mask;-webkit-mask-composite:source-in;mask-image:$mask;mask-composite:intersect}")
$c = $c.Replace('.card:before{content:"";position:absolute;inset:-12px;border:1px solid var(--gold);opacity:.7;pointer-events:none}','').Replace('.card:before{inset:-7px}','')
$c = $c.Replace('bottom:-40px;left:-12px','bottom:-34px;left:4px').Replace('bottom:-26px;left:-7px','bottom:-24px;left:2px')
$c = $c.Replace('width:52px;height:52px','width:34px;height:54px').Replace('width:30px;height:30px','width:22px;height:36px')
# --- colors: rich grass green
$c = $c.Replace('--em:#0b2a23;--em2:#071d18;','--em:#1f6f3a;--em2:#14572b;').Replace('--gold:#c2a050','--gold:#e3c878').Replace('--rose:#d4a2a3','--rose:#f2c6c4')
# --- one font family
$c = $c.Replace('&family=Jost:wght@300;400;500','').Replace('font:300 18px/1.75 Jost,sans-serif',"font:500 20px/1.65 'Cormorant Garamond',serif")
$c = $c.Replace('Jost,sans-serif',"'Cormorant Garamond',serif").Replace('Jost;',"'Cormorant Garamond',serif;")
$c = $c.Replace("font:400 11px 'Cormorant","font:500 13px 'Cormorant").Replace("font:400 12px 'Cormorant","font:500 14px 'Cormorant").Replace("font:300 14px 'Cormorant","font:500 16px 'Cormorant")
$c = $c.Replace('letter-spacing:.32em;font-size:12px','letter-spacing:.32em;font-size:14px').Replace('letter-spacing:.2em;font-size:13px;text-transform:uppercase;transition:.4s','letter-spacing:.2em;font-size:15px;text-transform:uppercase;transition:.4s').Replace('font-size:19px;counter-increment','font-size:21px;counter-increment')
$c = $c.Replace('body{font-size:15px;line-height:1.6}','body{font-size:17px;line-height:1.5}').Replace('p{font-size:15px}','p{font-size:17px}').Replace('li{padding:12px 0 12px 30px;font-size:15px}','li{padding:12px 0 12px 30px;font-size:17px}')
# --- links: telegram only, no SBP
$c = [regex]::Replace($c,'<a href="#" id="sbp">.*?</a>','')
$c = [regex]::Replace($c,'<a href="#" id="tg">','<a href="https://t.me/she_lisen" target="_blank" rel="noopener" id="tg">')
$c = $c.Replace('.soc{display:grid;grid-template-columns:1fr 1fr;gap:14px}','.soc{display:grid;grid-template-columns:1fr;gap:14px}')
# --- modal
$css=@'
.modal{position:fixed;inset:0;z-index:300;display:grid;place-items:center;padding:16px;background:rgba(5,25,12,.74);backdrop-filter:blur(6px);opacity:0;visibility:hidden;transition:opacity .4s,visibility .4s}
.modal.open{opacity:1;visibility:visible}
.mbox{position:relative;width:min(100%,420px);max-height:94vh;overflow:auto;background:#f6f1e8;color:#14401f;padding:30px 26px 26px;text-align:center;outline:1px solid var(--gold);outline-offset:-10px;transform:translateY(24px) scale(.97);transition:transform .5s cubic-bezier(.22,1,.36,1)}
.modal.open .mbox{transform:none}
.mbox h3{font:italic 600 36px/1.1 'Cormorant Garamond',serif;margin:0 0 8px}
.mbox p{max-width:none;color:#35523b;font-size:19px;line-height:1.3}
.mbox img{display:block;width:min(70vw,250px);margin:18px auto;background:#fff;padding:8px}
.mbox .mb{display:block;margin-top:10px;padding:14px;font:italic 600 23px 'Cormorant Garamond',serif;text-decoration:none;border:1px solid #14572b;color:#14572b;transition:.3s}
.mbox .mb.pri{background:#14572b;color:#f6f1e8}
.mbox .mb:hover{background:var(--gold);color:#14401f;border-color:var(--gold)}
.mx{position:absolute;right:12px;top:6px;background:none;border:0;font:300 36px/1 'Cormorant Garamond',serif;color:#14572b;cursor:pointer;padding:6px 10px}
'@
$html=@'
<div class="modal" id="modal" role="dialog" aria-modal="true" aria-labelledby="mt" aria-hidden="true"><div class="mbox"><button class="mx" id="mx" aria-label="Закрыть">×</button><h3 id="mt">Оплата билета</h3><p>Отсканируйте QR-код камерой телефона или в приложении банка</p><img src="qr.svg" alt="QR-код для оплаты"><a class="mb pri" href="https://www.sberbank.ru/ru/choise_bank?requisiteNumber=79882866956&bankCode=100000000111" target="_blank" rel="noopener">Открыть в приложении банка</a><a class="mb" href="https://t.me/she_lisen" target="_blank" rel="noopener">Отправить чек в Telegram</a></div></div>
<script>
const modal=document.getElementById('modal');
const openM=e=>{e&&e.preventDefault();modal.classList.add('open');modal.setAttribute('aria-hidden','false');lenis&&lenis.stop();document.getElementById('mx').focus()};
const closeM=()=>{modal.classList.remove('open');modal.setAttribute('aria-hidden','true');lenis&&lenis.start()};
document.getElementById('buy').addEventListener('click',openM);document.getElementById('mx').addEventListener('click',closeM);
modal.addEventListener('click',e=>{if(e.target===modal)closeM()});addEventListener('keydown',e=>{if(e.key==='Escape')closeM()});
</script>
'@
$c = $c.Replace('</style></head>',$css+'</style></head>').Replace('</body>',$html+'</body>')
[IO.File]::WriteAllText("$PWD\index.html",$c,(New-Object Text.UTF8Encoding $false))
$ms=[regex]::Matches($c,'<script>(.*?)</script>',[System.Text.RegularExpressions.RegexOptions]::Singleline)
$k=0; foreach($m in $ms){ $k++; [IO.File]::WriteAllText("$PWD\_c$k.js",$m.Groups[1].Value); node --check "_c$k.js" 2>&1; Remove-Item "_c$k.js" }
"scripts: $k; Jost left: " + ([regex]::Matches($c,'Jost')).Count + "; sbp left: " + ([regex]::Matches($c,'id="sbp"')).Count
(Get-ChildItem pix | Select -Expand Name) -join ', '
git add -A; git commit -m "New 6 photos feathered, green bg, one font, QR payment modal, Telegram link" 2>&1 | Select -Last 1; git push 2>&1 | Select -Last 1

// Wave stepper + species-group tabs for the v2.2 story site.

function wireTabs(btnSelector, onSelect) {
  const btns = Array.from(document.querySelectorAll(btnSelector));
  if (!btns.length) return;
  btns.forEach((btn) => {
    btn.addEventListener('click', () => {
      btns.forEach((b) => {
        b.classList.toggle('is-active', b === btn);
        b.setAttribute('aria-selected', b === btn ? 'true' : 'false');
      });
      onSelect(btn);
    });
  });
}

function swapImage(img, src) {
  if (!img || img.getAttribute('src') === src) return;
  img.style.opacity = '0';
  const next = new Image();
  next.onload = () => {
    img.src = src;
    requestAnimationFrame(() => { img.style.opacity = '1'; });
  };
  next.onerror = () => { img.src = src; img.style.opacity = '1'; };
  next.src = src;
}

document.addEventListener('DOMContentLoaded', () => {
  const waveImg = document.getElementById('waveImg');
  const waveCountImg = document.getElementById('waveCountImg');
  const waveTitle = document.getElementById('waveTitle');
  const waveNote = document.getElementById('waveNote');

  wireTabs('.wave-btn', (btn) => {
    swapImage(waveImg, `assets/${btn.dataset.fig}.png`);
    // Style C (overlapping bars, grouped by taxonomy) replaces the old
    // plain "-counts" observed-population chart as of v2.2.
    swapImage(waveCountImg, `assets/${btn.dataset.fig}-stylec.png`);
    if (waveTitle) waveTitle.innerHTML = btn.dataset.title;
    if (waveNote) waveNote.innerHTML = btn.dataset.note;
  });

  const groupImg = document.getElementById('groupImg');
  const groupTitle = document.getElementById('groupTitle');
  const groupNote = document.getElementById('groupNote');
  const groupSpecies = document.getElementById('groupSpecies');

  wireTabs('.group-btn', (btn) => {
    swapImage(groupImg, `assets/${btn.dataset.fig}.png`);
    if (groupTitle) groupTitle.innerHTML = btn.dataset.title;
    if (groupNote) groupNote.innerHTML = btn.dataset.note;
    if (groupSpecies) groupSpecies.innerHTML = btn.dataset.species;
  });

  // Arrow-key navigation between waves.
  document.addEventListener('keydown', (e) => {
    if (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') return;
    const btns = Array.from(document.querySelectorAll('.wave-btn'));
    const i = btns.findIndex((b) => b.classList.contains('is-active'));
    if (i < 0) return;
    const picker = document.querySelector('.waves-section');
    if (!picker) return;
    const r = picker.getBoundingClientRect();
    if (r.bottom < 0 || r.top > window.innerHeight) return; // only when in view
    const next = e.key === 'ArrowRight'
      ? Math.min(i + 1, btns.length - 1)
      : Math.max(i - 1, 0);
    if (next !== i) btns[next].click();
  });
});

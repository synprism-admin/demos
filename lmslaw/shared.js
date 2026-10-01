(function () {
  'use strict';

  /* ── Sticky nav scroll logo ── */
  var nav = document.querySelector('.lms-nav');
  var topbar = document.querySelector('.lms-topbar');
  if (nav) {
    function checkScroll() {
      var threshold = topbar ? topbar.offsetHeight : 60;
      nav.classList.toggle('lms-nav--scrolled', window.scrollY > threshold);
    }
    window.addEventListener('scroll', checkScroll, { passive: true });
    checkScroll();
  }

  /* ── Mobile hamburger menu ── */
  if (!nav) return;

  // Inject hamburger button into nav inner
  var navInner = nav.querySelector('.lms-nav-inner');
  if (!navInner) return;

  var btn = document.createElement('button');
  btn.className = 'lms-mob-btn';
  btn.setAttribute('aria-label', 'Open menu');
  btn.innerHTML =
    '<span></span><span></span><span></span>';
  navInner.appendChild(btn);

  // Build mobile panel from existing menu items
  var panel = document.createElement('div');
  panel.className = 'lms-mob-panel';

  var menu = nav.querySelector('.lms-menu');
  if (menu) {
    var items = menu.querySelectorAll('li');
    items.forEach(function (li) {
      // Top-level link
      var topLink = li.querySelector(':scope > a');
      if (!topLink) return;
      var row = document.createElement('div');
      row.className = 'lms-mob-row';

      var a = document.createElement('a');
      a.href = topLink.href;
      a.textContent = topLink.textContent.replace('▾', '').trim();
      if (topLink.classList.contains('lms-active')) a.classList.add('lms-active');
      row.appendChild(a);

      // Sub-links
      var drop = li.querySelector('.lms-drop');
      if (drop) {
        var tog = document.createElement('button');
        tog.className = 'lms-mob-tog';
        tog.innerHTML = '&#9660;';
        row.appendChild(tog);

        var sub = document.createElement('div');
        sub.className = 'lms-mob-sub';
        drop.querySelectorAll('a').forEach(function (da) {
          var sa = document.createElement('a');
          sa.href = da.href;
          sa.textContent = da.textContent.trim();
          sub.appendChild(sa);
        });

        tog.addEventListener('click', function (e) {
          e.stopPropagation();
          var open = sub.classList.toggle('open');
          tog.classList.toggle('open', open);
        });

        panel.appendChild(row);
        panel.appendChild(sub);
      } else {
        panel.appendChild(row);
      }
    });
  }

  nav.appendChild(panel);

  // Toggle open/close
  var open = false;
  function setOpen(state) {
    open = state;
    btn.classList.toggle('open', open);
    panel.classList.toggle('open', open);
    btn.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
  }

  btn.addEventListener('click', function (e) {
    e.stopPropagation();
    setOpen(!open);
  });

  document.addEventListener('click', function () {
    if (open) setOpen(false);
  });

  panel.addEventListener('click', function (e) {
    e.stopPropagation();
  });

})();

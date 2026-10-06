
document.querySelectorAll('[data-menu]').forEach(b=>b.addEventListener('click',()=>document.body.classList.toggle('menu-open')));
document.querySelectorAll('[data-alert]').forEach(b=>b.addEventListener('click',()=>alert(b.dataset.alert)));

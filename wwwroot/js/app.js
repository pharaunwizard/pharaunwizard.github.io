window.marsCv = window.marsCv || {};

window.marsCv.openMailto = function (address) {
    window.location.href = 'mailto:' + address;
};

document.addEventListener('click', function (event) {
    var link = event.target && event.target.closest ? event.target.closest('a[data-mail]') : null;
    if (!link) {
        return;
    }
    event.preventDefault();
    try {
        var address = atob(link.getAttribute('data-mail'));
        window.marsCv.openMailto(address);
    } catch (err) {
        // почтовый клиент может быть не настроен — интерфейс не ломается
    }
});

window.marsCv.appReady = function (photoSelector) {
    var done = function () {
        requestAnimationFrame(function () {
            requestAnimationFrame(function () {
                document.documentElement.classList.add('app-loaded');
            });
        });
    };

    var img = photoSelector ? document.querySelector(photoSelector) : null;
    if (img && !img.complete) {
        if (typeof img.decode === 'function') {
            img.decode().then(done, done);
        } else {
            img.addEventListener('load', done, { once: true });
            img.addEventListener('error', done, { once: true });
        }
    } else {
        done();
    }
};

document.addEventListener('DOMContentLoaded', function () {
    var ui = document.getElementById('blazor-error-ui');
    if (!ui || typeof MutationObserver === 'undefined') {
        return;
    }
    new MutationObserver(function () {
        if (window.getComputedStyle(ui).display !== 'none') {
            document.documentElement.classList.add('app-loaded');
        }
    }).observe(ui, { attributes: true, attributeFilter: ['style', 'class'] });
});

window.marsCv.initReveal = function () {
    if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return 0;
    }
    if (typeof IntersectionObserver === 'undefined') {
        return 0;
    }

    const targets = document.querySelectorAll('.section:not(.hero)');
    const observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.isIntersecting) {
                entry.target.classList.add('is-visible');
                observer.unobserve(entry.target);
            }
        });
    }, { rootMargin: '0px 0px -10% 0px', threshold: 0.08 });

    targets.forEach(function (target) {
        target.classList.add('reveal');
        observer.observe(target);
    });

    return targets.length;
};

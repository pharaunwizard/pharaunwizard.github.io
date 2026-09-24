window.marsCv = window.marsCv || {};

window.marsCv.openMailto = function (local, domain) {
    window.location.href = 'mailto:' + local + '@' + domain;
};

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

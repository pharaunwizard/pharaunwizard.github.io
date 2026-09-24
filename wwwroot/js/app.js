window.marsCv = window.marsCv || {};

window.marsCv.openMailto = function (local, domain) {
    window.location.href = 'mailto:' + local + '@' + domain;
};

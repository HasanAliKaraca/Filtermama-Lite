function test() {

    var filter = {
        curves: "inkwell",
        desaturate: false,
        vignette: false
    };

    $('#the-photo').filterMe(
        filter
    );


}

/* ==================================================
 *      GLOBALS
 * ==================================================
 */

App = {};
Settings = {};

b64Cache = [];

filtering = false;
thePhoto = document.getElementById('the-photo');
thePhoto.style.height = window.innerWidth + 'px';

var theCanvas = document.getElementById('canvas');
theCanvas.style.width = window.innerWidth;
theCanvas.style.height = window.innerWidth;

filterPackInstalledVersion = window.localStorage.getItem('filterPackInstalledVersion') || 0;
filterPackNewVersion = window.localStorage.getItem('filterPackNewVersion') || 0;

/* ==================================================
 *      HANDLE NATIVE CHIT-CHAT
 * ==================================================
 */

try {
    navigator.cascades.onmessage = function onmessage(message) {
        message = JSON.parse(message);

        // load photo
        if (message.cmd === 'loadPhoto') {
            thePhoto.src = 'data:image/png;base64,' + message.data;
            prepareImage();

            // save photo
        } else if (message.cmd === 'savePhoto') {
            savePhoto();

            // filter the image
        } else if (message.cmd === 'filter') {
            if (!filtering) {
                setTimeout(function() {
                    filtering = true;
                    process(message.data);
                    console.log(message.data);
                }, 350);
            } else {
                return;
            }
        }
    };
} catch (e) {}



/* ==================================================
 *      PREPARE BASE64 FOR SAVING
 * ==================================================
 */

var savePhoto = function() {
    var b64 = thePhoto.src;
    //b64 = b64.replace('data:image/png;base64,', '');
    navigator.cascades.postMessage(b64);
};



/* ==================================================
 *      PROCESS FILTERS
 * ==================================================
 */

var process = function(effect) {
    filterId = effect.id;
    if (effect.id === 'normal') {
        console.log('no filter - reset the photo');

        // reset photo source
        thePhoto.src = b64Cache['normal'];
        navigator.cascades.postMessage('filter-done');
        filtering = false;
        return;

    } else {

        // if filter already applied and cached
        if (b64Cache[effect.id]) {
            console.log('--- filter already cahced ---');
            thePhoto.src = b64Cache[effect.id];
            filtering = false;
            console.log('--- done filtering ---');
            setTimeout(function() {
                navigator.cascades.postMessage('filter-done');
            }, 250);

            // if not, filter it!
        } else {

            if (effect.filter.curves) {
                console.log('make curves an array');
                var a = effect.filter.curves.a;
                var r = effect.filter.curves.r;
                var g = effect.filter.curves.g;
                var b = effect.filter.curves.b;

                a = JSON.parse("[" + a + "]");
                r = JSON.parse("[" + r + "]");
                g = JSON.parse("[" + g + "]");
                b = JSON.parse("[" + b + "]");

                curvesObject = {
                    "a": a[0],
                    "r": r[0],
                    "g": g[0],
                    "b": b[0]
                };

            } else {
                curvesObject = false;
            }

            var filter = {
                curves: curvesObject,
                desaturate: effect.filter.desaturate,
                vignette: effect.filter.vignette
            };

            // process the filter
            jQuery(document).ready(function($) {
                $('#the-photo').filterMe(
                    filter
                );

                // process callback
                $(this).bind('filterMe.processEnd', function(event, base) {
                    filtering = false;
                    b64Cache[filterId] = thePhoto.src;
                    console.log('--- done filtering ---');
                    navigator.cascades.postMessage('filter-done');
                });
            });
        }
    }
};



/* ==================================================
 *      LOAD, RESCALE, AND CREATE THE PHOTO INSTANCE
 * ==================================================
 */

var prepareImage = function(filepath, success, error) {
    console.log('[prepare image]');
    setTimeout(function() {
        var canvas = jQuery('canvas').get(0);
        var ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerWidth;
        ctx.drawImage(thePhoto, 0, 0, canvas.width, canvas.height);
        b64Cache = [];
        b64Cache['normal'] = canvas.toDataURL('image/png');
        thePhoto.src = b64Cache['normal'];
    }, 100);
};



/* ==================================================
 *          CONSOLE LOGS
 * ==================================================
 */

var log = function log(msg) {
    console.log('[  ' + msg + '  ]');
};
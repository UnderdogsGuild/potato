var xivdb_tooltips_config =
{
    // General
    'version'       : '1.5',
    'domain'        : 'xivdb.com',

    // Tooltip options
    'zindex'        : '99999999',
    'convertQuotes' : true,
    'frameShadow'   : true,
    'compact'       : false,
    'statsOnly'     : false,
    'replaceName'   : true,
    'colorName'     : true,
    'showIcon'      : true,

    // Accept url domains
    hrefs:
    [
        'xivdb.com',
        'xivdatabase.com',
        'www.xivdb.com',
        'www.xivdatabase.com',
        'jp.xivdb.com',
        'en.xivdb.com',
        'de.xivdb.com',
        'fr.xivdb.com',
    ],

    // List of languages
    language:
    {
        list: ["JP", "EN", "DE", "FR"],
        value: 1,
    },

};

// Main tooltip function
function fPopLoadItem()
{
    "undefined" != typeof Prototype && jQuery.noConflict();
    jQuery("a").each(function (index, value) 
    {
        // Set vars
        var url  = jQuery(this).attr("href");
        var host = null;
        if (void 0 != url && url.indexOf('/') > -1)
        {  
            url = url.split('/');
            var host = url[2];
        }

        // If valid address
        var ValidAddress = xivdb_tooltips_config.hrefs.indexOf(host);

        // If host not undefined and valid address is in hrefs
        if (void 0 != host && ValidAddress != -1) 
        {
            var type, id, name;
            if (url[3]) { type = url[3].replace('?', ''); }
            if (url[4]) { id= url[4]; }
            if (url[5]) { name = url[5].replace('-', ' '); }

            // If any tooltip settings passed
            if (typeof xivdb_tooltips !== "undefined") 
            { 
                // If language set, get the value from the list using its index
                if (typeof xivdb_tooltips.language !== "undefined")
                {
                    xivdb_tooltips_config.language.value = xivdb_tooltips_config.language.list.indexOf(xivdb_tooltips.language);
                }

                // If shadow set
                if (typeof xivdb_tooltips.frameShadow !== "undefined")
                {
                    xivdb_tooltips_config.frameShadow = xivdb_tooltips.frameShadow;
                }

                // if convert quotes set
                if (typeof xivdb_tooltips.convertQuotes !== "undefined")
                {
                    xivdb_tooltips_config.convertQuotes = xivdb_tooltips.convertQuotes;
                }

                // if compact
                if (typeof xivdb_tooltips.compact !== "undefined")
                {
                    xivdb_tooltips_config.compact = xivdb_tooltips.compact;
                }

                // if stats only
                if (typeof xivdb_tooltips.statsOnly !== "undefined")
                {
                    xivdb_tooltips_config.statsOnly = xivdb_tooltips.statsOnly;
                }

                // if replace name
                if (typeof xivdb_tooltips.replaceName !== "undefined")
                {
                    xivdb_tooltips_config.replaceName = xivdb_tooltips.replaceName;
                }

                // if color name
                if (typeof xivdb_tooltips.colorName !== "undefined")
                {
                    xivdb_tooltips_config.colorName = xivdb_tooltips.colorName;
                }

                // if show icon
                if (typeof xivdb_tooltips.showIcon !== "undefined")
                {
                    xivdb_tooltips_config.showIcon = xivdb_tooltips.showIcon;
                }
            }

            var replacename = jQuery(this).attr("data-replacename");
            if (replacename) 
            { 
                replacename = parseInt(replacename);
                xivdb_tooltips_config.replaceName = replacename;
            }

            var t = jQuery(this);
            void 0 == id || !jQuery.isNumeric(id) || (jQuery.ajax({
                url: "http://"+ xivdb_tooltips_config.domain +"/modules/fpop/fpop.php",
                data: 
                {
                    lang: xivdb_tooltips_config.language.value,
                    version: xivdb_tooltips_config.version,
                    host: host,
                    type: type,
                    id: id,
                    name: name,
                    location: window.location.toString(),

                    convertQuotes: xivdb_tooltips_config.convertQuotes,
                    frameShadow: xivdb_tooltips_config.frameShadow,
                    compact: xivdb_tooltips_config.compact,
                    statsOnly: xivdb_tooltips_config.statsOnly,
                    replaceName: xivdb_tooltips_config.replaceName,
                    colorName: xivdb_tooltips_config.colorName,
                    showIcon: xivdb_tooltips_config.showIcon,
                },
                type: 'GET',
                dataType: "jsonp",
                success: function (e) 
                {
                    if (void 0 != e)
                    {
                        t.attr("title", "");
                        if (xivdb_tooltips_config.replaceName) { t.html(e.name); }
                        t.data("tooltip", e.html.replace('db.xivdev.com', 'xivtooltips.com'));
                        t.simpletooltip({
                            fixed: !0,
                            position: "bottom"
                        });
                    }
                    else
                    {
                        console.log("Error[1] fetching tooltip data, please copy the below response to: http://xivpads.com/?Support");
                        console.log(e);
                        console.log("---");
                    }
                },
                error: function (e, t, n) 
                {
                    console.log("Error[2] fetching tooltip data, please copy the below response to: http://xivpads.com/?Support");
                    console.log(e.responseText);
                    console.log(t);
                    console.log(n);
                    console.log("---");
                }
            }));
        }
    });
}

// Other required functions
function fPopGetScript(e,t){var n=document.createElement("script");n.src=e;var r=document.getElementsByTagName("head")[0],i=!1;void 0==r&&(r=document.getElementsByTagName("body")[0]);n.onload=n.onreadystatechange=function(){i||this.readyState&&"loaded"!=this.readyState&&"complete"!=this.readyState||(i=!0,t(),n.onload=n.onreadystatechange=null,r.removeChild(n))};r.appendChild(n)};
function fPopLoadTips(){"undefined"!=typeof Prototype&&jQuery.noConflict();jQuery.fn.simpletooltip||function(e){e.fn.simpletooltip=function(){return this.each(function(){void 0!=e(this).data("tooltip")&&(e(this).hover(function(t){e("#simpleTooltip").remove();var n=e(this).data("tooltip"),r=t.pageX+5;t=t.pageY+5;e("body").append("<div id='simpleTooltip' style='position: absolute; z-index: "+ xivdb_tooltips_config.zindex +"; display: none;'>"+n+"</div>");n=e("#simpleTooltip").width();e("#simpleTooltip").width(n);e("#simpleTooltip").css("left",r).css("top",t).show()},function(){e("#simpleTooltip").remove()}),e(this).mousemove(function(t){var n=t.pageX+12,r=t.pageY+12,i=e("#simpleTooltip").outerWidth(!0),s=e("#simpleTooltip").outerHeight(!0);n+i>e(window).scrollLeft()+e(window).width()&&(n=t.pageX-i);e(window).height()+e(window).scrollTop()<r+s&&(r=t.pageY-s);e("#simpleTooltip").css("left",n).css("top",r).show()}))})}}(jQuery);fPopLoadItem()};
function fPopInit(){"undefined"==typeof jQuery?fPopGetScript("//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js",fPopLoadTips):fPopLoadTips()}

// Oncall event
initXIVDBTooltips=function(){var e=document.createElement("link");e.setAttribute("rel","stylesheet");e.setAttribute("href","http://"+xivdb_tooltips_config.domain+"/css/tooltip.css");e.setAttribute("type","text/css");document.getElementsByTagName("head")[0].appendChild(e);var e=setInterval(function(){"complete"===document.readyState&&(clearInterval(e),fPopInit())},10)}
document.addEventListener('DOMContentLoaded',function(){ initXIVDBTooltips(); })
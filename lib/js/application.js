var xivdb_tooltips =
{
  'language' : 'EN',
  'convertQuotes' : true,
  'frameShadow' : false,
  'compact' : false,
  'statsOnly' : false,
  'replaceName' : true,
  'colorName' : true,
  'showIcon' : true,
};

// Google Analytics
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','//www.google-analytics.com/analytics.js','ga');ga('create', 'UA-46777577-1', 'underdogs.im');ga('send', 'pageview');

// Hash passwords on submit
$("form").submit(function() {
  var plainfield = $(this).find("input[name='plain_password']");
  var hashfield = $(this).find("input[name='password']");
  hashfield.val(SHA512(plainfield.val()));
  plainfield.val("");
});


var progress = $('#progress'),
    slideshow = $( '.cycle-slideshow' );
slideshow.on( 'cycle-initialized cycle-before', function( e, opts ) {
  progress.stop(true).css( 'width', 0 );
});
slideshow.on( 'cycle-initialized cycle-after', function( e, opts ) {
  if ( ! slideshow.is('.cycle-paused') )
  progress.animate({ width: '100%' }, opts.timeout, 'linear' );
});
slideshow.on( 'cycle-paused', function( e, opts ) {
  progress.stop(); 
});
slideshow.on( 'cycle-resumed', function( e, opts, timeoutRemaining ) {
  progress.animate({ width: '100%' }, timeoutRemaining, 'linear' );
});

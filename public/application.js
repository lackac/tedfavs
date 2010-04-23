$(function() {
  $('#profile_id').keypress(function(event) {
    if (event) {
      setTimeout(arguments.callee, 0);
      return;
    }

    var id = parseInt($('#profile_id').val());
    if (id && id > 0) {
      $('#feed-link').html('TED Favorites RSS Feed').attr('href', '/tedfavs/'+id+'.rss');
    } else {
      $('#feed-link').html('').attr('href', '');
    }
  });
});

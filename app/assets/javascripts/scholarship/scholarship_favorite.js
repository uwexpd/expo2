$(document).on('turbolinks:load', function () {

  var $btn = $('.favorite-btn');
  if ($btn.length === 0) return;

  $btn.on('click', function () {
    var $this        = $(this);
    var favorited    = $this.data('favorited') === true || $this.data('favorited') === 'true';
    var loginUrl     = $this.data('login-url');
    var createUrl    = $this.data('create-url');
    var destroyUrl   = $this.data('destroy-url');
    var scholarshipId = $this.data('scholarship-id');

    // ── Not logged in → redirect to login ───────────────────────────────
    if (!loginUrl || $this.data('favorited') === undefined) return;

    // Check if user is logged in by attempting the request;
    // the controller will return 401 if not, and we redirect.

    var method = favorited ? 'DELETE' : 'POST';
    var url    = favorited ? destroyUrl : createUrl;
    var payload = favorited ? {} : { scholarship_id: scholarshipId };

    // Optimistic UI update
    $this.addClass('loading').removeClass('favorited');

    $.ajax({
      url:    url,
      method: method,
      data:   payload,
      headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
      dataType: 'json',
      success: function (response) {
        $this.removeClass('loading');

        if (response.favorited) {
          $this.addClass('favorited')
               .data('favorited', 'true')
               .attr('title', 'Remove from favorites')
               .find('i').text('favorite');
        } else {
          $this.removeClass('favorited')
               .data('favorited', 'false')
               .attr('title', 'Add to favorites')
               .find('i').text('favorite_border');
        }
      },
      error: function (xhr) {
        $this.removeClass('loading');

        // ── Not logged in → redirect to login ─────────────────────────
        if (xhr.status === 401) {
          var redirect = xhr.responseJSON && xhr.responseJSON.redirect;
          window.location.href = redirect || loginUrl;
          return;
        }

        // ── Any other error → revert optimistic update ─────────────────
        if (favorited) {
          $this.addClass('favorited')
               .data('favorited', 'true')
               .find('i').text('favorite');
        } else {
          $this.data('favorited', 'false')
               .find('i').text('favorite_border');
        }

        console.error('Favorite toggle failed:', xhr.responseJSON);
      }
    });
  });

});

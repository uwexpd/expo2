(function () {
  var FILTER_SELECTOR = 'form.filter_form input[name="q[student_number_eq]"]';
  var UID_PATTERN = /^[0-9a-f]{14}$/i;
  var STUDENT_NUMBER_PATTERN = /^\d{7}$/;
  var SCAN_GAP_MS = 500;
  var NOTICE_KEY = 'event_invitee_rfid_lookup_notice';
  var buffer = '';
  var lastKeyAt = 0;
  var lookupPending = false;
  var suppressSuffixUntil = 0;

  function lookupUrl() {
    var path = window.location.pathname.replace(/\/$/, '');
    var nestedInvitees = path.match(/^(.*\/times\/\d+\/invitees)$/);
    return nestedInvitees
      ? nestedInvitees[1] + '/lookup_rfid'
      : '/expo/admin/invitees/lookup_rfid';
  }

  function csrfToken() {
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.content : null;
  }

  function showStatus(message, isError) {
    var status = document.querySelector('#rfid-reader-status');
    if (!status) {
      var input = document.querySelector(FILTER_SELECTOR);
      if (!input || !input.form) return;
      status = document.createElement('span');
      status.id = 'rfid-reader-status';
      status.style.marginLeft = '8px';
      input.form.appendChild(status);
    }
    status.textContent = message;
    status.style.color = isError ? '#b91c1c' : '#166534';
  }

  function showSavedNotice() {
    var studentNumber = sessionStorage.getItem(NOTICE_KEY);
    if (!studentNumber) return;
    sessionStorage.removeItem(NOTICE_KEY);

    var currentNumber = new URLSearchParams(window.location.search).get('q[student_number_eq]');
    if (currentNumber !== studentNumber) return;

    var notice = document.createElement('div');
    notice.id = 'rfid-lookup-notice';
    notice.className = 'flash flash_notice';
    notice.setAttribute('role', 'status');
    notice.textContent = 'Found student with number: ' + studentNumber +
      '. Student-number filter applied. Select Check in to check them in.';

    var content = document.querySelector('#active_admin_content');
    if (content) {
      content.parentNode.insertBefore(notice, content);
    } else {
      var wrapper = document.querySelector('#wrapper');
      if (wrapper) wrapper.insertBefore(notice, wrapper.firstChild);
    }
  }

  function submitStudentNumber(studentNumber) {
    var input = document.querySelector(FILTER_SELECTOR);
    if (!input) return;
    var value = String(studentNumber);
    if (!STUDENT_NUMBER_PATTERN.test(value)) {
      throw new Error('Card lookup returned an invalid student number.');
    }

    input.value = value;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
    sessionStorage.setItem(NOTICE_KEY, value);

    var form = input.form;
    if (form.requestSubmit) {
      form.requestSubmit();
    } else {
      var submitButton = form.querySelector('[type="submit"]');
      if (submitButton) submitButton.click();
      else form.submit();
    }
  }

  function lookUpUid(uid) {
    showStatus('Looking up card…');
    var headers = { Accept: 'application/json', 'Content-Type': 'application/json' };
    var token = csrfToken();
    if (token) headers['X-CSRF-Token'] = token;

    return fetch(lookupUrl(), {
      method: 'POST',
      headers: headers,
      body: JSON.stringify({ rfid_uid: uid })
    }).then(function (response) {
      return response.json().then(function (data) {
        if (!response.ok) throw new Error(data.error || 'Unable to look up this card.');
        showStatus('Student found. Applying filter…');
        submitStudentNumber(data.student_number);
      });
    });
  }

  function initializeRfidReader() {
    var input = document.querySelector(FILTER_SELECTOR);
    if (!input) return;

    showSavedNotice();
    document.addEventListener('keydown', function (event) {
      if (event.ctrlKey || event.altKey || event.metaKey || event.repeat) return;
      if (event.key === 'Shift') return;

      // Leave other editable fields alone; a scan can still start on the page or in this filter.
      var target = event.target;
      if (target !== input && target.isContentEditable) return;
      if (target !== input && /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName)) return;

      var now = Date.now();
      if (now - lastKeyAt > SCAN_GAP_MS) buffer = '';
      lastKeyAt = now;

      if (now < suppressSuffixUntil && (event.key === ' ' || event.key === 'Spacebar')) {
        event.preventDefault();
        event.stopImmediatePropagation();
        return;
      }

      if (event.key === 'Enter' || event.key === 'Tab') {
        // The reader may send Enter after the 14th digit already started the lookup.
        if (now < suppressSuffixUntil) {
          event.preventDefault();
          event.stopImmediatePropagation();
          return;
        }
        var uid = buffer.replace(/\s+/g, '');
        buffer = '';
        if (!UID_PATTERN.test(uid) || lookupPending) return;
        event.preventDefault();
        event.stopImmediatePropagation();
        startLookup(uid);
        return;
      }

      if (/^[0-9a-f]$/i.test(event.key)) {
        buffer += event.key;
      } else if (event.key === ' ' || event.key === 'Spacebar') {
        buffer += ' ';
      } else {
        buffer = '';
        return;
      }

      var normalized = buffer.replace(/\s+/g, '');
      if (UID_PATTERN.test(normalized) && !lookupPending) {
        // Complete scan: don't let the final key or the reader's Enter submit raw UID.
        event.preventDefault();
        event.stopImmediatePropagation();
        buffer = '';
        startLookup(normalized);
      } else if (normalized.length > 14) {
        buffer = '';
      }
    }, true);

    function startLookup(uid) {
      input.value = ''; // Earlier scan keystrokes may have landed in the focused filter.
      lookupPending = true;
      suppressSuffixUntil = Date.now() + 1000;
      lookUpUid(uid).catch(function (error) {
        console.error('[RFID] Lookup failed:', error);
        showStatus(error.message, true);
      }).then(function () {
        lookupPending = false;
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeRfidReader);
  } else {
    initializeRfidReader();
  }
})();
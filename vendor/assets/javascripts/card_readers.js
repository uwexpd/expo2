(function () {
  var EVENT_FILTER_SELECTOR = 'form.filter_form input[name="q[student_number_eq]"]';
  var APPOINTMENT_FILTER_SELECTOR = 'form.filter_form input[name="q[student_no_search_eq]"]';
  var NEW_APPOINTMENT_SELECTOR = 'form#new_appointment .student-lookup .student-number-search';
  var UID_PATTERN = /^[0-9a-f]{14}$/i;
  var STUDENT_NUMBER_PATTERN = /^\d{7}$/;
  var SCAN_GAP_MS = 500;
  var buffer = '';
  var lastKeyAt = 0;
  var lookupPending = false;
  var suppressSuffixUntil = 0;

  function mode() {
    var path = window.location.pathname.replace(/\/$/, '');
    if (path === '/expo/admin/appointments/new' && document.querySelector(NEW_APPOINTMENT_SELECTOR)) return 'appointment_new';
    if (path === '/expo/admin/appointments' && document.querySelector(APPOINTMENT_FILTER_SELECTOR)) return 'appointment';
    if (document.querySelector(EVENT_FILTER_SELECTOR) && document.querySelector('[data-rfid-event-id]')) return 'event';
    return null;
  }

  function filterSelector() {
    if (mode() === 'appointment_new') return NEW_APPOINTMENT_SELECTOR;
    return mode() === 'appointment' ? APPOINTMENT_FILTER_SELECTOR : EVENT_FILTER_SELECTOR;
  }

  function noticeKey() {
    return 'rfid_checkin_notice_' + mode();
  }

  function lookupUrl() {
    if (mode() === 'appointment_new') return '/expo/admin/appointments/prefill_rfid';
    if (mode() === 'appointment') return '/expo/admin/appointments/checkin_rfid';
    var path = window.location.pathname.replace(/\/$/, '');
    var nestedInvitees = path.match(/^(.*\/times\/\d+\/invitees)$/);
    return nestedInvitees ? nestedInvitees[1] + '/lookup_rfid' : '/expo/admin/invitees/lookup_rfid';
  }

  function csrfToken() {
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.content : null;
  }

  function showStatus(message, isError) {
    var status = document.getElementById('rfid-reader-status');
    if (!status) {
      var input = document.querySelector(filterSelector());
      if (!input || !input.form) return;
      status = document.createElement('span');
      status.id = 'rfid-reader-status';
      status.style.marginLeft = '8px';
      input.form.appendChild(status);
    }
    status.textContent = message;
    status.style.color = isError ? '#b91c1c' : '#166534';
  }

  function showFlashAlert(message) {
    var oldAlert = document.getElementById('rfid-lookup-alert');
    if (oldAlert) oldAlert.remove();
    var status = document.getElementById('rfid-reader-status');
    if (status) status.textContent = '';
    var content = document.getElementById('active_admin_content');
    if (!content) return;
    var alert = document.createElement('div');
    alert.id = 'rfid-lookup-alert';
    alert.className = 'flash flash_alert';
    alert.setAttribute('role', 'alert');
    alert.textContent = message;
    content.parentNode.insertBefore(alert, content);
  }

  function showFlashNotice(message) {
    var oldNotice = document.getElementById('rfid-lookup-notice');
    if (oldNotice) oldNotice.remove();
    var status = document.getElementById('rfid-reader-status');
    if (status) status.textContent = '';
    var content = document.getElementById('active_admin_content');
    if (!content) return;
    var notice = document.createElement('div');
    notice.id = 'rfid-lookup-notice';
    notice.className = 'flash flash_notice';
    notice.setAttribute('role', 'status');
    notice.textContent = message;
    content.parentNode.insertBefore(notice, content);
  }

  function eventId() {
    var context = document.querySelector('[data-rfid-event-id]');
    return context ? context.getAttribute('data-rfid-event-id') : null;
  }

  function eventTimeId() {
    var path = window.location.pathname.match(/\/times\/(\d+)\/invitees/);
    if (path) return path[1];
    var selector = document.getElementById('rfid_event_time_id');
    return selector ? selector.value : null;
  }

  function initializeEventTimeSelector() {
    var selector = document.getElementById('rfid_event_time_id');
    var filterInput = document.querySelector(EVENT_FILTER_SELECTOR);
    if (!selector || !filterInput || !filterInput.form) return;
    var hidden = filterInput.form.querySelector('input[name="event_time_id"]');
    if (!hidden) {
      hidden = document.createElement('input');
      hidden.type = 'hidden';
      hidden.name = 'event_time_id';
      filterInput.form.appendChild(hidden);
    }
    function syncSelection() {
      hidden.value = selector.value;
      var url = new URL(window.location.href);
      if (selector.value) url.searchParams.set('event_time_id', selector.value);
      else url.searchParams.delete('event_time_id');
      window.history.replaceState(window.history.state, '', url.toString());
    }
    selector.addEventListener('change', syncSelection);
    syncSelection();
  }

  function studentLabel(result) {
    var name = String(result.student_name || '').trim();
    return (name ? name + ' ' : 'Student ') + '(' + result.student_number + ')';
  }

  function showAppointmentDetailNotice() {
    var match = window.location.pathname.match(/^\/expo\/admin\/appointments\/(\d+)\/?$/);
    if (!match) return;
    var key = 'rfid_checkin_notice_appointment';
    var raw = sessionStorage.getItem(key);
    if (!raw) return;
    var result = JSON.parse(raw);
    if (String(result.appointment_id) !== match[1]) return;
    sessionStorage.removeItem(key);

    var content = document.getElementById('active_admin_content');
    if (!content) return;
    var notice = document.createElement('div');
    notice.id = 'rfid-lookup-notice';
    notice.className = 'flash flash_notice';
    notice.setAttribute('role', 'status');
    notice.textContent = result.status === 'already_checked_in'
      ? 'Appointment for ' + studentLabel(result) + ' already checked in.'
      : 'Appointment found for ' + studentLabel(result) + '. Review it and select Check in.';
    content.parentNode.insertBefore(notice, content);
  }

  function showSavedNotice() {
    var raw = sessionStorage.getItem(noticeKey());
    if (!raw) return;
    sessionStorage.removeItem(noticeKey());
    var result = JSON.parse(raw);
    var param = mode() === 'appointment' ? 'q[student_no_search_eq]' : 'q[student_number_eq]';
    if (new URLSearchParams(window.location.search).get(param) !== result.student_number) return;
    if (mode() === 'appointment' && (result.status === 'no_appointment' || result.status === 'multiple_appointments')) {
      if (new URLSearchParams(window.location.search).get('scope') === 'today') {
        showFlashAlert(result.status === 'no_appointment'
          ? 'No appointment scheduled for ' + studentLabel(result) + ' today. No check-in was made.'
          : 'Multiple appointments found for ' + studentLabel(result) + ' today. Choose one to check in.');
      }
      return;
    }
    var notice = document.createElement('div');
    notice.id = 'rfid-lookup-notice';
    notice.className = 'flash flash_notice';
    notice.setAttribute('role', 'status');
    notice.textContent = result.status === 'already_checked_in'
      ? studentLabel(result) + ' was already checked in.'
      : studentLabel(result) + ' successfully checked in.';
    var content = document.getElementById('active_admin_content');
    if (content) content.parentNode.insertBefore(notice, content);
  }

  function submitStudentNumber(studentNumber, result) {
    var input = document.querySelector(filterSelector());
    if (!input) return;
    var value = String(studentNumber);
    if (!STUDENT_NUMBER_PATTERN.test(value)) throw new Error('Card lookup returned an invalid student number.');
    if (mode() === 'appointment') {
      sessionStorage.setItem(noticeKey(), JSON.stringify({
        student_number: value, student_name: result.student_name,
        status: result.status, appointment_id: result.appointment_id
      }));
      if (result.status === 'appointment_found' || result.status === 'already_checked_in') {
        if (!/^\d+$/.test(String(result.appointment_id))) throw new Error('Card lookup returned an invalid appointment.');
        window.location.assign('/expo/admin/appointments/' + result.appointment_id);
        return;
      }
      if (result.status === 'no_appointment' || result.status === 'multiple_appointments') {
        var url = new URL('/expo/admin/appointments', window.location.origin);
        url.searchParams.set('q[student_no_search_eq]', value);
        url.searchParams.set('scope', 'today');
        window.location.assign(url.toString());
        return;
      }
      sessionStorage.removeItem(noticeKey());
      throw new Error('Card lookup returned an unexpected appointment status.');
    }
    input.value = value;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
    sessionStorage.setItem(noticeKey(), JSON.stringify({
      student_number: value, student_name: result.student_name,
      status: result.status, appointment_id: result.appointment_id
    }));
    var form = input.form;
    if (form.requestSubmit) form.requestSubmit();
    else {
      var submitButton = form.querySelector('[type="submit"]');
      if (submitButton) submitButton.click();
      else form.submit();
    }
  }

  function setFormValue(element, value) {
    element.value = String(value);
    element.dispatchEvent(new Event('input', { bubbles: true }));
    element.dispatchEvent(new Event('change', { bubbles: true }));
  }

  function prefillAppointment(data) {
    var number = String(data.student_number || '');
    var studentId = String(data.student_id || '');
    var form = document.querySelector('form#new_appointment');
    if (!form || !STUDENT_NUMBER_PATTERN.test(number) || !/^\d+$/.test(studentId)) {
      throw new Error('Card lookup returned an invalid student record.');
    }
    var numberInput = form.querySelector('.student-lookup .student-number-search');
    var studentInput = form.querySelector('#appointment_student_id');
    var startInput = form.querySelector('#appointment_start_time');
    var checkinInput = form.querySelector('#appointment_check_in_time');
    var contactInput = form.querySelector('#appointment_contact_type_id');
    if (!numberInput || !studentInput || !startInput || !checkinInput || !contactInput) {
      throw new Error('Could not find all appointment fields to fill.');
    }
    if (!Array.prototype.some.call(contactInput.options, function (option) {
      return option.value === String(data.contact_type_id);
    })) throw new Error('In-person contact type is not available in this form.');

    setFormValue(numberInput, number);
    setFormValue(studentInput, studentId);
    setFormValue(startInput, data.start_time);
    setFormValue(checkinInput, data.check_in_time);
    setFormValue(contactInput, data.contact_type_id);
    if (window.jQuery) window.jQuery(contactInput).trigger('chosen:updated').trigger('change.select2');
    showFlashNotice(studentLabel({ student_name: data.student_name, student_number: number }) +
      ' and appointment details filled. Review and save the form.');
  }

  function lookUpUid(uid) {
    var currentMode = mode();
    if (currentMode === 'event' && !eventId()) return Promise.reject(new Error('Open an event check-in page before scanning.'));
    showStatus(currentMode === 'appointment_new' ? 'Looking up student…' :
      currentMode === 'appointment' ? 'Looking up appointment…' : 'Checking in card…');
    var headers = { Accept: 'application/json', 'Content-Type': 'application/json' };
    var token = csrfToken();
    if (token) headers['X-CSRF-Token'] = token;
    var payload = { rfid_uid: uid };
    if (currentMode === 'event') {
      payload.event_id = eventId();
      payload.event_time_id = eventTimeId();
    }
    return fetch(lookupUrl(), {
      method: 'POST',
      credentials: 'same-origin',
      headers: headers,
      body: JSON.stringify(payload)
    }).then(function (response) {
      return response.json().then(function (data) {
        if (!response.ok) throw new Error(data.error || (currentMode === 'event' ? 'Unable to check in this card.' : 'Unable to look up this card.'));
        if (currentMode === 'appointment_new') {
          prefillAppointment(data);
        } else {
          showStatus(data.message);
          submitStudentNumber(data.student_number, data);
        }
      });
    });
  }

  function initializeRfidReader() {
    showAppointmentDetailNotice();
    var currentMode = mode();
    if (!currentMode) return;
    var input = document.querySelector(filterSelector());
    showSavedNotice();
    if (currentMode === 'event') initializeEventTimeSelector();
    document.addEventListener('keydown', function (event) {
      if (event.ctrlKey || event.altKey || event.metaKey || event.repeat) return;
      if (event.key === 'Shift') return;
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
      if (/^[0-9a-f]$/i.test(event.key)) buffer += event.key;
      else if (event.key === ' ' || event.key === 'Spacebar') buffer += ' ';
      else {
        buffer = '';
        return;
      }
      var normalized = buffer.replace(/\s+/g, '');
      if (UID_PATTERN.test(normalized) && !lookupPending) {
        event.preventDefault();
        event.stopImmediatePropagation();
        buffer = '';
        startLookup(normalized);
      } else if (normalized.length > 14) buffer = '';
    }, true);

    function startLookup(uid) {
      input.value = '';
      lookupPending = true;
      suppressSuffixUntil = Date.now() + 1000;
      var oldAlert = document.getElementById('rfid-lookup-alert');
      if (oldAlert) oldAlert.remove();
      lookUpUid(uid).catch(function (error) {
        console.error('[RFID] Lookup failed:', error);
        showFlashAlert(error.message);
      }).then(function () {
        lookupPending = false;
      });
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initializeRfidReader);
  else initializeRfidReader();
})();
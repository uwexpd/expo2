(() => {
  const FILTER_SELECTOR = 'form.filter_form input[name="q[student_number_eq]"]';
  const UID_PATTERN = /^[0-9a-f]{14}$/i;
  const SCAN_GAP_MS = 75;
  const NOTICE_KEY = 'event_invitee_rfid_lookup_notice';
  let buffer = '';
  let lastKeyAt = 0;

  function lookupUrl() {
    const path = window.location.pathname.replace(/\/$/, '');
    const nestedInvitees = path.match(/^(.*\/times\/\d+\/invitees)$/);

    return nestedInvitees
      ? `${nestedInvitees[1]}/lookup_rfid`
      : '/expo/admin/invitees/lookup_rfid';
  }

  function csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content;
  }

  function showStatus(message, isError = false) {
    let status = document.querySelector('#rfid-reader-status');
    if (!status) {
      status = document.createElement('span');
      status.id = 'rfid-reader-status';
      status.style.marginLeft = '8px';
      document.querySelector(FILTER_SELECTOR)?.closest('form')?.append(status);
    }
    status.textContent = message;
    status.style.color = isError ? '#b91c1c' : '#166534';
  }

  function showSavedNotice() {
    const studentNumber = sessionStorage.getItem(NOTICE_KEY);
    if (!studentNumber) return;
    sessionStorage.removeItem(NOTICE_KEY);

    const currentNumber = new URLSearchParams(window.location.search).get('q[student_number_eq]');
    if (currentNumber !== studentNumber) return;

    const notice = document.createElement('div');
    notice.id = 'rfid-lookup-notice';
    notice.className = 'flash flash_notice';
    notice.setAttribute('role', 'status');
    notice.textContent = `Found student with student number: ${studentNumber}. Student-number filter applied. Select Check in to check them in.`;    

    const content = document.querySelector('#active_admin_content');
    if (content) {
      content.before(notice);
    } else {
      document.querySelector('#wrapper')?.prepend(notice);
    }
  }

  function submitStudentNumber(studentNumber) {
    const input = document.querySelector(FILTER_SELECTOR);
    if (!input) return;

    const value = String(studentNumber);
    input.value = value;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
    sessionStorage.setItem(NOTICE_KEY, value);
    input.closest('form')?.requestSubmit();
  }

  async function lookUpUid(uid) {
    showStatus('Looking up card…');

    const response = await fetch(lookupUrl(), {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken()
      },
      body: JSON.stringify({ rfid_uid: uid })
    });

    const data = await response.json();
    if (!response.ok) throw new Error(data.error || 'Unable to look up this card.');

    showStatus('Student found. Applying filter…');
    submitStudentNumber(data.student_number);
  }

  function initializeRfidReader() {
    if (!document.querySelector(FILTER_SELECTOR)) return;

    showSavedNotice();
    console.info('[RFID] UID reader enabled on Event Invitee check-in.');
    document.addEventListener('keydown', (event) => {
      if (event.ctrlKey || event.altKey || event.metaKey) return;

      const now = Date.now();
      if (now - lastKeyAt > SCAN_GAP_MS) buffer = '';
      lastKeyAt = now;

      if (event.key === 'Enter') {
        if (!UID_PATTERN.test(buffer)) {
          buffer = '';
          return;
        }

        event.preventDefault();
        const uid = buffer;
        buffer = '';
        lookUpUid(uid).catch((error) => {
          console.error('[RFID] Lookup failed:', error);
          showStatus(error.message, true);
        });
        return;
      }

      if (/^[0-9a-f]$/i.test(event.key)) {
        buffer += event.key;
        return;
      }

      buffer = '';
    });
  }

  document.readyState === 'loading'
    ? document.addEventListener('DOMContentLoaded', initializeRfidReader)
    : initializeRfidReader();
})();
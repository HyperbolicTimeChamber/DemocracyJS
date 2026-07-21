(function() {
  'use strict';

  var state = {
    poll: null,
    selected: [],
    voted: false,
    wsConnected: false
  };

  var ws = null;
  var reconnectDelay = 1000;
  var maxReconnectDelay = 10000;

  // DOM helpers
  function $(id) { return document.getElementById(id); }

  function showScreen(name) {
    var screens = document.querySelectorAll('.screen');
    for (var i = 0; i < screens.length; i++) {
      screens[i].classList.remove('active');
    }
    $(name).classList.add('active');
  }

  function setConnectionStatus(status) {
    var dot = $('status-dot');
    var text = $('status-text');
    dot.className = status;
    text.textContent = status === 'connected' ? 'Connected' :
                       status === 'connecting' ? 'Connecting...' :
                       'Disconnected';
  }

  // API
  function fetchPoll() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/api/poll', true);
    xhr.onload = function() {
      if (xhr.status === 200) {
        state.poll = JSON.parse(xhr.responseText);
        renderVoting();
      } else {
        showError('Could not load poll.');
      }
    };
    xhr.onerror = function() {
      showError('Could not connect to server.');
    };
    xhr.send();
  }

  function submitVote() {
    if (state.selected.length === 0) return;

    var btn = $('submit-btn');
    btn.disabled = true;
    btn.textContent = 'Submitting...';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/api/vote', true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onload = function() {
      var res = JSON.parse(xhr.responseText);
      if (res.success) {
        state.voted = true;
        if (state.poll.resultsVisibility === 'afterVote' || state.poll.resultsVisibility === 'live') {
          fetchAndShowResults('results-after-vote');
          showScreen('submitted');
        } else {
          showScreen('waiting');
        }
      } else if (res.error === 'already_voted') {
        state.voted = true;
        fetchAndShowResults('results-after-vote');
        showScreen('submitted');
      } else {
        showError(res.error || 'Vote failed.');
      }
    };
    xhr.onerror = function() {
      btn.disabled = false;
      btn.textContent = 'Submit Vote';
      showError('Could not submit vote.');
    };
    xhr.send(JSON.stringify({ optionIds: state.selected }));
  }

  function fetchAndShowResults(containerId) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/api/results', true);
    xhr.onload = function() {
      if (xhr.status === 200) {
        var data = JSON.parse(xhr.responseText);
        renderResults(containerId, data);
      }
    };
    xhr.send();
  }

  // Rendering
  function renderVoting() {
    if (!state.poll) return;

    $('question').textContent = state.poll.question;
    var container = $('options');
    container.innerHTML = '';

    var isMulti = state.poll.voteMode === 'multipleChoice';

    for (var i = 0; i < state.poll.options.length; i++) {
      var opt = state.poll.options[i];
      var div = document.createElement('div');
      div.className = 'option-item' + (isMulti ? ' multi' : '');
      div.setAttribute('data-id', opt.id);
      div.innerHTML =
        '<div class="option-indicator"><div class="option-indicator-inner"></div></div>' +
        '<span class="option-text">' + escapeHtml(opt.text) + '</span>';

      div.addEventListener('click', (function(optId) {
        return function() { toggleOption(optId, isMulti); };
      })(opt.id));

      container.appendChild(div);
    }

    showScreen('voting');
  }

  function toggleOption(optId, isMulti) {
    if (isMulti) {
      var idx = state.selected.indexOf(optId);
      if (idx > -1) {
        state.selected.splice(idx, 1);
      } else {
        state.selected.push(optId);
      }
    } else {
      state.selected = [optId];
    }
    updateOptionUI();
  }

  function updateOptionUI() {
    var items = document.querySelectorAll('.option-item');
    for (var i = 0; i < items.length; i++) {
      var id = items[i].getAttribute('data-id');
      if (state.selected.indexOf(id) > -1) {
        items[i].classList.add('selected');
      } else {
        items[i].classList.remove('selected');
      }
    }
    $('submit-btn').disabled = state.selected.length === 0;
  }

  function renderResults(containerId, data) {
    var container = $(containerId);
    if (!container) return;
    container.innerHTML = '';

    for (var i = 0; i < data.options.length; i++) {
      var opt = data.options[i];
      var pct = data.totalVotes > 0 ? Math.round((opt.voteCount / data.totalVotes) * 100) : 0;
      var div = document.createElement('div');
      div.className = 'result-item';
      div.innerHTML =
        '<div class="result-header">' +
          '<span class="result-text">' + escapeHtml(opt.text) + '</span>' +
          '<span class="result-count">' + opt.voteCount + '</span>' +
          '<span class="result-percent">' + pct + '%</span>' +
        '</div>' +
        '<div class="result-bar-bg">' +
          '<div class="result-bar-fill" style="width:' + pct + '%"></div>' +
        '</div>';
      container.appendChild(div);
    }

    // Total votes display
    var totalEl = containerId === 'final-results' ? $('final-total') : $('total-votes');
    if (totalEl) {
      totalEl.textContent = data.totalVotes + ' total votes';
    }
  }

  function showError(msg) {
    $('error-message').textContent = msg;
    showScreen('error');
  }

  function escapeHtml(str) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  // WebSocket
  function connectWs() {
    var protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
    var url = protocol + '//' + location.host + '/ws';

    setConnectionStatus('connecting');

    try {
      ws = new WebSocket(url);
    } catch (e) {
      setConnectionStatus('error');
      scheduleReconnect();
      return;
    }

    ws.onopen = function() {
      state.wsConnected = true;
      reconnectDelay = 1000;
      setConnectionStatus('connected');
    };

    ws.onmessage = function(event) {
      try {
        var msg = JSON.parse(event.data);
        handleWsMessage(msg);
      } catch (e) {}
    };

    ws.onclose = function() {
      state.wsConnected = false;
      setConnectionStatus('error');
      scheduleReconnect();
    };

    ws.onerror = function() {
      state.wsConnected = false;
      setConnectionStatus('error');
    };
  }

  function scheduleReconnect() {
    setTimeout(function() {
      connectWs();
    }, reconnectDelay);
    reconnectDelay = Math.min(reconnectDelay * 2, maxReconnectDelay);
  }

  function handleWsMessage(msg) {
    switch (msg.type) {
      case 'results_updated':
        if (state.voted) {
          renderResults('results-after-vote', msg.data);
        }
        break;
      case 'poll_ended':
        fetchAndShowResults('final-results');
        showScreen('ended');
        break;
      case 'vote_submitted':
        // Update total votes if showing results
        break;
    }
  }

  // Submit button
  $('submit-btn').addEventListener('click', submitVote);

  // Init
  fetchPoll();
  connectWs();
})();

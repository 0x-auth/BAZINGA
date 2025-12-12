/**
 * BAZINGA Web App - Universal Script Runner
 *
 * This component integrates the BAZINGA Web App with mathematical visualizations
 * and provides a universal script runner that doesn't require sudo access.
 * Everything runs locally with no internet communication.
 */

// WebSocket connection for real-time communication
let scriptSocket = null;

/**
 * Universal Script Runner with mathematical enhancements
 */
const universalScriptRunner = {
  /**
   * Initialize the script runner
   */
  init: function() {
    console.log('Initializing Universal Script Runner...');
    this.connectWebSocket();
    this.setupEventListeners();
    this.setupMathVisualizations();
    this.setupHashMonitoring();
  },

  /**
   * Connect to the WebSocket server
   */
  connectWebSocket: function() {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}`;

    scriptSocket = new WebSocket(wsUrl);
    window.scriptSocket = scriptSocket;

    // Connection opened
    scriptSocket.addEventListener('open', (event) => {
      console.log('Connected to BAZINGA server');
      this.updateConnectionStatus(true);
    });

    // Listen for messages
    scriptSocket.addEventListener('message', (event) => {
      try {
        const message = JSON.parse(event.data);
        this.handleWebSocketMessage(message);
      } catch (error) {
        console.error('Error parsing WebSocket message:', error);
      }
    });

    // Connection closed
    scriptSocket.addEventListener('close', (event) => {
      console.log('Disconnected from BAZINGA server');
      this.updateConnectionStatus(false);

      // Try to reconnect after 5 seconds
      setTimeout(() => {
        this.connectWebSocket();
      }, 5000);
    });

    // Connection error
    scriptSocket.addEventListener('error', (event) => {
      console.error('WebSocket error:', event);
      this.updateConnectionStatus(false);
    });
  },

  /**
   * Update the connection status indicator
   */
  updateConnectionStatus: function(isConnected) {
    const statusElement = document.getElementById('websocket-status');
    if (statusElement) {
      statusElement.className = isConnected ?
        'w-3 h-3 rounded-full bg-green-500 mr-2' :
        'w-3 h-3 rounded-full bg-red-500 mr-2';
    }
  },

  /**
   * Handle WebSocket messages
   */
  handleWebSocketMessage: function(message) {
    const type = message.type || '';
    const data = message.data || {};

    switch (type) {
      case 'connected':
        console.log('WebSocket connection established');
        break;

      case 'script-start':
        this.handleScriptStart(data);
        break;

      case 'script-output':
        this.handleScriptOutput(data);
        break;

      case 'script-end':
        this.handleScriptEnd(data);
        break;

      case 'script-error':
        this.handleScriptError(data);
        break;

      case 'hash-analysis':
        this.handleHashAnalysis(data);
        break;

      case 'hash-error':
        console.error('Hash analysis error:', data.message);
        break;

      case 'hash-monitoring-started':
        this.handleHashMonitoringStarted(data);
        break;

      case 'hash-monitoring-stopped':
        this.handleHashMonitoringStopped(data);
        break;

      default:
        console.log('Received unknown message type:', type);
    }
  },

  /**
   * Set up event listeners
   */
  setupEventListeners: function() {
    // Run button click handler
    document.addEventListener('click', (e) => {
      if (e.target && (e.target.id === 'run-script-btn' || e.target.closest('#run-script-btn'))) {
        this.handleRunScript();
      }

      // Script category selection
      if (e.target && e.target.classList.contains('script-category-btn')) {
        const category = e.target.getAttribute('data-category');
        this.filterScriptsByCategory(category);

        // Update the active category button
        document.querySelectorAll('.script-category-btn').forEach(btn => {
          if (btn === e.target) {
            btn.classList.remove('bg-gray-200', 'text-gray-700');
            btn.classList.add('bg-indigo-600', 'text-white');
          } else {
            btn.classList.remove('bg-indigo-600', 'text-white');
            btn.classList.add('bg-gray-200', 'text-gray-700');
          }
        });
      }

      // Hash monitoring buttons
      if (e.target && e.target.id === 'start-hash-monitoring') {
        this.startHashMonitoring();
      }

      if (e.target && e.target.id === 'stop-hash-monitoring') {
        this.stopHashMonitoring();
      }
    });

    // Script search functionality
    const searchInput = document.getElementById('script-search-input');
    if (searchInput) {
      searchInput.addEventListener('input', (e) => {
        this.filterScriptsBySearch(e.target.value);
      });
    }

    // Global search functionality
    const globalSearch = document.getElementById('global-search');
    if (globalSearch) {
      globalSearch.addEventListener('input', (e) => {
        const searchTerm = e.target.value.toLowerCase();
        if (searchTerm.length >= 2) {
          this.performGlobalSearch(searchTerm);
        }
      });
    }
  },

  /**
   * Handle running a script
   */
  handleRunScript: function() {
    const scriptNameElement = document.getElementById('script-detail-name');
    const scriptPathElement = document.getElementById('script-detail-path');

    if (!scriptNameElement || !scriptPathElement) {
      console.error('Script details elements not found');
      return;
    }

    const scriptName = scriptNameElement.textContent;
    const scriptPath = scriptPathElement.textContent;
    const paramsInput = document.getElementById('script-params');
    const params = paramsInput ? paramsInput.value : '';

    // Get selected function if any
    let selectedFunction = '';
    const functionSelect = document.getElementById('script-function-select');
    if (functionSelect && functionSelect.value) {
      selectedFunction = functionSelect.value;
    }

    // Show terminal and clear previous output
    const terminal = document.getElementById('script-terminal');
    if (terminal) {
      terminal.classList.remove('hidden');
      const outputElement = terminal.querySelector('.terminal-output');
      if (outputElement) {
        outputElement.innerHTML = `<span class = "text-yellow-400">$</span> <span class = "text-blue-400">${scriptPath}</span> ${selectedFunction ? `<span class = "text-green-400">${selectedFunction}</span>` : ''} ${params}\n\n`;
      }
    }

    // Prepare the parameter data
    const scriptData = {
      path: scriptPath,
      params: params,
      function: selectedFunction
    };

    // Execute via WebSocket if available, otherwise fallback to fetch API
    if (scriptSocket && scriptSocket.readyState === WebSocket.OPEN) {
      scriptSocket.send(JSON.stringify({
        type: 'run-script',
        data: scriptData
      }));
    } else {
      this.executeScriptViaFetch(scriptData);
    }

    // Add to history immediately with pending status
    this.addToScriptHistory({
      timestamp: new Date().toISOString(),
      name: scriptName,
      path: scriptPath,
      command: `${scriptPath} ${selectedFunction} ${params}`.trim(),
      status: 'pending'
    });

    // If this is a mathematical script, animate the math visualization
    if (scriptName.includes('hash') || scriptPath.includes('hash') ||
        params.includes('hash') || selectedFunction.includes('hash')) {
      this.showHashVisualization();
    }
  },

  /**
   * Execute script via fetch API (fallback when WebSocket isn't available)
   */
  executeScriptViaFetch: function(scriptData) {
    fetch('/api/script-run', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(scriptData)
    })
    .then(response => response.json())
    .then(data => {
      // Update terminal with output
      const terminal = document.getElementById('script-terminal');
      if (terminal) {
        const outputElement = terminal.querySelector('.terminal-output');
        if (outputElement) {
          if (data.stdout) {
            outputElement.innerHTML += `<span class = "text-green-400">${data.stdout.replace(/\n/g, '<br>')}</span>\n`;
          }

          if (data.stderr) {
            outputElement.innerHTML += `<span class = "text-red-400">${data.stderr.replace(/\n/g, '<br>')}</span>\n`;
          }

          outputElement.innerHTML += `\n<span class = "text-gray-400">Exit code: ${data.exitCode}</span>\n`;

          // Scroll to bottom
          outputElement.scrollTop = outputElement.scrollHeight;
        }
      }

      // Update script history
      this.updateScriptHistoryStatus(data.command, data.exitCode === 0 ? 'success' : 'error');
    })
    .catch(error => {
      console.error('Error executing script:', error);
      const terminal = document.getElementById('script-terminal');
      if (terminal) {
        const outputElement = terminal.querySelector('.terminal-output');
        if (outputElement) {
          outputElement.innerHTML += `<span class = "text-red-400">Error: ${error.message}</span>\n`;
        }
      }

      // Update script history with error
      this.updateScriptHistoryStatus(scriptData.path, 'error');
    });
  },

  /**
   * Handle script start event
   */
  handleScriptStart: function(data) {
    console.log('Script started:', data);
  },

  /**
   * Handle script output event
   */
  handleScriptOutput: function(data) {
    const terminal = document.getElementById('script-terminal');
    if (!terminal) return;

    const outputElement = terminal.querySelector('.terminal-output');
    if (!outputElement) return;

    // Append output with appropriate color
    if (data.isError) {
      outputElement.innerHTML += `<span class = "text-red-400">${data.output.replace(/\n/g, '<br>')}</span>`;
    } else {
      outputElement.innerHTML += `<span class = "text-green-400">${data.output.replace(/\n/g, '<br>')}</span>`;
    }

    // Scroll to bottom
    outputElement.scrollTop = outputElement.scrollHeight;
  },

  /**
   * Handle script end event
   */
  handleScriptEnd: function(data) {
    const terminal = document.getElementById('script-terminal');
    if (!terminal) return;

    const outputElement = terminal.querySelector('.terminal-output');
    if (!outputElement) return;

    // Add exit code
    outputElement.innerHTML += `\n<span class = "text-gray-400">Exit code: ${data.exitCode}</span>\n`;

    // Scroll to bottom
    outputElement.scrollTop = outputElement.scrollHeight;

    // Update script history
    this.updateScriptHistoryStatus(data.command, data.success ? 'success' : 'error');
  },

  /**
   * Handle script error event
   */
  handleScriptError: function(data) {
    const terminal = document.getElementById('script-terminal');
    if (!terminal) return;

    const outputElement = terminal.querySelector('.terminal-output');
    if (!outputElement) return;

    // Show error
    outputElement.innerHTML += `<span class = "text-red-500">ERROR: ${data.message}</span>\n`;
    if (data.details) {
      outputElement.innerHTML += `<span class = "text-red-400">${data.details}</span>\n`;
    }

    // Scroll to bottom
    outputElement.scrollTop = outputElement.scrollHeight;
  },

  /**
   * Filter scripts by category
   */
  filterScriptsByCategory: function(category) {
    if (!category) return;

    const scriptItems = document.querySelectorAll('.script-item');
    scriptItems.forEach(item => {
      const itemCategory = item.getAttribute('data-category');
      if (category === 'all' || itemCategory === category) {
        item.classList.remove('hidden');
      } else {
        item.classList.add('hidden');
      }
    });
  },

  /**
   * Filter scripts by search term
   */
  filterScriptsBySearch: function(searchTerm) {
    if (!searchTerm) {
      // If search is cleared, show all scripts based on active category
      const activeCategory = document.querySelector('.script-category-btn.bg-indigo-600')?.getAttribute('data-category') || 'all';
      this.filterScriptsByCategory(activeCategory);
      return;
    }

    const lowerSearchTerm = searchTerm.toLowerCase();
    const scriptItems = document.querySelectorAll('.script-item');

    scriptItems.forEach(item => {
      const scriptName = item.querySelector('.script-name')?.textContent.toLowerCase() || '';
      const scriptDesc = item.querySelector('.script-description')?.textContent.toLowerCase() || '';
      const scriptPath = item.querySelector('.text-xs')?.textContent.toLowerCase() || '';

      if (scriptName.includes(lowerSearchTerm) ||
          scriptDesc.includes(lowerSearchTerm) ||
          scriptPath.includes(lowerSearchTerm)) {
        item.classList.remove('hidden');
      } else {
        item.classList.add('hidden');
      }
    });
  },

  /**
   * Perform global search across scripts and artifacts
   */
  performGlobalSearch: function(searchTerm) {
    // TODO: Implement global search functionality
    console.log('Global search for:', searchTerm);

    // This would typically involve a server request to search across all scripts and artifacts
    // For now, we'll just make the Dashboard tab active and search scripts
    document.querySelector('.nav-link[data-target = "scripts"]')?.click();

    // Set the script search input value
    const scriptSearchInput = document.getElementById('script-search-input');
    if (scriptSearchInput) {
      scriptSearchInput.value = searchTerm;
      this.filterScriptsBySearch(searchTerm);
    }
  },

  /**
   * Add a script execution to the history
   */
  addToScriptHistory: function(historyItem) {
    const historyContainer = document.getElementById('script-history');
    if (!historyContainer) return;

    // Create history item element
    const historyElement = document.createElement('div');
    historyElement.className = 'p-3 rounded bg-gray-50 flex justify-between items-center';
    historyElement.setAttribute('data-command', historyItem.command);

    // Status indicator
    let statusClass = 'bg-yellow-500'; // Default: pending
    if (historyItem.status === 'success') {
      statusClass = 'bg-green-500';
    } else if (historyItem.status === 'error') {
      statusClass = 'bg-red-500';
    }

    // Format timestamp
    const timestamp = new Date(historyItem.timestamp);
    const formattedTime = timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

    historyElement.innerHTML = `
      <div class = "flex items-center">
        <div class = "w-3 h-3 rounded-full ${statusClass} mr-2"></div>
        <div>
          <div class = "font-medium">${historyItem.name}</div>
          <div class = "text-xs text-gray-500">${historyItem.command}</div>
        </div>
      </div>
      <div class = "text-sm text-gray-500">${formattedTime}</div>
    `;

    // Add to history
    historyContainer.prepend(historyElement);

    // Limit history to 10 items
    const historyItems = historyContainer.children;
    if (historyItems.length > 10) {
      historyContainer.removeChild(historyItems[historyItems.length - 1]);
    }
  },

  /**
   * Update the status of a script in the history
   */
  updateScriptHistoryStatus: function(command, status) {
    const historyContainer = document.getElementById('script-history');
    if (!historyContainer) return;

    // Find the history item by command
    const historyItem = Array.from(historyContainer.children).find(item => {
      return item.getAttribute('data-command') === command;
    });

    if (historyItem) {
      // Update status indicator
      const statusIndicator = historyItem.querySelector('.w-3.h-3.rounded-full');
      if (statusIndicator) {
        statusIndicator.className = 'w-3 h-3 rounded-full';
        statusIndicator.classList.add(status === 'success' ? 'bg-green-500' : 'bg-red-500');
      }
    } else {
      // If not found, add a new history item
      this.addToScriptHistory({
        timestamp: new Date().toISOString(),
        name: command.split('/').pop(),
        command: command,
        status: status
      });
    }
  },

  /**
   * Set up mathematical visualizations
   */
  setupMathVisualizations: function() {
    // Setup the hash visualization container
    const hashVizContainer = document.getElementById('hash-visualization');
    if (hashVizContainer) {
      // We'll populate this when needed
      hashVizContainer.innerHTML = this.getHashVisualizationHTML();
    }

    // Setup the math visualizations container for the Math section
    const mathContainer = document.getElementById('math-visualizations-container');
    if (mathContainer) {
      mathContainer.innerHTML = this.getMathVisualizationHTML();
    }
  },

  /**
   * Show hash visualization in the dashboard
   */
  showHashVisualization: function() {
    const hashVizContainer = document.getElementById('hash-visualization');
    if (!hashVizContainer) return;

    // Make sure it's visible
    hashVizContainer.classList.remove('hidden');

    // Start the animation
    this.animateHashViz();
  },

  /**
   * Generate the HTML for the hash visualization
   */
  getHashVisualizationHTML: function() {
    return `
      <div class = "bg-white rounded-lg shadow p-4">
        <h3 class = "text-lg font-semibold mb-3">Hash State Visualization</h3>
        <div class = "hash-viz-container h-40 border border-gray-200 rounded p-2 overflow-hidden">
          <canvas id = "hash-viz-canvas" class = "w-full h-full"></canvas>
        </div>
        <div class = "mt-2 text-sm text-gray-600">
          Visualizing the mathematical patterns of script modification probabilities
        </div>
      </div>
    `;
  },

  /**
   * Generate the HTML for the math visualization
   */
  getMathVisualizationHTML: function() {
    return `
      <div class = "grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class = "bg-white rounded-lg shadow p-4">
          <h3 class = "text-lg font-semibold mb-3">Hash Probability Mapping</h3>
          <div class = "hash-mapping-container h-64 border border-gray-200 rounded p-2 overflow-hidden">
            <canvas id = "hash-mapping-canvas" class = "w-full h-full"></canvas>
          </div>
          <div class = "mt-2 text-sm text-gray-600">
            Hash-based scripts use mathematical transformations to map problems to solutions
          </div>
        </div>

        <div class = "bg-white rounded-lg shadow p-4">
          <h3 class = "text-lg font-semibold mb-3">Möbius Transformation</h3>
          <div class = "mobius-container h-64 border border-gray-200 rounded p-2 overflow-hidden">
            <canvas id = "mobius-canvas" class = "w-full h-full"></canvas>
          </div>
          <div class = "mt-2 text-sm text-gray-600">
            <p>Möbius Transform: w = (az + b)/(cz + d)</p>
            <p>The solution exists precisely because of the apparent impossibility, not despite it.</p>
          </div>
        </div>
      </div>

      <div class = "mt-4 bg-white rounded-lg shadow p-4">
        <h3 class = "text-lg font-semibold mb-3">Mathematical Description</h3>
        <div class = "mb-4">
          <p>The BAZINGA system uses complex mathematical transformations to map problems into solvable spaces.
          Hash-based analytics operate like a Möbius transformation - they transform seemingly impossible problems
          into elegant solutions.</p>
        </div>
        <div class = "p-4 bg-gray-100 rounded text-sm">
          <p><strong>The Magic of Hashing</strong>: A hash function maps arbitrary data to fixed-size values.
          In mathematical terms, this is a projection from a high-dimensional space to a lower-dimensional one.
          When applied through probabilistic analysis and Bayesian inference, this enables us to predict and
          detect system changes with remarkable accuracy.</p>
        </div>
      </div>
    `;
  },

  /**
   * Animate the hash visualization
   */
  animateHashViz: function() {
    const canvas = document.getElementById('hash-viz-canvas');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const width = canvas.clientWidth;
    const height = canvas.clientHeight;

    // Set canvas dimensions to match display size
    canvas.width = width;
    canvas.height = height;

    // Clear canvas
    ctx.clearRect(0, 0, width, height);

    // Number of particles
    const particleCount = 30;
    const particles = [];

    // Create particles
    for (let i = 0; i < particleCount; i++) {
      particles.push({
        x: Math.random() * width,
        y: Math.random() * height,
        radius: Math.random() * 3 + 1,
        color: `rgba(79, 70, 229, ${Math.random() * 0.5 + 0.25})`,
        vx: Math.random() * 2 - 1,
        vy: Math.random() * 2 - 1
      });
    }

    // Animation variables
    let animationId;
    let frameCount = 0;

    // Animate function
    function animate() {
      frameCount++;

      // Clear canvas
      ctx.clearRect(0, 0, width, height);

      // Draw connections
      ctx.beginPath();
      for (let i = 0; i < particles.length; i++) {
        const p1 = particles[i];
        for (let j = i + 1; j < particles.length; j++) {
          const p2 = particles[j];
          const dx = p1.x - p2.x;
          const dy = p1.y - p2.y;
          const distance = Math.sqrt(dx * dx + dy * dy);

          if (distance < 100) {
            ctx.beginPath();
            ctx.strokeStyle = `rgba(79, 70, 229, ${0.2 * (1 - distance / 100)})`;
            ctx.lineWidth = 1;
            ctx.moveTo(p1.x, p1.y);
            ctx.lineTo(p2.x, p2.y);
            ctx.stroke();
          }
        }
      }

      // Update and draw particles
      for (const p of particles) {
        p.x += p.vx;
        p.y += p.vy;

        // Bounce off edges
        if (p.x < 0 || p.x > width) p.vx *= -1;
        if (p.y < 0 || p.y > height) p.vy *= -1;

        // Draw particle
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
        ctx.fillStyle = p.color;
        ctx.fill();
      }

      // Add a pulsing central hash
      const centerX = width / 2;
      const centerY = height / 2;
      const pulseFactor = 1 + 0.2 * Math.sin(frameCount / 20);

      ctx.beginPath();
      ctx.arc(centerX, centerY, 15 * pulseFactor, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(79, 70, 229, ${0.3 + 0.2 * Math.sin(frameCount / 15)})`;
      ctx.fill();

      ctx.font = `${12 * pulseFactor}px monospace`;
      ctx.fillStyle = 'white';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('HASH', centerX, centerY);

      // Continue animation
      animationId = requestAnimationFrame(animate);

      // Stop after 5 seconds if not in the Math tab
      if (frameCount > 300 && !document.querySelector('.section#math').classList.contains('active')) {
        cancelAnimationFrame(animationId);
      }
    }

    // Start animation
    animate();
  },

  /**
   * Set up hash monitoring functionality
   */
  setupHashMonitoring: function() {
    // Initial setup for monitoring UI
    const monitoringResults = document.getElementById('system-monitoring-results');
    if (monitoringResults) {
      monitoringResults.innerHTML = `
        <h3 class = "text-lg font-semibold mb-3">Monitoring Results</h3>
        <div class = "p-4 text-center text-gray-500" id = "monitoring-placeholder">
          Start monitoring to see real-time system analysis
        </div>
        <div id = "monitoring-active-content" class = "hidden">
          <div class = "mb-4">
            <div class = "flex justify-between items-center mb-2">
              <span class = "font-medium">System Hash:</span>
              <span id = "system-hash" class = "font-mono bg-gray-100 px-2 py-1 rounded text-sm"></span>
            </div>
            <div class = "flex justify-between items-center mb-2">
              <span class = "font-medium">Last Change:</span>
              <span id = "last-change-time" class = "text-sm"></span>
            </div>
            <div class = "flex justify-between items-center">
              <span class = "font-medium">Monitoring Status:</span>
              <span id = "monitoring-status" class = "text-sm text-green-600">Active</span>
            </div>
          </div>

          <div class = "mb-4">
            <h4 class = "font-medium mb-2">Changed Zones</h4>
            <div id = "changed-zones" class = "space-y-2"></div>
          </div>

          <div>
            <h4 class = "font-medium mb-2">Top Changed Files</h4>
            <div id = "changed-files" class = "space-y-2"></div>
          </div>

          <div class = "mt-4 p-3 bg-gray-100 rounded-lg">
            <h4 class = "font-medium mb-1">Möbius Transformation</h4>
            <div id = "mobius-transform-params" class = "text-sm">
              w = (az + b)/(cz+d)
            </div>
          </div>
        </div>
      `;
    }
  },

  /**
   * Start hash monitoring
   */
  startHashMonitoring: function() {
    if (!scriptSocket || scriptSocket.readyState !== WebSocket.OPEN) {
      console.error('WebSocket not connected, cannot start monitoring');
      return;
    }

    // Send message to start monitoring
    scriptSocket.send(JSON.stringify({
      type: 'start-hash-monitoring',
      data: {
        interval: 60000 // 1 minute interval
      }
    }));

    // Update UI
    document.getElementById('monitoring-placeholder')?.classList.add('hidden');
    document.getElementById('monitoring-active-content')?.classList.remove('hidden');
    document.getElementById('monitoring-status').textContent = 'Starting...';

    // Enable visualizations in the Math tab
    this.enableMathVisualizations();
  },

  /**
   * Stop hash monitoring
   */
  stopHashMonitoring: function() {
    if (!scriptSocket || scriptSocket.readyState !== WebSocket.OPEN) {
      console.error('WebSocket not connected, cannot stop monitoring');
      return;
    }

    // Send message to stop monitoring
    scriptSocket.send(JSON.stringify({
      type: 'stop-hash-monitoring'
    }));

    // Update UI
    document.getElementById('monitoring-placeholder')?.classList.remove('hidden');
    document.getElementById('monitoring-active-content')?.classList.add('hidden');
  },

  /**
   * Handle hash monitoring started event
   */
  handleHashMonitoringStarted: function(data) {
    console.log('Hash monitoring started:', data);

    // Update UI
    document.getElementById('monitoring-status').textContent = 'Active';
    document.getElementById('monitoring-status').className = 'text-sm text-green-600';

    // Show message
    this.showNotification('Hash monitoring started', 'Monitoring system changes at ' + (data.interval / 1000) + ' second intervals');
  },

  /**
   * Handle hash monitoring stopped event
   */
  handleHashMonitoringStopped: function(data) {
    console.log('Hash monitoring stopped:', data);

    // Show message
    this.showNotification('Hash monitoring stopped', 'System hash monitoring has been deactivated');
  },

  /**
   * Handle hash analysis data
   */
  handleHashAnalysis: function(data) {
    console.log('Received hash analysis:', data);

    // Update UI with analysis results
    document.getElementById('system-hash').textContent = data.currentState.overallHash.substring(0, 10) + '...';
    document.getElementById('last-change-time').textContent = new Date(data.timestamp).toLocaleString();

    // Update changed zones
    const changedZonesContainer = document.getElementById('changed-zones');
    if (changedZonesContainer && data.comparison.changedZones) {
      changedZonesContainer.innerHTML = '';

      if (data.comparison.changedZones.length === 0) {
        changedZonesContainer.innerHTML = '<div class = "text-sm text-gray-500">No changed zones detected</div>';
      } else {
        data.comparison.changedZones.slice(0, 3).forEach(zone => {
          const zoneName = zone.split('/').slice(-2).join('/');
          const zoneItem = document.createElement('div');
          zoneItem.className = 'p-2 bg-indigo-50 rounded text-sm';
          zoneItem.textContent = zoneName;
          changedZonesContainer.appendChild(zoneItem);
        });
      }
    }

    // Update changed files
    const changedFilesContainer = document.getElementById('changed-files');
    if (changedFilesContainer && data.comparison.topChangedFiles) {
      changedFilesContainer.innerHTML = '';

      if (data.comparison.topChangedFiles.length === 0) {
        changedFilesContainer.innerHTML = '<div class = "text-sm text-gray-500">No changed files detected</div>';
      } else {
        data.comparison.topChangedFiles.forEach(file => {
          const fileName = file.path.split('/').pop();
          const probability = Math.round(file.probability * 100);

          const fileItem = document.createElement('div');
          fileItem.className = 'p-2 bg-gray-50 rounded flex justify-between items-center';
          fileItem.innerHTML = `
            <span class = "text-sm">${fileName}</span>
            <span class = "text-xs px-2 py-1 bg-indigo-100 rounded-full">${probability}%</span>
          `;
          changedFilesContainer.appendChild(fileItem);
        });
      }
    }

    // Update Möbius transformation parameters
    if (data.mobiusTransformation) {
      const mobiusParamsElement = document.getElementById('mobius-transform-params');
      if (mobiusParamsElement) {
        const params = data.mobiusTransformation.parameters;
        mobiusParamsElement.innerHTML = `
          <div class = "font-mono">w = (${params.a}z + ${params.b}) / (${params.c}z + ${params.d})</div>
          <div class = "text-xs mt-1">${data.mobiusTransformation.metaDescription}</div>
        `;
      }
    }

    // Update math visualizations if on math tab
    if (document.querySelector('.section#math').classList.contains('active')) {
      this.updateMathVisualizations(data);
    }
  },

  /**
   * Update math visualizations with new data
   */
  updateMathVisualizations: function(data) {
    // Update the hash mapping visualization
    this.drawHashMapping(data);

    // Update the Möbius transformation visualization
    this.drawMobiusTransformation(data);
  },

  /**
   * Draw hash mapping visualization
   */
  drawHashMapping: function(data) {
    const canvas = document.getElementById('hash-mapping-canvas');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const width = canvas.clientWidth;
    const height = canvas.clientHeight;

    // Set canvas dimensions
    canvas.width = width;
    canvas.height = height;

    // Clear canvas
    ctx.clearRect(0, 0, width, height);

    // Draw a simple visual representation
    ctx.fillStyle = 'rgba(79, 70, 229, 0.1)';
    ctx.fillRect(0, 0, width, height);

    // Draw grid
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
    ctx.lineWidth = 1;
    for (let i = 0; i < width; i += 20) {
      ctx.beginPath();
      ctx.moveTo(i, 0);
      ctx.lineTo(i, height);
      ctx.stroke();
    }
    for (let i = 0; i < height; i += 20) {
      ctx.beginPath();
      ctx.moveTo(0, i);
      ctx.lineTo(width, i);
      ctx.stroke();
    }

    // Only continue if we have file change data
    if (!data.comparison || !data.comparison.changeProbabilities) return;

    // Draw file changes as points
    const files = Object.entries(data.comparison.changeProbabilities).slice(0, 20);

    files.forEach(([path, info], index) => {
      const x = (index / files.length) * width;
      const y = (1 - info.probability) * height;

      // Draw point
      ctx.beginPath();
      ctx.arc(x, y, 5, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(79, 70, 229, ${0.5 + 0.5 * info.probability})`;
      ctx.fill();

      // Draw label for high probability files
      if (info.probability > 0.6) {
        const fileName = path.split('/').pop();
        ctx.font = '10px sans-serif';
        ctx.fillStyle = 'white';
        ctx.textAlign = 'center';
        ctx.fillText(fileName, x, y - 10);
      }
    });
  },

  /**
   * Draw Möbius transformation visualization
   */
  drawMobiusTransformation: function(data) {
    const canvas = document.getElementById('mobius-canvas');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const width = canvas.clientWidth;
    const height = canvas.clientHeight;

    // Set canvas dimensions
    canvas.width = width;
    canvas.height = height;

    // Animation variables
    let animationId;
    let frameCount = 0;

    // Extract Möbius parameters or use defaults
    let a = 1, b = 0, c = 0, d = 1;
    if (data && data.mobiusTransformation && data.mobiusTransformation.parameters) {
      a = data.mobiusTransformation.parameters.a;
      b = data.mobiusTransformation.parameters.b;
      c = data.mobiusTransformation.parameters.c;
      d = data.mobiusTransformation.parameters.d;
    }

    // Points to transform
    const initialPoints = [];
    for (let i = 0; i < 500; i++) {
      const angle = (i / 500) * Math.PI * 2;
      initialPoints.push({
        x: Math.cos(angle) * 0.5,
        y: Math.sin(angle) * 0.5
      });
    }

    // Animate function
    function animate() {
      frameCount++;

      // Clear canvas
      ctx.fillStyle = 'rgba(0, 0, 0, 0.95)';
      ctx.fillRect(0, 0, width, height);

      // Draw coordinate axes
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(0, height / 2);
      ctx.lineTo(width, height / 2);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(width / 2, 0);
      ctx.lineTo(width / 2, height);
      ctx.stroke();

      // Animation parameters
      const t = (Math.sin(frameCount / 100) + 1) / 2; // Oscillate between 0 and 1

      // Interpolate Möbius parameters
      const currentC = c * t;

      // Draw points
      ctx.fillStyle = 'rgba(79, 70, 229, 0.8)';

      initialPoints.forEach(p => {
        // Apply Möbius transformation: w = (az + b) / (cz + d)
        // Using complex coordinates: z = x + iy
        let x = p.x;
        let y = p.y;

        // Complex multiplication and division
        const numeratorReal = a * x - b * y;
        const numeratorImag = a * y + b * x;
        const denominatorReal = currentC * x + d;
        const denominatorImag = currentC * y;
        const denominator = denominatorReal * denominatorReal + denominatorImag * denominatorImag;

        // Avoid division by zero
        if (Math.abs(denominator) > 0.001) {
          const transformedX = (numeratorReal * denominatorReal + numeratorImag * denominatorImag) / denominator;
          const transformedY = (numeratorImag * denominatorReal - numeratorReal * denominatorImag) / denominator;

          // Map to canvas coordinates
          const canvasX = width / 2 + transformedX * (width / 3);
          const canvasY = height / 2 - transformedY * (height / 3);

          // Draw point
          ctx.beginPath();
          ctx.arc(canvasX, canvasY, 1.5, 0, Math.PI * 2);
          ctx.fill();
        }
      });

      // Draw formula
      ctx.font = '14px monospace';
      ctx.fillStyle = 'white';
      ctx.textAlign = 'center';
      ctx.fillText(`w = (${a}z + ${b}) / (${currentC.toFixed(2)}z + ${d})`, width / 2, 20);

      // Continue animation
      animationId = requestAnimationFrame(animate);
    }

    // Cancel any existing animation
    if (window.mobiusAnimationId) {
      cancelAnimationFrame(window.mobiusAnimationId);
    }

    // Start animation and store ID
    animate();
    window.mobiusAnimationId = animationId;
  },

  /**
   * Enable mathematical visualizations
   */
  enableMathVisualizations: function() {
    // Enabled the visualizations in the Math tab
    const mathContainer = document.getElementById('math-visualizations-container');
    if (mathContainer) {
      // Create the Möbius transformation visualization
      setTimeout(() => {
        this.drawMobiusTransformation({
          mobiusTransformation: {
            parameters: { a: 1, b: 0, c: 0, d: 1 }
          }
        });

        // Create the hash mapping visualization
        this.drawHashMapping({});
      }, 100);
    }
  },

  /**
   * Show a notification message
   */
  showNotification: function(title, message) {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'fixed top-4 right-4 bg-white shadow-lg rounded-lg p-4 max-w-sm z-50 transform transition-transform duration-300 translate-x-full';
    notification.innerHTML = `
      <div class = "flex items-start">
        <div class = "flex-shrink-0 text-indigo-600">
          <svg class = "h-6 w-6" fill = "none" stroke = "currentColor" viewBox = "0 0 24 24" xmlns = "http://www.w3.org/2000/svg">
            <path stroke-linecap = "round" stroke-linejoin = "round" stroke-width = "2" d = "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
        </div>
        <div class = "ml-3 w-0 flex-1">
          <p class = "text-sm font-medium text-gray-900">${title}</p>
          <p class = "mt-1 text-sm text-gray-500">${message}</p>
        </div>
        <div class = "ml-4 flex-shrink-0 flex">
          <button class = "inline-flex text-gray-400 hover:text-gray-500 focus:outline-none">
            <svg class = "h-5 w-5" fill = "none" stroke = "currentColor" viewBox = "0 0 24 24" xmlns = "http://www.w3.org/2000/svg">
              <path stroke-linecap = "round" stroke-linejoin = "round" stroke-width = "2" d = "M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
      </div>
    `;

    // Add to document
    document.body.appendChild(notification);

    // Animate in
    setTimeout(() => {
      notification.classList.remove('translate-x-full');
    }, 10);

    // Add click handler to close
    notification.querySelector('button').addEventListener('click', () => {
      notification.classList.add('translate-x-full');
      setTimeout(() => {
        notification.remove();
      }, 300);
    });

    // Auto remove after 5 seconds
    setTimeout(() => {
      if (document.body.contains(notification)) {
        notification.classList.add('translate-x-full');
        setTimeout(() => {
          notification.remove();
        }, 300);
      }
    }, 5000);
  }
};

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  // Initialize the Universal Script Runner
  universalScriptRunner.init();
});

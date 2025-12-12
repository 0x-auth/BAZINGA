/tmp/upl-setup-1744566716/upl-visualization-component.txt:class PSpaceVisualizer {
/tmp/upl-setup-1744566716/upl-visualization-component.txt-  constructor(containerId) {
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.container = document.getElementById(containerId);
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    if (!this.container) {
/tmp/upl-setup-1744566716/upl-visualization-component.txt-      throw new Error(`Container with ID ${containerId} not found`);
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    }
/tmp/upl-setup-1744566716/upl-visualization-component.txt-
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.width = this.container.clientWidth;
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.height = 400;
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.centerX = this.width / 2;
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.centerY = this.height / 2;
/tmp/upl-setup-1744566716/upl-visualization-component.txt-
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.createCanvas();
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.setupEventListeners();
/tmp/upl-setup-1744566716/upl-visualization-component.txt-  }
/tmp/upl-setup-1744566716/upl-visualization-component.txt-
/tmp/upl-setup-1744566716/upl-visualization-component.txt-  createCanvas() {
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.canvas = document.createElement('canvas');
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.canvas.width = this.width;
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.canvas.height = this.height;
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.container.appendChild(this.canvas);
/tmp/upl-setup-1744566716/upl-visualization-component.txt-
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.ctx = this.canvas.getContext('2d');
/tmp/upl-setup-1744566716/upl-visualization-component.txt-
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    // Add a canvas label
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    const label = document.createElement('div');
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    label.style.textAlign = 'center';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    label.style.marginTop = '10px';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    label.style.fontWeight = 'bold';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    label.textContent = '5-Dimensional P-Space Visualization';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.container.appendChild(label);
/tmp/upl-setup-1744566716/upl-visualization-component.txt-  }
/tmp/upl-setup-1744566716/upl-visualization-component.txt-
/tmp/upl-setup-1744566716/upl-visualization-component.txt-  setupEventListeners() {
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    // Add resize listener
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    window.addEventListener('resize', () => {
/tmp/upl-setup-1744566716/upl-visualization-component.txt-      if (this.resizeTimeout) {
/tmp/upl-setup-1744566716/upl-visualization-component.txt-        clearTimeout(this.resizeTimeout);
/tmp/upl-setup-1744566716/upl-visualization-component.txt-      }
/tmp/upl-setup-1744566716/upl-visualization-component.txt-
/tmp/upl-setup-1744566716/upl-visualization-component.txt-      this.resizeTimeout = setTimeout(() => {
/tmp/upl-setup-1744566716/upl-visualization-component.txt-        this.resize();
/tmp/upl-setup-1744566716/upl-visualization-component.txt-      }, 200);
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    });
/tmp/upl-setup-1744566716/upl-visualization-component.txt-
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    // Add tooltip functionality
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.tooltip = document.createElement('div');
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.tooltip.style.position = 'absolute';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.tooltip.style.display = 'none';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.tooltip.style.padding = '10px';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.tooltip.style.background = 'rgba(0, 0, 0, 0.8)';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.tooltip.style.color = '#fff';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.tooltip.style.borderRadius = '5px';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-    this.tooltip.style.fontSize = '14px';
/tmp/upl-setup-1744566716/upl-visualization-component.txt-

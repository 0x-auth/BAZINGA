#!/usr/bin/env python
# bazinga_dashboard_generator.py - Generate a dashboard for the BAZINGA system

from src.core.bazinga import BazingaUniversalTool
from src.core.dodo import DodoSystem, ProcessingState
import os
import json
import random
import datetime

print("=== BAZINGA Dashboard Generator ===\n")

# Initialize our tools
bazinga = BazingaUniversalTool()
dodo = DodoSystem()

# Create directory for generated output if it doesn't exist
output_dir = "generated"
dashboard_dir = os.path.join(output_dir, "dashboard")
if not os.path.exists(dashboard_dir):
    os.makedirs(dashboard_dir)

# Step 1: Generate sample BAZINGA metrics data
print("Step 1: Generating sample metrics data")

# Create a dataset of sample encodings and their processing results
current_date = datetime.datetime.now()
metrics = []

# Generate 30 days of sample data
for i in range(30):
    date = (current_date - datetime.timedelta(days = 30-i)).strftime("%Y-%m-%d")

    # Generate between 3-7 pattern processes per day
    daily_processes = random.randint(3, 7)

    for j in range(daily_processes):
        # Create sample patterns
        section = random.randint(1, 9)
        subsection = random.randint(1, 3)
        attributes = [random.randint(1, 5) for _ in range(random.randint(3, 5))]

        pattern = bazinga.encode(section, subsection, attributes)

        # Generate metrics
        trust_level = round(random.uniform(0.5, 0.95), 2)
        processing_time = round(random.uniform(0.1, 1.5), 2)

        # Different pattern types
        pattern_type = random.choice(["Divergence", "Convergence", "Balance", "Recency", "BigPicture"])

        metrics.append({
            "date": date,
            "timestamp": int((current_date - datetime.timedelta(days = 30-i)).timestamp()),
            "pattern": pattern,
            "pattern_type": pattern_type,
            "trust_level": trust_level,
            "processing_time": processing_time,
            "section": section,
            "subsection": subsection
        })

# Save metrics data to JSON
metrics_file = os.path.join(dashboard_dir, "metrics.json")
with open(metrics_file, "w") as f:
    json.dump(metrics, f, indent = 2)
print(f"Generated metrics data saved to: {metrics_file}")

# Step 2: Create the dashboard HTML
print("\nStep 2: Creating dashboard HTML")

dashboard_html = """<!DOCTYPE html>
<html lang = "en">
<head>
    <meta charset = "UTF-8">
    <meta name = "viewport" content = "width = device-width, initial-scale = 1.0">
    <title>BAZINGA System Dashboard</title>
    <link href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel = "stylesheet">
    <script src = "https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src = "https://cdn.jsdelivr.net/npm/moment@2.29.4/moment.min.js"></script>
    <style>
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: #f8f9fa;
            color: #343a40;
            padding-top: 20px;
        }
        .card {
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
            border: none;
        }
        .card-header {
            background-color: #fff;
            border-bottom: 1px solid rgba(0, 0, 0, 0.125);
            padding: 1rem 1.25rem;
            font-weight: 600;
            border-top-left-radius: 10px !important;
            border-top-right-radius: 10px !important;
        }
        .metric-value {
            font-size: 2rem;
            font-weight: 700;
        }
        .metric-label {
            font-size: 0.9rem;
            color: #6c757d;
        }
        .pattern-card {
            transition: transform 0.2s;
            cursor: pointer;
        }
        .pattern-card:hover {
            transform: translateY(-5px);
        }
        .navbar-brand {
            font-weight: 700;
            color: #5469d4 !important;
        }
        .header-subtitle {
            color: #6c757d;
            font-weight: 400;
        }
        .section-title {
            font-weight: 600;
            margin-bottom: 1rem;
            color: #495057;
        }
        .badge-pattern {
            background-color: #5469d4;
            color: white;
            font-weight: 500;
            padding: 0.4em 0.7em;
        }
        #trust-gauge-container {
            position: relative;
            height: 200px;
        }
        .gauge-value {
            position: absolute;
            bottom: 0;
            width: 100%;
            text-align: center;
            font-size: 1.75rem;
            font-weight: 700;
        }
    </style>
</head>
<body>
    <div class = "container">
        <header class = "mb-4">
            <div class = "d-flex justify-content-between align-items-center">
                <div>
                    <h1 class = "navbar-brand mb-0">BAZINGA System Dashboard</h1>
                    <p class = "header-subtitle">Pattern Processing & Trust Analysis</p>
                </div>
                <div class = "text-end">
                    <div id = "current-time" class = "fs-5 fw-light"></div>
                    <div class = "text-muted">Last updated <span id = "update-time">just now</span></div>
                </div>
            </div>
        </header>

        <!-- Key Metrics Row -->
        <div class = "row mb-4">
            <div class = "col-md-3">
                <div class = "card h-100">
                    <div class = "card-header">Pattern Count</div>
                    <div class = "card-body d-flex flex-column justify-content-center">
                        <div class = "text-center">
                            <div class = "metric-value" id = "pattern-count">--</div>
                            <div class = "metric-label">Total Patterns</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class = "col-md-3">
                <div class = "card h-100">
                    <div class = "card-header">Avg Processing Time</div>
                    <div class = "card-body d-flex flex-column justify-content-center">
                        <div class = "text-center">
                            <div class = "metric-value" id = "avg-processing">--</div>
                            <div class = "metric-label">Seconds</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class = "col-md-3">
                <div class = "card h-100">
                    <div class = "card-header">Avg Trust Level</div>
                    <div class = "card-body d-flex flex-column justify-content-center">
                        <div class = "text-center">
                            <div class = "metric-value" id = "avg-trust">--</div>
                            <div class = "metric-label">Trust Score</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class = "col-md-3">
                <div class = "card h-100">
                    <div class = "card-header">Pattern Types</div>
                    <div class = "card-body d-flex flex-column justify-content-center">
                        <div class = "text-center">
                            <div class = "metric-value" id = "pattern-types">--</div>
                            <div class = "metric-label">Unique Types</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts Row -->
        <div class = "row mb-4">
            <div class = "col-md-8">
                <div class = "card h-100">
                    <div class = "card-header">Pattern Processing Over Time</div>
                    <div class = "card-body">
                        <canvas id = "processing-chart"></canvas>
                    </div>
                </div>
            </div>
            <div class = "col-md-4">
                <div class = "card h-100">
                    <div class = "card-header">Pattern Type Distribution</div>
                    <div class = "card-body">
                        <canvas id = "pattern-type-chart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Trust & Sections Row -->
        <div class = "row mb-4">
            <div class = "col-md-4">
                <div class = "card h-100">
                    <div class = "card-header">Trust Level Gauge</div>
                    <div class = "card-body">
                        <div id = "trust-gauge-container">
                            <canvas id = "trust-gauge"></canvas>
                            <div class = "gauge-value" id = "trust-gauge-value">--</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class = "col-md-8">
                <div class = "card h-100">
                    <div class = "card-header">Section Distribution</div>
                    <div class = "card-body">
                        <canvas id = "section-chart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Patterns -->
        <div class = "row mb-4">
            <div class = "col-12">
                <div class = "card">
                    <div class = "card-header">Recent Patterns</div>
                    <div class = "card-body">
                        <div class = "table-responsive">
                            <table class = "table table-hover">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Pattern</th>
                                        <th>Type</th>
                                        <th>Trust Level</th>
                                        <th>Processing Time</th>
                                    </tr>
                                </thead>
                                <tbody id = "recent-patterns-table">
                                    <!-- Will be populated by JavaScript -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Load the metrics data
        async function loadMetricsData() {
            const response = await fetch('metrics.json');
            return await response.json();
        }

        // Update dashboard with metrics
        async function updateDashboard() {
            const metrics = await loadMetricsData();

            // Sort metrics by date (newest first)
            metrics.sort((a, b) => b.timestamp - a.timestamp);

            // Update key metrics
            document.getElementById('pattern-count').textContent = metrics.length;

            const avgProcessingTime = metrics.reduce((sum, m) => sum + m.processing_time, 0) / metrics.length;
            document.getElementById('avg-processing').textContent = avgProcessingTime.toFixed(2);

            const avgTrustLevel = metrics.reduce((sum, m) => sum + m.trust_level, 0) / metrics.length;
            document.getElementById('avg-trust').textContent = avgTrustLevel.toFixed(2);

            const uniquePatternTypes = new Set(metrics.map(m => m.pattern_type)).size;
            document.getElementById('pattern-types').textContent = uniquePatternTypes;

            // Update trust gauge value
            document.getElementById('trust-gauge-value').textContent = avgTrustLevel.toFixed(2);

            // Populate recent patterns table
            const recentPatternsTable = document.getElementById('recent-patterns-table');
            recentPatternsTable.innerHTML = '';

            metrics.slice(0, 10).forEach(m => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${m.date}</td>
                    <td><span class = "badge badge-pattern">${m.pattern}</span></td>
                    <td>${m.pattern_type}</td>
                    <td>${m.trust_level}</td>
                    <td>${m.processing_time}s</td>
                `;
                recentPatternsTable.appendChild(row);
            });

            // Create processing time chart
            createProcessingChart(metrics);

            // Create pattern type distribution chart
            createPatternTypeChart(metrics);

            // Create section distribution chart
            createSectionChart(metrics);

            // Create trust gauge chart
            createTrustGauge(avgTrustLevel);

            // Update current time
            updateTime();
        }

        function createProcessingChart(metrics) {
            // Group metrics by date
            const metricsByDate = {};
            metrics.forEach(m => {
                if (!metricsByDate[m.date]) {
                    metricsByDate[m.date] = {
                        patterns: 0,
                        avgTrust: 0,
                        avgProcessingTime: 0
                    };
                }
                metricsByDate[m.date].patterns++;
                metricsByDate[m.date].avgTrust += m.trust_level;
                metricsByDate[m.date].avgProcessingTime += m.processing_time;
            });

            // Calculate averages
            Object.keys(metricsByDate).forEach(date => {
                metricsByDate[date].avgTrust /= metricsByDate[date].patterns;
                metricsByDate[date].avgProcessingTime /= metricsByDate[date].patterns;
            });

            // Sort dates
            const dates = Object.keys(metricsByDate).sort();

            // Prepare chart data
            const patternCounts = dates.map(date => metricsByDate[date].patterns);
            const avgTrustLevels = dates.map(date => metricsByDate[date].avgTrust);
            const avgProcessingTimes = dates.map(date => metricsByDate[date].avgProcessingTime);

            // Create chart
            const ctx = document.getElementById('processing-chart').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: dates,
                    datasets: [
                        {
                            label: 'Pattern Count',
                            data: patternCounts,
                            borderColor: '#5469d4',
                            backgroundColor: 'rgba(84, 105, 212, 0.1)',
                            borderWidth: 2,
                            fill: true,
                            yAxisID: 'y'
                        },
                        {
                            label: 'Avg Trust Level',
                            data: avgTrustLevels,
                            borderColor: '#38b000',
                            backgroundColor: 'rgba(56, 176, 0, 0)',
                            borderWidth: 2,
                            fill: false,
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    interaction: {
                        mode: 'index',
                        intersect: false,
                    },
                    scales: {
                        y: {
                            type: 'linear',
                            display: true,
                            position: 'left',
                            title: {
                                display: true,
                                text: 'Pattern Count'
                            }
                        },
                        y1: {
                            type: 'linear',
                            display: true,
                            position: 'right',
                            title: {
                                display: true,
                                text: 'Trust Level'
                            },
                            min: 0,
                            max: 1,
                            grid: {
                                drawOnChartArea: false,
                            }
                        }
                    }
                }
            });
        }

        function createPatternTypeChart(metrics) {
            // Count pattern types
            const patternTypeCounts = {};
            metrics.forEach(m => {
                if (!patternTypeCounts[m.pattern_type]) {
                    patternTypeCounts[m.pattern_type] = 0;
                }
                patternTypeCounts[m.pattern_type]++;
            });

            // Create chart
            const ctx = document.getElementById('pattern-type-chart').getContext('2d');
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: Object.keys(patternTypeCounts),
                    datasets: [{
                        data: Object.values(patternTypeCounts),
                        backgroundColor: [
                            '#5469d4',
                            '#38b000',
                            '#ff7c43',
                            '#f95d6a',
                            '#665191'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'right',
                        }
                    }
                }
            });
        }

        function createSectionChart(metrics) {
            // Count sections
            const sectionCounts = {};
            metrics.forEach(m => {
                const sectionKey = `Section ${m.section}.${m.subsection}`;
                if (!sectionCounts[sectionKey]) {
                    sectionCounts[sectionKey] = 0;
                }
                sectionCounts[sectionKey]++;
            });

            // Sort section keys
            const sectionKeys = Object.keys(sectionCounts).sort((a, b) => {
                const aMatch = a.match(/Section (\d+)\.(\d+)/);
                const bMatch = b.match(/Section (\d+)\.(\d+)/);
                const aNum = parseInt(aMatch[1]) * 10 + parseInt(aMatch[2]);
                const bNum = parseInt(bMatch[1]) * 10 + parseInt(bMatch[2]);
                return aNum - bNum;
            });

            // Create chart
            const ctx = document.getElementById('section-chart').getContext('2d');
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: sectionKeys,
                    datasets: [{
                        label: 'Pattern Count',
                        data: sectionKeys.map(key => sectionCounts[key]),
                        backgroundColor: '#5469d4',
                        borderColor: '#4356b4',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Count'
                            }
                        }
                    }
                }
            });
        }

        function createTrustGauge(trustLevel) {
            const ctx = document.getElementById('trust-gauge').getContext('2d');

            // Define gradient colors
            const gradientColors = [
                [0, '#f95d6a'],     // Red at 0%
                [0.4, '#ff7c43'],   // Orange at 40%
                [0.6, '#ffd166'],   // Yellow at 60%
                [0.8, '#a0c35a'],   // Light green at 80%
                [1, '#38b000']      // Green at 100%
            ];

            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    datasets: [{
                        data: [trustLevel, 1 - trustLevel],
                        backgroundColor: [
                            createGradient(ctx, gradientColors, trustLevel),
                            '#f1f3f5'
                        ],
                        borderWidth: 0,
                        circumference: 180,
                        rotation: 270
                    }]
                },
                options: {
                    responsive: true,
                    cutout: '70%',
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            enabled: false
                        }
                    }
                }
            });
        }

        function createGradient(ctx, colorStops, value) {
            const gradient = ctx.createLinearGradient(0, 0, 200, 0);

            // Find the color range where value falls
            for (let i = 0; i < colorStops.length - 1; i++) {
                const [pos1, color1] = colorStops[i];
                const [pos2, color2] = colorStops[i + 1];

                if (value >= pos1 && value <= pos2) {
                    const normalizedPos = (value - pos1) / (pos2 - pos1);
                    gradient.addColorStop(0, color1);
                    gradient.addColorStop(1, color2);
                    break;
                }
            }

            return gradient;
        }

        function updateTime() {
            const now = new Date();
            document.getElementById('current-time').textContent = now.toLocaleTimeString();
        }

        // Initialize dashboard
        updateDashboard();

        // Update time every second
        setInterval(updateTime, 1000);
    </script>
</body>
</html>
"""

# Save dashboard HTML
dashboard_html_file = os.path.join(dashboard_dir, "index.html")
with open(dashboard_html_file, "w") as f:
    f.write(dashboard_html)
print(f"Dashboard HTML saved to: {dashboard_html_file}")

print("\nStep 3: Creating a Python script to launch the dashboard")

# Create a launcher script
launcher_script = """#!/usr/bin/env python
# bazinga_dashboard_launcher.py - Launch the BAZINGA dashboard

import os
import webbrowser
import http.server
import socketserver
import threading

# Dashboard directory
dashboard_dir = os.path.join("generated", "dashboard")
if not os.path.exists(dashboard_dir):
    print(f"Error: Dashboard directory '{dashboard_dir}' not found.")
    exit(1)

# Define server port
PORT = 8000

# Create a simple HTTP server
Handler = http.server.SimpleHTTPRequestHandler
httpd = socketserver.TCPServer(("", PORT), Handler)

# Change to the dashboard directory
os.chdir(dashboard_dir)

# Function to start the server
def start_server():
    print(f"Starting BAZINGA Dashboard server at http://localhost:{PORT}")
    print("Press Ctrl+C to stop the server")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print("Server stopped")

# Start the server in a separate thread
server_thread = threading.Thread(target = start_server)
server_thread.daemon = True
server_thread.start()

# Open the dashboard in a web browser
webbrowser.open(f"http://localhost:{PORT}")

# Keep the main thread running
try:
    while True:
        input("")
except KeyboardInterrupt:
    print("Shutting down...")
"""

# Save launcher script
launcher_script_file = os.path.join(output_dir, "bazinga_dashboard_launcher.py")
with open(launcher_script_file, "w") as f:
    f.write(launcher_script)
os.chmod(launcher_script_file, 0o755)  # Make executable
print(f"Dashboard launcher script saved to: {launcher_script_file}")

print("\n=== Dashboard Generation Complete ===")
print(f"Files generated in the '{dashboard_dir}' directory:")
print(f"1. index.html - The main dashboard interface")
print(f"2. metrics.json - Sample metrics data for the dashboard")
print("\nTo launch the dashboard:")
print(f"1. Run the launcher script: ./{launcher_script_file}")
print("2. Press Ctrl+C to stop the server when finished")

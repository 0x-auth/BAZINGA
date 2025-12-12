/**
 * WisdomVisualization.js
 *
 * Integrated from BAZINGA artifacts
 * Original file: wisdom-visualization.js
 *
 * Part of the BAZINGA Fractal Relationship Analysis framework
 * BAZINGA Encoding: 5.2.1.3.7.8
 */

import React, { useEffect, useRef, useState } from 'react';

/**
 * Tapestry of Wisdom Visualization
 *
 * This component creates a visual representation of the wisdom concepts
 * from Epictetus and the Bhagavad Gita, showing how imagination, ego,
 * and witness consciousness interact to create suffering or peace.
 */
const WisdomTapestryVisualization = () => {
  const canvasRef = useRef(null);
  const [windowDimensions, setWindowDimensions] = useState({
    width: window.innerWidth * 0.8,
    height: window.innerHeight * 0.7
  });

  // Resize handler
  useEffect(() => {
    const handleResize = () => {
      setWindowDimensions({
        width: window.innerWidth * 0.8,
        height: window.innerHeight * 0.7
      });
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  // Main render effect
  useEffect(() => {
    if (!canvasRef.current) return;

    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');

    // Setup canvas
    canvas.width = windowDimensions.width;
    canvas.height = windowDimensions.height;
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Settings
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    const maxRadius = Math.min(canvas.width, canvas.height) * 0.4;

    // Colors
    const colors = {
      background: '#8570a5', // Purple background from the original image
      reality: '#ffffff',    // White for reality
      imagination: '#ffcc80', // Light orange for imagination
      ego: '#ff8a65',        // Coral for ego
      witness: '#80cbc4',    // Teal for witness consciousness
      text: '#ffffff'        // White text
    };

    // Draw background
    ctx.fillStyle = colors.background;
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Function to draw threads
    const drawThreads = (startAngle, endAngle, startRadius, endRadius, color, count = 50, width = 1) => {
      ctx.strokeStyle = color;

      for (let i = 0; i < count; i++) {
        const angle = startAngle + (endAngle - startAngle) * Math.random();
        const radius1 = startRadius + (endRadius - startRadius) * Math.random() * 0.3;
        const radius2 = startRadius + (endRadius - startRadius) * (0.7 + Math.random() * 0.3);

        ctx.beginPath();
        ctx.lineWidth = width * (0.5 + Math.random());
        ctx.globalAlpha = 0.4 + Math.random() * 0.6;
        ctx.moveTo(
          centerX + Math.cos(angle) * radius1,
          centerY + Math.sin(angle) * radius1
        );
        ctx.lineTo(
          centerX + Math.cos(angle) * radius2,
          centerY + Math.sin(angle) * radius2
        );
        ctx.stroke();
      }

      ctx.globalAlpha = 1;
    };

    // Draw tapestry background texture
    for (let i = 0; i < 360; i += 5) {
      const angle = i * Math.PI / 180;
      drawThreads(
        angle - 0.1,
        angle + 0.1,
        0,
        maxRadius * 1.3,
        `rgba(255, 255, 255, ${0.05 + Math.random() * 0.05})`,
        3,
        1
      );
    }

    // Draw reality circle (center)
    const realityRadius = maxRadius * 0.15;
    ctx.beginPath();
    ctx.arc(centerX, centerY, realityRadius, 0, Math.PI * 2);
    ctx.fillStyle = colors.reality;
    ctx.globalAlpha = 0.7;
    ctx.fill();
    ctx.globalAlpha = 1;

    // Draw imagination zone (surrounds reality)
    const imaginationRadius = maxRadius * 0.4;
    const imaginationGradient = ctx.createRadialGradient(
      centerX, centerY, realityRadius,
      centerX, centerY, imaginationRadius
    );
    imaginationGradient.addColorStop(0, 'rgba(255, 204, 128, 0.1)');
    imaginationGradient.addColorStop(1, 'rgba(255, 204, 128, 0.4)');

    ctx.beginPath();
    ctx.arc(centerX, centerY, imaginationRadius, 0, Math.PI * 2);
    ctx.fillStyle = imaginationGradient;
    ctx.fill();

    // Draw ego barriers
    const egoBarrierCount = 8;
    const egoWidth = 15;
    ctx.strokeStyle = colors.ego;
    ctx.lineWidth = egoWidth;
    ctx.globalAlpha = 0.7;

    for (let i = 0; i < egoBarrierCount; i++) {
      const angle = (i / egoBarrierCount) * Math.PI * 2;
      ctx.beginPath();
      ctx.moveTo(
        centerX + Math.cos(angle) * (imaginationRadius + egoWidth/2),
        centerY + Math.sin(angle) * (imaginationRadius + egoWidth/2)
      );
      ctx.lineTo(
        centerX + Math.cos(angle) * (maxRadius - egoWidth/2),
        centerY + Math.sin(angle) * (maxRadius - egoWidth/2)
      );
      ctx.stroke();
    }

    ctx.globalAlpha = 1;

    // Draw witness consciousness (outer circle)
    ctx.beginPath();
    ctx.arc(centerX, centerY, maxRadius, 0, Math.PI * 2);
    ctx.strokeStyle = colors.witness;
    ctx.lineWidth = 10;
    ctx.globalAlpha = 0.9;
    ctx.stroke();
    ctx.globalAlpha = 1;

    // Draw threads connecting reality to witness
    drawThreads(0, Math.PI * 2, realityRadius, maxRadius, colors.witness, 100, 0.5);

    // Add labels with shadows
    ctx.font = 'bold 16px Arial';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillStyle = colors.text;

    // Function to add text with shadow
    const drawText = (text, x, y, size = 16) => {
      ctx.font = `bold ${size}px Arial`;
      ctx.shadowColor = 'rgba(0, 0, 0, 0.5)';
      ctx.shadowBlur = 4;
      ctx.shadowOffsetX = 2;
      ctx.shadowOffsetY = 2;
      ctx.fillText(text, x, y);
      ctx.shadowColor = 'transparent';
    };

    // Add labels
    drawText('Reality', centerX, centerY, 18);
    drawText('Imagination', centerX, centerY - imaginationRadius * 0.7, 16);
    drawText('Ego Barriers', centerX, centerY - maxRadius * 0.7, 16);
    drawText('Witness Consciousness', centerX, centerY - maxRadius - 20, 20);

    // Add wisdom quotes
    drawText('"We suffer more often in imagination than in reality"', centerX, centerY - maxRadius - 50, 14);
    drawText('- Epictetus', centerX, centerY - maxRadius - 70, 12);

    drawText('"A person is never the doer of actions, but the witness to them"', centerX, centerY + maxRadius + 50, 14);
    drawText('- Bhagavad Gita', centerX, centerY + maxRadius + 70, 12);

    // Add explanation at bottom
    const explanationY = canvas.height - 40;
    drawText('The tapestry of wisdom shows how ego creates barriers between reality and witness consciousness.', centerX, explanationY, 14);
    drawText('Suffering occurs mainly in imagination, not in reality itself.', centerX, explanationY + 20, 14);

  }, [windowDimensions]);

  return (
    <div className = "flex flex-col items-center justify-center p-4">
      <h2 className = "text-2xl font-bold mb-4 text-center">The Tapestry of Wisdom: Visualization</h2>
      <div className = "border-2 border-gray-300 rounded-lg overflow-hidden shadow-lg">
        <canvas
          ref={canvasRef}
          className = "bg-white"
          width={windowDimensions.width}
          height={windowDimensions.height}
        />
      </div>
      <div className = "mt-6 text-center max-w-2xl">
        <p className = "text-lg">
          This visualization represents the relationship between reality, imagination, ego, and witness consciousness.
          The center circle is reality; the surrounding area is imagination where most suffering occurs (Epictetus).
          The radiating barriers represent ego that divides hearts and creates separation.
          The outer circle is witness consciousness - our true nature beyond doership (Bhagavad Gita).
        </p>
      </div>
    </div>
  );
};

export default WisdomTapestryVisualization;


// Add module exports for BAZINGA integration
module.exports = { Wisdactivity-glance_v1.1_v1.2_v1.2.shomVisualization };

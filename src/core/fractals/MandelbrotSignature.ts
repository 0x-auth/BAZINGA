/**
 * MandelbrotSignature.ts
 *
 * Implements fractal mathematics for pattern analysis in the BAZINGA system.
 * Uses the Mandelbrot set to create unique signatures for communication patterns.
 *
 * DODO Pattern: 5.1.1.2.3.4.5.1
 * Encoding: 7.5.3.2.1.4
 */

// Mathematical constants that appear in nature and consciousness
export const FRACTAL_CONSTANTS = {
  PHI: 1.618033988749895,  // Golden ratio
  PHI_SQUARED: 2.618033988749895, // φ²
  INV_PHI: 0.618033988749895,     // 1/φ
  E: 2.718281828459045,    // Euler's number
  PI: 3.141592653589793,   // Pi
  TWO_PI: 6.283185307179586,      // 2π
  E_TO_PI: 23.140692632779267,    // e^π
  FEIGENBAUM_ALPHA: 2.5029,       // Feigenbaum constant alpha
  FEIGENBAUM_DELTA: 4.6692,       // Feigenbaum constant delta
  BASE_FIBONACCI: [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
};

/**
 * Represents a point in the Mandelbrot set calculation
 */
export interface MandelbrotPoint {
    x: number;
    y: number;
    iterations: number;
    inSet: boolean;
}

/**
 * Fractal signature based on Mandelbrot set
 * Used to analyze and visualize communication patterns
 */
export class FractalSignature {
    public points: MandelbrotPoint[];
    private complexity: number | null = null;
    private harmonicRatio: number = FRACTAL_CONSTANTS.PHI; // Golden ratio

    constructor(points: MandelbrotPoint[]) {
        this.points = points;
    }

    /**
     * Get all points in the fractal signature
     */
    public getPoints(): MandelbrotPoint[] {
        return [...this.points];
    }

    /**
     * Get points that are in the Mandelbrot set
     */
    public getSetPoints(): MandelbrotPoint[] {
        return this.points.filter(point => point.inSet);
    }

    /**
     * Get points that are not in the Mandelbrot set
     */
    public getBoundaryPoints(): MandelbrotPoint[] {
        return this.points.filter(point => !point.inSet);
    }

    /**
     * Calculate the complexity of the fractal signature
     * Higher values indicate more complex patterns
     */
    public calculateComplexity(): number {
        // Use cached value if available
        if (this.complexity !=== null) {
            return this.complexity;
        }

        // If no points, return zero complexity
        if (this.points.length === 0) {
            this.complexity = 0;
            return 0;
        }

        // Calculate average iterations
        const avgIterations = this.points.reduce((sum, point) => sum + point.iterations, 0) / this.points.length;

        // Calculate iteration variance
        const iterationVariance = this.points.reduce((sum, point) => {
            const diff = point.iterations - avgIterations;
            return sum + (diff * diff);
        }, 0) / this.points.length;

        // Calculate point distribution
        const xValues = this.points.map(p => p.x);
        const yValues = this.points.map(p => p.y);

        const xMin = Math.min(...xValues);
        const xMax = Math.max(...xValues);
        const yMin = Math.min(...yValues);
        const yMax = Math.max(...yValues);

        const area = (xMax - xMin) * (yMax - yMin);
        const density = this.points.length / Math.max(0.0001, area);

        // Calculate fractal dimension approximation
        const fractalDimension = this.calculateFractalDimension();

        // Combine factors to determine complexity
        // Normalize to [0, 1] range
        const iterationFactor = Math.min(1, Math.sqrt(iterationVariance) / 50);
        const densityFactor = Math.min(1, density / 10);
        const dimensionFactor = (fractalDimension - 1) / 1; // Normalize from [1, 2] to [0, 1]

        // Calculate final complexity with golden ratio weighting
        this.complexity = (
            (iterationFactor * 0.4) +
            (densityFactor * 0.3) +
            (dimensionFactor * 0.3)
        ) * (1 + (1 / this.harmonicRatio));

        // Ensure complexity is in [0, 1] range
        this.complexity = Math.max(0, Math.min(1, this.complexity));

        return this.complexity;
    }

    /**
     * Find harmonic patterns in the fractal signature
     */
    public findHarmonicPatterns(): number[] {
        const harmonics: number[] = [];

        // Find points with golden ratio relationships
        for (let i = 0; i < this.points.length; i++) {
            for (let j = i + 1; j < this.points.length; j++) {
                const p1 = this.points[i];
                const p2 = this.points[j];

                // Calculate distance
                const dx = p2.x - p1.x;
                const dy = p2.y - p1.y;
                const distance = Math.sqrt(dx*dx + dy*dy);

                // Add harmonic if distance is related to golden ratio
                if (Math.abs(distance - this.harmonicRatio) < 0.1 ||
                    Math.abs(distance - (1/this.harmonicRatio)) < 0.1) {
                    harmonics.push(distance);
                }
            }
        }

        return harmonics;
    }

    /**
     * Check if the fractal signature contains specific pattern
     */
    public containsPattern(patternPoints: MandelbrotPoint[], tolerance: number = 0.1): boolean {
        if (patternPoints.length === 0) return true;
        if (this.points.length === 0) return false;

        // For each pattern point, find the closest point in the signature
        for (const patternPoint of patternPoints) {
            let found = false;

            for (const point of this.points) {
                const dx = point.x - patternPoint.x;
                const dy = point.y - patternPoint.y;
                const distance = Math.sqrt(dx*dx + dy*dy);

                if (distance < tolerance) {
                    found = true;
                    break;
                }
            }

            if (!found) return false;
        }

        return true;
    }

    /**
     * Calculate the approximate fractal dimension using box-counting method
     */
    private calculateFractalDimension(): number {
        if (this.points.length < 10) return 1.0;

        // Implement a simplified box-counting method
        // We'll use 2 different grid sizes and calculate the dimension
        const sizes = [0.1, 0.05];
        const counts: number[] = [];

        for (const size of sizes) {
            const boxes = new Set<string>();

            for (const point of this.points) {
                // Convert point to box coordinate
                const boxX = Math.floor(point.x / size);
                const boxY = Math.floor(point.y / size);
                const boxKey = `${boxX}, ${boxY}`;

                boxes.add(boxKey);
            }

            counts.push(boxes.size);
        }

        // Calculate dimension using log ratio
        if (counts[0] === 0 || counts[1] === 0) return 1.0;

        const dimension = Math.abs(
            Math.log(counts[1] / counts[0]) /
            Math.log(sizes[1] / sizes[0])
        );

        // Ensure dimension is in reasonable range [1, 2]
        return Math.max(1, Math.min(2, dimension));
    }

    /**
     * Generate data for visualization
     */
    public generateVisualizationData(): any {
        const boundaryPoints = this.getBoundaryPoints();
        const setPoints = this.getSetPoints();

        // Calculate normalized iteration values for coloring
        const maxIterations = Math.max(...this.points.map(p => p.iterations));

        const visualData = {
            boundary: boundaryPoints.map(p => ({
                x: p.x,
                y: p.y,
                colorValue: p.iterations / maxIterations
            })),
            set: setPoints.map(p => ({
                x: p.x,
                y: p.y
            })),
            stats: {
                complexity: this.calculateComplexity(),
                boundaryCount: boundaryPoints.length,
                setCount: setPoints.length,
                maxIterations
            }
        };

        return visualData;
    }

    /**
     * Compare with another fractal signature
     * Returns similarity score from 0 to 1
     */
    public compareWith(other: FractalSignature): number {
        const thisComplexity = this.calculateComplexity();
        const otherComplexity = other.calculateComplexity();

        // Compare complexities
        const complexityDiff = Math.abs(thisComplexity - otherComplexity);

        // Compare point distributions
        const thisPoints = this.getPoints();
        const otherPoints = other.getPoints();

        // Simplify comparison by using a sample of points
        const sampleSize = Math.min(100, Math.min(thisPoints.length, otherPoints.length));

        let matchCount = 0;
        const tolerance = 0.1;

        for (let i = 0; i < sampleSize; i++) {
            const thisIndex = Math.floor((i / sampleSize) * thisPoints.length);
            const thisPoint = thisPoints[thisIndex];

            let matched = false;
            for (const otherPoint of otherPoints) {
                const dx = thisPoint.x - otherPoint.x;
                const dy = thisPoint.y - otherPoint.y;
                const distance = Math.sqrt(dx*dx + dy*dy);

                if (distance < tolerance) {
                    matched = true;
                    break;
                }
            }

            if (matched) matchCount++;
        }

        const pointSimilarity = matchCount / sampleSize;

        // Combine factors for final similarity score
        const similarityScore = (1 - complexityDiff) * 0.5 + pointSimilarity * 0.5;

        return Math.max(0, Math.min(1, similarityScore));
    }

    /**
     * Convert to string representation
     */
    public toString(): string {
        const complexity = this.calculateComplexity();
        const inSetCount = this.getSetPoints().length;
        const boundaryCount = this.getBoundaryPoints().length;

        return `FractalSignature: Complexity=${complexity.toFixed(4)}, Points=${this.points.length} (Set=${inSetCount}, Boundary=${boundaryCount})`;
    }

    /**
     * Extract key boundary points from the signature
     * These points typically represent significant transitions in the pattern
     * @param count Number of key points to extract
     * @returns Array of key points
     */
    public extractKeyPoints(count: number = 5): MandelbrotPoint[] {
        if (this.points.length <= count) return [...this.points];

        const keyPoints: MandelbrotPoint[] = [];

        // First, select boundary points (in/out of set transitions)
        const boundaryPoints: MandelbrotPoint[] = [];

        for (let i = 1; i < this.points.length; i++) {
            const current = this.points[i];
            const previous = this.points[i-1];

            // If there's a transition from in-set to out-of-set or vice versa
            if (current.inSet !== previous.inSet) {
                boundaryPoints.push(current);
            }
        }

        // If we have enough boundary points, use them
        if (boundaryPoints.length >= count) {
            // Use Fibonacci-based selection for harmonic distribution
            const indices: number[] = [];
            for (let i = 0; i < count; i++) {
                // Use Fibonacci numbers modulo length for optimal distribution
                const fibIndex = FRACTAL_CONSTANTS.BASE_FIBONACCI[i % FRACTAL_CONSTANTS.BASE_FIBONACCI.length];
                indices.push(fibIndex % boundaryPoints.length);
            }

            // Remove duplicates from indices
            const uniqueIndices = [...new Set(indices)];

            // Get points at those indices
            return uniqueIndices.map(index => boundaryPoints[index]);
        }

        // Otherwise, select points with maximum iteration diversity
        // Sort by iterations
        const sortedPoints = [...this.points].sort((a, b) => a.iterations - b.iterations);

        // Select evenly spaced points from sorted array
        const step = Math.max(1, Math.floor(sortedPoints.length / count));
        for (let i = 0; i < sortedPoints.length && keyPoints.length < count; i += step) {
            keyPoints.push(sortedPoints[i]);
        }

        return keyPoints;
    }

    /**
     * Convert the fractal signature to a binary string representation
     * This creates a unique fingerprint of the fractal pattern
     * @returns Binary string encoding the pattern
     */
    public toBinaryString(): string {
        let binary = '';

        // Sample up to 32 points (or fewer if not available)
        const sampleCount = Math.min(32, this.points.length);
        const step = Math.max(1, Math.floor(this.points.length / sampleCount));

        for (let i = 0; i < this.points.length; i += step) {
            if (binary.length >= 32) break;

            const point = this.points[i];

            // Add bit for in-set status
            binary += point.inSet ? '1' : '0';

            // Add bit for iteration count (high/low)
            binary += point.iterations > 50 ? '1' : '0';
        }

        // Pad to at least 5 bits if needed
        while (binary.length < 5) {
            binary += '0';
        }

        return binary;
    }

    /**
     * Derive a set of 5-bit patterns from this fractal signature
     * These patterns can be used with the Lambda system
     * @param count Number of patterns to derive
     * @returns Array of 5-bit pattern strings
     */
    public derivePatterns(count: number = 5): string[] {
        const patterns: string[] = [];
        const keyPoints = this.extractKeyPoints(count);

        // For each key point, derive a 5-bit pattern
        keyPoints.forEach(point => {
            let pattern = '';

            // Bit 1: Based on x coordinate (positive/negative)
            pattern += point.x >= 0 ? '1' : '0';

            // Bit 2: Based on y coordinate (positive/negative)
            pattern += point.y >= 0 ? '1' : '0';

            // Bit 3: Based on iterations (high/low)
            pattern += point.iterations > 50 ? '1' : '0';

            // Bit 4: Based on whether point is in set
            pattern += point.inSet ? '1' : '0';

            // Bit 5: Based on distance from origin
            const distance = Math.sqrt(point.x * point.x + point.y * point.y);
            pattern += distance > 0.5 ? '1' : '0';

            patterns.push(pattern);
        });

        return patterns;
    }

    /**
     * Map this fractal signature to the five dimensions of DODO
     * @returns Mapping of dimensions to relevance scores (0-1)
     */
    public mapToDODODimensions(): Record<string, number> {
        // Calculate properties that correlate with different dimensions
        const complexity = this.calculateComplexity();
        const variance = this.calculateIterationVariance();
        const inSetRatio = this.getSetPoints().length / this.points.length;

        // Map properties to dimensions
        return {
            // X-Dimension: Structure (physical arrangement)
            X: this.calculateSymmetryScore(),

            // Y-Dimension: Temporality (temporal relationship)
            Y: variance,

            // Z-Dimension: Contextuality (contextual relationship)
            Z: complexity,

            // W-Dimension: Emergence (emergent properties)
            W: this.calculateBoundaryRatio(),

            // V-Dimension: Trust (trust relationship)
            V: inSetRatio
        };
    }

    /**
     * Calculate the statistical variance of iteration values
     * High variance indicates complex patterns with many transitions
     * @returns Variance value (0 to 1 normalized)
     */
    private calculateIterationVariance(): number {
        if (this.points.length <= 1) return 0;

        // Calculate mean
        const iterations = this.points.map(p => p.iterations);
        const mean = iterations.reduce((sum, val) => sum + val, 0) / iterations.length;

        // Calculate variance
        const variance = iterations.reduce((sum, val) => {
            const diff = val - mean;
            return sum + (diff * diff);
        }, 0) / iterations.length;

        // Normalize to 0-1 range (assuming max iterations is 100)
        return Math.min(1, variance / 1000);
    }

    /**
     * Calculate symmetry score for the fractal signature
     * @returns Symmetry score (0-1, where 1 is perfectly symmetric)
     */
    private calculateSymmetryScore(): number {
        // A simple approach comparing points across x-axis
        // A more thorough implementation would check multiple symmetry types

        // Find points with corresponding negative-y values
        let matchCount = 0;
        for (const point of this.points) {
            // Look for a point with similar x but opposite y
            const counterpart = this.points.find(p =>
                Math.abs(p.x - point.x) < 0.1 &&
                Math.abs(p.y + point.y) < 0.1
            );

            if (counterpart) {
                matchCount++;
            }
        }

        return matchCount / this.points.length;
    }

    /**
     * Calculate the ratio of boundary points to total points
     * Boundary points are at the edge between in-set and out-of-set regions
     * @returns Boundary ratio (0-1)
     */
    private calculateBoundaryRatio(): number {
        if (this.points.length <= 1) return 0;

        // Count transitions from in-set to out-of-set or vice versa
        let boundaryCount = 0;
        for (let i = 1; i < this.points.length; i++) {
            if (this.points[i].inSet !== this.points[i-1].inSet) {
                boundaryCount++;
            }
        }

        return boundaryCount / (this.points.length - 1);
    }
}

/**
 * Create a Mandelbrot signature from a pattern string
 */
export function createSignatureFromPattern(patternString: string, depth: number = 5): FractalSignature {
    // Convert pattern string to numeric seed
    let seed = 0;
    for (let i = 0; i < patternString.length; i++) {
        seed += patternString.charCodeAt(i) * Math.pow(1.5, i % 3);
    }

    const points: MandelbrotPoint[] = [];

    // Generate points around the Mandelbrot set
    for (let i = 0; i < depth * 10; i++) {
        const angle = seed * i * 0.1;
        const radius = 0.7 + (Math.sin(seed * i * 0.05) * 0.3);

        const x = radius * Math.cos(angle);
        const y = radius * Math.sin(angle);

        // Check if point is in Mandelbrot set
        const iterations = mandelbrotIterations(x, y, 100);

        points.push({
            x,
            y,
            iterations,
            inSet: iterations >= 100
        });
    }

    return new FractalSignature(points);
}

/**
 * Calculate iterations for Mandelbrot set
 */
function mandelbrotIterations(x0: number, y0: number, maxIterations: number): number {
    let x = 0;
    let y = 0;
    let iteration = 0;

    while (x*x + y*y < 4 && iteration < maxIterations) {
        const xTemp = x*x - y*y + x0;
        y = 2*x*y + y0;
        x = xTemp;
        iteration++;
    }

    return iteration;
}

export default FractalSignature;

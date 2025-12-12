/**
 * RelationshipFractalAnalyzer.ts
 *
 * Analyzes relationship patterns using fractal mathematics and time-trust dimensions.
 * Integrates with BAZINGA system for pattern recognition and analysis.
 */

import { Pattern } from '../core/dna';
import { Blueprint } from '../core/patterns';
import { TimeTrustFramework } from '../core/time-trust';
import { HarmonicProcessor } from '../dodo/harmonics';
import { FractalSignature, MandelbrotPoint } from './MandelbrotSignature';

/**
 * Configuration for relationship pattern analysis
 */
export interface RelationshipPatternConfig {
    timeScale: number;
    trustThreshold: number;
    fractalDepth: number;
    harmonicRatio: number;
    patternDetectionMode: 'standard' | 'sensitive' | 'temporal';
    encodingPattern: string; // e.g. "4.1.1.3.5.2.4"
}

/**
 * Result of a relationship pattern analysis
 */
export interface RelationshipAnalysisResult {
    patterns: Pattern[];
    fractalSignature: FractalSignature;
    timelineSeries: TimelinePoint[];
    trustEvolution: TrustPoint[];
    harmonicResonance: number;
    stabilityScore: number;
    recommendations?: string[];
}

interface TimelinePoint {
    timestamp: number;
    patternState: string;
    emotionalValence: number;
    trustLevel: number;
}

interface TrustPoint {
    level: number;
    stability: number;
    trend: 'increasing' | 'decreasing' | 'stable';
}

/**
 * Core analyzer for relationship patterns using fractal mathematics
 */
export class RelationshipFractalAnalyzer {
    private timeTrust: TimeTrustFramework;
    private harmonicProcessor: HarmonicProcessor;
    private config: RelationshipPatternConfig;
    private mandelbrotCache: Map<string, MandelbrotPoint[]>;

    constructor(config: RelationshipPatternConfig) {
        this.config = {
            timeScale: 1.0,
            trustThreshold: 0.7,
            fractalDepth: 5,
            harmonicRatio: 1.618033988749895, // Golden ratio
            patternDetectionMode: 'standard',
            ...config
        };

        this.timeTrust = new TimeTrustFramework(this.config.encodingPattern);
        this.harmonicProcessor = new HarmonicProcessor(this.config.harmonicRatio);
        this.mandelbrotCache = new Map<string, MandelbrotPoint[]>();
    }

    /**
     * Analyze communication data to identify relationship patterns
     */
    public analyzeRelationshipPatterns(
        communicationData: any[],
        timeframe: [Date, Date]
    ): RelationshipAnalysisResult {
        // Filter data based on timeframe
        const filteredData = this.filterDataByTimeframe(communicationData, timeframe);

        // Create blueprint from communication patterns
        const blueprint = this.createBlueprint(filteredData);

        // Generate fractal signature
        const fractalSignature = this.generateFractalSignature(blueprint);

        // Process timeline series
        const timelineSeries = this.processTimelineSeries(filteredData);

        // Analyze trust evolution
        const trustEvolution = this.analyzeTrustEvolution(timelineSeries);

        // Calculate harmonic resonance
        const harmonicResonance = this.calculateHarmonicResonance(fractalSignature, trustEvolution);

        // Determine stability score
        const stabilityScore = this.calculateStabilityScore(trustEvolution, timelineSeries);

        // Generate recommendations if needed
        const recommendations = stabilityScore < 0.7 ? this.generateRecommendations(
            fractalSignature, trustEvolution, stabilityScore
        ) : undefined;

        return {
            patterns: blueprint.getPatterns(),
            fractalSignature,
            timelineSeries,
            trustEvolution,
            harmonicResonance,
            stabilityScore,
            recommendations
        };
    }

    /**
     * Analyze using specific time-trust encoding (e.g. "4.1.1.3.5.2.4")
     */
    public analyzeWithEncoding(
        data: any[],
        encoding: string,
        timeframe: [Date, Date]
    ): RelationshipAnalysisResult {
        // Update the time-trust framework with new encoding
        this.timeTrust = new TimeTrustFramework(encoding);

        // Run the analysis with the new encoding
        return this.analyzeRelationshipPatterns(data, timeframe);
    }

    /**
     * Filter data based on timeframe
     */
    private filterDataByTimeframe(data: any[], timeframe: [Date, Date]): any[] {
        const [startDate, endDate] = timeframe;
        return data.filter(item => {
            const itemDate = new Date(item.timestamp);
            return itemDate >= startDate && itemDate <= endDate;
        });
    }

    /**
     * Create a blueprint from communication data
     */
    private createBlueprint(data: any[]): Blueprint {
        // Extract patterns from communication data
        const patterns: Pattern[] = data.map(item => {
            // Apply time-trust framework to extract pattern
            const processedPattern = this.timeTrust.processItem(item);
            return new Pattern(processedPattern.pattern);
        });

        // Generate blueprint from patterns
        return new Blueprint(patterns);
    }

    /**
     * Generate fractal signature from blueprint
     */
    private generateFractalSignature(blueprint: Blueprint): FractalSignature {
        const patternString = blueprint.getPatternString();

        // Check cache first
        if (this.mandelbrotCache.has(patternString)) {
            const points = this.mandelbrotCache.get(patternString)!;
            return new FractalSignature(points);
        }

        // Generate new fractal signature
        const fractalPoints = this.generateMandelbrotPoints(patternString, this.config.fractalDepth);
        this.mandelbrotCache.set(patternString, fractalPoints);

        return new FractalSignature(fractalPoints);
    }

    /**
     * Generate Mandelbrot points from a pattern string
     */
    private generateMandelbrotPoints(patternString: string, depth: number): MandelbrotPoint[] {
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
            const iterations = this.mandelbrotIterations(x, y, 100);

            points.push({
                x,
                y,
                iterations,
                inSet: iterations >= 100
            });
        }

        return points;
    }

    /**
     * Calculate iterations for Mandelbrot set
     */
    private mandelbrotIterations(x0: number, y0: number, maxIterations: number): number {
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

    /**
     * Process timeline series from data
     */
    private processTimelineSeries(data: any[]): TimelinePoint[] {
        return data.map(item => {
            // Calculate emotional valence based on sentiment or message content
            const emotionalValence = this.calculateEmotionalValence(item);

            // Determine trust level based on message patterns and response time
            const trustLevel = this.calculateTrustLevel(item);

            // Determine pattern state based on communication characteristics
            const patternState = this.determinePatternState(item, emotionalValence, trustLevel);

            return {
                timestamp: new Date(item.timestamp).getTime(),
                patternState,
                emotionalValence,
                trustLevel
            };
        });
    }

    /**
     * Calculate emotional valence from communication item
     */
    private calculateEmotionalValence(item: any): number {
        // Basic calculation based on message content
        if (!item.content) return 0;

        const content = typeof item.content === 'string' ? item.content : '';

        // Simple sentiment analysis - can be replaced with more sophisticated algorithm
        const positiveWords = ['happy', 'good', 'great', 'love', 'wonderful', 'thanks', 'appreciate'];
        const negativeWords = ['sad', 'bad', 'awful', 'hate', 'terrible', 'sorry', 'upset'];

        let score = 0;
        const lowerContent = content.toLowerCase();

        positiveWords.forEach(word => {
            if (lowerContent.includes(word)) score += 0.1;
        });

        negativeWords.forEach(word => {
            if (lowerContent.includes(word)) score -= 0.1;
        });

        // Normalize score to range [-1, 1]
        return Math.max(-1, Math.min(1, score));
    }

    /**
     * Calculate trust level from communication item
     */
    private calculateTrustLevel(item: any): number {
        // Base trust level
        let trustLevel = 0.5;

        // Adjust based on response time (quicker responses indicate higher trust)
        if (item.responseTime) {
            const maxExpectedResponse = 86400000; // 24 hours in milliseconds
            const responseTimeFactor = Math.min(1, item.responseTime / maxExpectedResponse);
            trustLevel -= responseTimeFactor * 0.2; // Reduce trust for slow responses
        }

        // Adjust based on message length (longer messages indicate higher trust)
        if (item.content && typeof item.content === 'string') {
            const contentLength = item.content.length;
            const lengthFactor = Math.min(1, contentLength / 500); // Cap at 500 characters
            trustLevel += lengthFactor * 0.1;
        }

        // Adjust based on communication frequency
        if (item.frequencyMetric) {
            trustLevel += item.frequencyMetric * 0.2;
        }

        // Keep trust level in [0, 1] range
        return Math.max(0, Math.min(1, trustLevel));
    }

    /**
     * Determine pattern state from analysis
     */
    private determinePatternState(item: any, emotionalValence: number, trustLevel: number): string {
        if (trustLevel < 0.3) {
            return 'disconnected';
        }

        if (trustLevel >= 0.8) {
            return 'connected';
        }

        if (emotionalValence > 0.5) {
            return 'positive';
        }

        if (emotionalValence < -0.5) {
            return 'negative';
        }

        return 'neutral';
    }

    /**
     * Analyze trust evolution over time
     */
    private analyzeTrustEvolution(timelineSeries: TimelinePoint[]): TrustPoint[] {
        if (timelineSeries.length < 2) {
            return [{
                level: timelineSeries.length ? timelineSeries[0].trustLevel : 0.5,
                stability: 1.0,
                trend: 'stable'
            }];
        }

        const windowSize = Math.max(5, Math.floor(timelineSeries.length / 10));
        const trustPoints: TrustPoint[] = [];

        for (let i = 0; i < timelineSeries.length - windowSize; i += windowSize) {
            const window = timelineSeries.slice(i, i + windowSize);

            // Calculate average trust level in window
            const avgTrustLevel = window.reduce((sum, point) => sum + point.trustLevel, 0) / window.length;

            // Calculate trust stability (variance)
            const variance = window.reduce((sum, point) => {
                const diff = point.trustLevel - avgTrustLevel;
                return sum + (diff * diff);
            }, 0) / window.length;

            const stability = Math.max(0, 1 - Math.sqrt(variance) * 2);

            // Determine trend
            const firstHalf = window.slice(0, Math.floor(window.length / 2));
            const secondHalf = window.slice(Math.floor(window.length / 2));

            const firstAvg = firstHalf.reduce((sum, point) => sum + point.trustLevel, 0) / firstHalf.length;
            const secondAvg = secondHalf.reduce((sum, point) => sum + point.trustLevel, 0) / secondHalf.length;

            let trend: 'increasing' | 'decreasing' | 'stable';

            if (secondAvg - firstAvg > 0.05) {
                trend = 'increasing';
            } else if (firstAvg - secondAvg > 0.05) {
                trend = 'decreasing';
            } else {
                trend = 'stable';
            }

            trustPoints.push({
                level: avgTrustLevel,
                stability,
                trend
            });
        }

        return trustPoints;
    }

    /**
     * Calculate harmonic resonance between fractal signature and trust evolution
     */
    private calculateHarmonicResonance(
        fractalSignature: FractalSignature,
        trustEvolution: TrustPoint[]
    ): number {
        // Base resonance value
        let resonance = 0.5;

        // Analyze fractal properties
        const fractalComplexity = fractalSignature.calculateComplexity();

        // Analyze trust stability
        const trustStability = trustEvolution.reduce((sum, point) => sum + point.stability, 0) /
            Math.max(1, trustEvolution.length);

        // Calculate resonance based on complexity and stability
        resonance = this.harmonicProcessor.calculateResonance(fractalComplexity, trustStability);

        // Apply golden ratio harmonic
        resonance = resonance * (1 + (1 / this.config.harmonicRatio));

        // Keep resonance in [0, 1] range
        return Math.max(0, Math.min(1, resonance));
    }

    /**
     * Calculate overall stability score
     */
    private calculateStabilityScore(
        trustEvolution: TrustPoint[],
        timelineSeries: TimelinePoint[]
    ): number {
        // Base stability is average of trust point stabilities
        const trustStability = trustEvolution.reduce((sum, point) => sum + point.stability, 0) /
            Math.max(1, trustEvolution.length);

        // Calculate emotional stability
        const emotionalValues = timelineSeries.map(point => point.emotionalValence);
        const emotionalVariance = this.calculateVariance(emotionalValues);
        const emotionalStability = Math.max(0, 1 - emotionalVariance);

        // Calculate pattern state stability
        const stateCount: Record<string, number> = {};
        timelineSeries.forEach(point => {
            stateCount[point.patternState] = (stateCount[point.patternState] || 0) + 1;
        });

        const dominantState = Object.entries(stateCount)
            .sort((a, b) => b[1] - a[1])[0][0];

        const patternStability = stateCount[dominantState] / timelineSeries.length;

        // Calculate weighted stability score
        return (trustStability * 0.5) + (emotionalStability * 0.3) + (patternStability * 0.2);
    }

    /**
     * Calculate variance of a numeric array
     */
    private calculateVariance(values: number[]): number {
        if (values.length < 2) return 0;

        const mean = values.reduce((sum, val) => sum + val, 0) / values.length;

        return values.reduce((sum, val) => {
            const diff = val - mean;
            return sum + (diff * diff);
        }, 0) / values.length;
    }

    /**
     * Generate recommendations based on analysis
     */
    private generateRecommendations(
        fractalSignature: FractalSignature,
        trustEvolution: TrustPoint[],
        stabilityScore: number
    ): string[] {
        const recommendations: string[] = [];

        // Add recommendations based on fractal pattern
        const complexity = fractalSignature.calculateComplexity();

        if (complexity > 0.8) {
            recommendations.push(
                "The communication pattern is highly complex. Simplifying communication and establishing clearer boundaries may improve understanding."
            );
        }

        // Add recommendations based on trust evolution
        const recentTrustPoints = trustEvolution.slice(-3);
        const recentTrend = recentTrustPoints.length > 0 ?
            recentTrustPoints[recentTrustPoints.length - 1].trend : 'stable';

        if (recentTrend === 'decreasing') {
            recommendations.push(
                "Trust appears to be declining. Focus on rebuilding trust through consistent and transparent communication."
            );
        }

        // Add recommendations based on stability score
        if (stabilityScore < 0.4) {
            recommendations.push(
                "The relationship shows significant instability. Consider establishing regular check-ins and clearer communication patterns."
            );
        } else if (stabilityScore < 0.6) {
            recommendations.push(
                "Moderate relationship instability detected. Building more consistent communication patterns may help improve stability."
            );
        }

        return recommendations;
    }
}

export default RelationshipFractalAnalyzer;

/**
 * DodoInterface.ts
 * TypeScript interfaces for DODO System integration with BAZINGA
 */

export interface HarmonicValues {
  goldenRatio: number;
  timeHarmonicRatio: number;
  baseFrequency: number;
}

export interface TransformationPair {
  id: number;
  stateA: string;
  stateB: string;
}

export interface ProcessingState {
  id: string;
  description: string;
}

export interface VisualHarmonics {
  baseRatio: number;
  spacingSequence: number[];
  patternBreaks: number[];
  infoChunks: number[];
}

export interface TimeHarmonics {
  baseRatio: number;
  processingBreaks: number[];
  patternCycles: number[];
}

export interface PatternBreakingStrategy {
  pathType: string;
  complexity: string;
  steps?: number[];
  timing: number[];
  breakPoints?: number[];
  transformPairs?: [string, string][];
  rhythm?: string;
}

export interface DodoSystemConfig {
  harmonics: {
    visual: VisualHarmonics;
    time: TimeHarmonics;
  };
  transformationPairs: TransformationPair[];
  constants: HarmonicValues;
}

/**
 * Integration with TypeValidator.ts
 * Add these methods to TypeValidator class
 */
export interface DodoTypeValidatorExtension {
  /**
   * Applies harmonic spacing based on the Golden Ratio
   */
  applyHarmonicSpacing(baseSize: number, elements: number): number[];

  /**
   * Creates a visual rhythm pattern for information display
   */
  createVisualRhythmPattern(containerWidth: number): {
    primaryElements: number[],
    secondaryElements: number[],
    breakPoints: number[]
  };

  /**
   * Validate with harmonic timing
   */
  validateWithHarmonicTiming<T>(value: T, validator: (val: T) => boolean): {
    isValid: boolean,
    timing: number,
    harmonicTiming: number
  };
}

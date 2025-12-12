// @types/bazinga-fractals.d.ts

declare module 'bazinga-fractals' {
  export interface WitnessDualityResult {
    ratio: number;
    witness_count: number;
    doer_count: number;
    orientation: string;
    phi_proximity: number;
  }

  export interface PerceptionGapResult {
    gap_magnitude: number;
    perception_count: number;
    reality_count: number;
    classification: string;
    e_proximity: number;
  }

  export interface TemporalPatternResult {
    past: number;
    present: number;
    future: number;
    cyclical: number;
    dominant: string;
    classification: string;
    pi_proximity: number;
  }

  export interface BazingaInsight {
    title: string;
    description: string;
    dominant_constant: string;
    fractal_signature: number[];
    witness_duality_pattern: string;
    perception_gap_pattern: string;
    temporal_pattern: string;
    bazinga_encoding: string;
  }

  export class RelationshipFractalAnalyzer {
    constructor(bazingaTool: any, dodoSystem?: any);
    analyzeWitnessDuality(text: string): WitnessDualityResult;
    calculatePerceptionRealityGap(text: string): PerceptionGapResult;
    analyzeTemporalPatterns(text: string): TemporalPatternResult;
    generateMandelbrotSignature(seed: number): number[];
    generateSeed(text: string): number;
    generateBazingaInsight(
      witnessDuality: WitnessDualityResult,
      perceptionGap: PerceptionGapResult,
      temporalPattern: TemporalPatternResult,
      signature: number[]
    ): BazingaInsight;
    enhanceDodoResult(dodoResult: any): any;
  }

  export class UniversalFractalGenerator {
    generate(seed: number, type?: string): any;
  }

  export class FractalDeterministicCommunication {
    generateCommunication(input: any): string;
  }

  export interface FractalSystem {
    analyzer: RelationshipFractalAnalyzer;
    generator: UniversalFractalGenerator;
    communication: FractalDeterministicCommunication;
    visualization: any;
    constants: Record<string, number>;
    analyzeText(text: string): BazingaInsight;
    generatePattern(seed: number, type?: string): any;
    enhanceDodo(data: any): any;
  }

  export function createFractalSystem(options?: {
    bazingaTool?: any;
    dodoSystem?: any;
  }): FractalSystem;
}

// src/utils/types.ts

import { Pattern } from '../core/dna';
import { Rule } from '../core/lambda-rules';

// Generator outputs
export interface GeneratorOutput<T> {
    success: boolean;
    data: T;
    error?: string;
}

// Pattern system types
export interface PatternSystem {
    patterns: Map<Pattern, Rule>;
    meta: Map<string, Function>;
}

// Documentation types
export interface DocumentConfig {
    format: 'markdown' | 'plain';
    sections: {
        overview?: boolean;
        patterns?: boolean;
        lambda?: boolean;
        execution?: boolean;
        examples?: boolean;
        implementation?: boolean;
    };
    detailLevel: 'basic' | 'detailed' | 'comprehensive';
}

// Visualization types
export interface Node {
    id: string;
    label: string;
    type: string;
    data?: any;
}

export interface Edge {
    source: string;
    target: string;
    label?: string;
}

export interface Graph {
    nodes: Node[];
    edges: Edge[];
}

export interface VisualizationConfig {
    includeLabels?: boolean;
    includeTypes?: boolean;
    layout?: 'horizontal' | 'vertical' | 'circular';
}

// Generator types
export interface BaseGeneratorConfig {
    validateInput?: boolean;
    throwErrors?: boolean;
    debug?: boolean;
}

export interface PatternGeneratorConfig extends BaseGeneratorConfig {
    allowComposition?: boolean;
    maxPatternLength?: number;
}

// Pattern transformation types
export interface TransformationResult {
    pattern: Pattern;
    operation: Rule;
    metadata?: Record<string, any>;
}

export interface CompositionResult {
    pattern: Pattern;
    components: Pattern[];
    operation: Rule;
}

// System state types
export interface SystemState {
    patterns: Pattern[];
    operations: Rule[];
    compositions: CompositionResult[];
    metadata: Record<string, any>;
}

// Error types
export class PatternError extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'PatternError';
    }
}

export class GeneratorError extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'GeneratorError';
    }
}

export class ValidationError extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'ValidationError';
    }
}

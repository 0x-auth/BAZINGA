// src/core/patterns.ts

import { Pattern } from './dna';
import { Rule } from './lambda-rules';
import { DNA_PATTERNS, DNAOperations } from './dna';

export class Blueprint {
    private static readonly CORE_PATTERNS = Object.keys(DNA_PATTERNS);

    static readonly CORE_SEQUENCE = '10101 11010 01011 10111 01100';

    /**
     * Get full blueprint sequence
     */
    static getFullBlueprint(): string {
        return this.CORE_SEQUENCE;
    }

    /**
     * Get pattern meaning
     */
    static getPatternMeaning(pattern: Pattern): string {
        return DNAOperations.getMeaning(pattern);
    }

    /**
     * Get lambda rule
     */
    static getLambdaRule(pattern: Pattern): string {
        return DNAOperations.getLambda(pattern);
    }

    /**
     * Validate pattern
     */
    static isValidPattern(pattern: string): boolean {
        return DNAOperations.validatePattern(pattern);
    }

    /**
     * Generate blueprint from patterns
     */
    static generateBlueprint(patterns: Pattern[]): string {
        if (!patterns.every(p => this.isValidPattern(p))) {
            throw new Error('Invalid pattern in sequence');
        }
        return patterns.join(' ');
    }

    /**
     * Parse blueprint into patterns
     */
    static parseBlueprint(blueprint: string): Pattern[] {
        const patterns = blueprint.split(' ');
        if (!patterns.every(p => this.isValidPattern(p))) {
            throw new Error('Invalid blueprint format');
        }
        return patterns;
    }

    /**
     * Get all core patterns
     */
    static getCorePatterns(): Pattern[] {
        return this.CORE_PATTERNS;
    }

    /**
     * Check if pattern is a core pattern
     */
    static isCorePattern(pattern: Pattern): boolean {
        return this.CORE_PATTERNS.includes(pattern);
    }

    /**
     * Compose patterns into new pattern
     */
    static composePatterns(patterns: Pattern[]): Pattern {
        return patterns.reduce((acc, pattern) =>
            DNAOperations.compose(acc, pattern)
        );
    }

    /**
     * Validate blueprint sequence
     */
    static validateBlueprint(blueprint: string): boolean {
        try {
            const patterns = this.parseBlueprint(blueprint);
            return patterns.every(p => this.isValidPattern(p));
        } catch {
            return false;
        }
    }

    /**
     * Get operation chain from blueprint
     */
    static getOperationChain(blueprint: string): Rule[] {
        const patterns = this.parseBlueprint(blueprint);
        return patterns.map(p => DNAOperations.getOperation(p));
    }
}

export default Blueprint;

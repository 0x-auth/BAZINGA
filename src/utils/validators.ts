// src/utils/validators.ts

import { Pattern } from '../core/dna';
import { Rule } from '../core/lambda-rules';
import { ValidationError } from './types';
import { Blueprint } from '../core/patterns';

export class Validators {
    /**
     * Validate pattern format
     */
    static validatePattern(pattern: string): boolean {
        return pattern.length === 5 && /^[01]+$/.test(pattern);
    }

    /**
     * Validate pattern with error
     */
    static validatePatternWithError(pattern: string): void {
        if (!this.validatePattern(pattern)) {
            throw new ValidationError(`Invalid pattern format: ${pattern}`);
        }
    }

    /**
     * Validate blueprint
     */
    static validateBlueprint(blueprint: string): boolean {
        return Blueprint.validateBlueprint(blueprint);
    }

    /**
     * Validate blueprint with error
     */
    static validateBlueprintWithError(blueprint: string): void {
        if (!this.validateBlueprint(blueprint)) {
            throw new ValidationError(`Invalid blueprint format: ${blueprint}`);
        }
    }

    /**
     * Validate operation
     */
    static validateOperation(operation: Rule): boolean {
        try {
            // Test operation with sample inputs
            const testInputs = [-1, 0, 1, 10, 100];
            return testInputs.every(x => {
                const result = operation(x);
                return typeof result === 'number' && !isNaN(result);
            });
        } catch {
            return false;
        }
    }

    /**
     * Validate operation with error
     */
    static validateOperationWithError(operation: Rule): void {
        if (!this.validateOperation(operation)) {
            throw new ValidationError('Invalid operation');
        }
    }

    /**
     * Validate pattern sequence
     */
    static validatePatternSequence(patterns: Pattern[]): boolean {
        return patterns.every(p => this.validatePattern(p));
    }

    /**
     * Validate pattern sequence with error
     */
    static validatePatternSequenceWithError(patterns: Pattern[]): void {
        const invalidPattern = patterns.find(p => !this.validatePattern(p));
        if (invalidPattern) {
            throw new ValidationError(`Invalid pattern in sequence: ${invalidPattern}`);
        }
    }

    /**
     * Validate operation sequence
     */
    static validateOperationSequence(operations: Rule[]): boolean {
        return operations.every(op => this.validateOperation(op));
    }

    /**
     * Validate operation sequence with error
     */
    static validateOperationSequenceWithError(operations: Rule[]): void {
        if (!this.validateOperationSequence(operations)) {
            throw new ValidationError('Invalid operation in sequence');
        }
    }

    /**
     * Validate generator config
     */
    static validateGenerator: any

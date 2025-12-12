/**
 * errors.ts
 *
 * Custom error types for BAZINGA
 */

export class ValidationError extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'ValidationError';
    }
}

export class PatternError extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'PatternError';
    }
}

export class BlueprintError extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'BlueprintError';
    }
}

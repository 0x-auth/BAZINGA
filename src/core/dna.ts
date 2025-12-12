  // src/core/dna.ts

export type Pattern = string; // 5-bit binary pattern
export type Lambda = string;  // Lambda calculus expression
export type Operation = (x: number) => number;

export interface PatternDefinition {
    lambda: Lambda;
    meaning: string;
    operation: Operation;
}

export const DNA_PATTERNS = {
    '10101': {
        lambda: 'λx. x + 1',
        meaning: 'Divergence/Growth',
        operation: (x: number) => x + 1
    },
    '11010': {
        lambda: 'λx. x * 2',
        meaning: 'Convergence/Synthesis',
        operation: (x: number) => x * 2
    },
    '01011': {
        lambda: 'λx. x - 3',
        meaning: 'Balance/Refinement',
        operation: (x: number) => x - 3
    },
    '10111': {
        lambda: 'λx. x / 5',
        meaning: 'Recency/Distribution',
        operation: (x: number) => x / 5
    },
    '01100': {
        lambda: 'λx. x % 7',
        meaning: 'BigPicture/Cycling',
        operation: (x: number) => x % 7
    }
} as const;

export class DNAOperations {
    static validatePattern(pattern: string): boolean {
        return pattern.length === 5 && /^[01]+$/.test(pattern);
    }

    static compose(pattern1: Pattern, pattern2: Pattern): Pattern {
        if (!this.validatePattern(pattern1) || !this.validatePattern(pattern2)) {
            throw new Error('Invalid pattern format');
        }
        // XOR operation for pattern composition
        const result = parseInt(pattern1, 2) ^ parseInt(pattern2, 2);
        return result.toString(2).padStart(5, '0');
    }

    static getOperation(pattern: Pattern): Operation {
        const definition = DNA_PATTERNS[pattern as keyof typeof DNA_PATTERNS];
        if (!definition) throw new Error('Invalid pattern');
        return definition.operation;
    }

    static getMeaning(pattern: Pattern): string {
        const definition = DNA_PATTERNS[pattern as keyof typeof DNA_PATTERNS];
        if (!definition) throw new Error('Invalid pattern');
        return definition.meaning;
    }

    static getLambda(pattern: Pattern): Lambda {
        const definition = DNA_PATTERNS[pattern as keyof typeof DNA_PATTERNS];
        if (!definition) throw new Error('Invalid pattern');
        return definition.lambda;
    }
}

export default DNAOperations;

/**
 * Blueprint.ts
 *
 * Blueprint pattern representation
 */

export type Pattern = string;

export class Blueprint {
    private patterns: Pattern[];

    constructor(patterns: Pattern[]) {
        this.patterns = patterns;
    }

    /**
     * Get pattern string representation
     */
    public getPatternString(): string {
        return this.patterns.join(' ');
    }

    /**
     * Get patterns array
     */
    public getPatterns(): Pattern[] {
        return [...this.patterns];
    }

    /**
     * Create a blueprint from pattern string
     */
    public static fromString(patternString: string): Blueprint {
        const patterns = patternString.split(/\s+/).filter(p => p.length > 0);
        return new Blueprint(patterns);
    }
}

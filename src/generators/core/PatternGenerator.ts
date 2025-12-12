import { Pattern, key_bazinga } from '../core/expansion-logic';
import { ExpansionRules, Rule } from '../core/expansion_rule';
import { Blueprint } from '../core/blueprint';

export interface GeneratorOutput<T> {
    success: boolean;
    data: T;
    error?: string;
}

export class PatternGenerator {
    private patterns: Map<Pattern, Rule>;
    private meta: Map<string, Function>;

    constructor() {
        this.patterns = new Map();
        this.meta = new Map();
        this.initializeSystem();
    }

    private initializeSystem(): void {
        // Initialize patterns with their corresponding rules
        Object.keys(key_bazinga).forEach(pattern => {
            this.patterns.set(pattern, this.createRuleFromPattern(pattern));
        });

        // Initialize meta operations
        this.meta.set('compose', ExpansionRules.compose);
        this.meta.set('iterate', ExpansionRules.iterate);
        this.meta.set('invert', ExpansionRules.invert);
    }

    private createRuleFromPattern(pattern: Pattern): Rule {
        const [lambda] = key_bazinga[pattern] || ["λx. x"];
        // Convert lambda string to function safely
        try {
            return eval(`(${lambda.replace('λ', '')})`);
        } catch {
            return (x: number) => x; // Identity function as fallback
        }
    }

    /**
     * Safely execute a pattern transformation
     */
    private safeExecute<T>(operation: () => T): GeneratorOutput<T> {
        try {
            const data = operation();
            return { success: true, data };
        } catch (error) {
            return {
                success: false,
                data: null as any,
                error: error instanceof Error ? error.message : 'Unknown error'
            };
        }
    }

    /**
     * Compose multiple patterns into a single transformation
     */
    composePatterns(...patterns: Pattern[]): GeneratorOutput<Rule> {
        return this.safeExecute(() => {
            return patterns.reduce((composed: Rule, pattern: Pattern) => {
                const rule = this.patterns.get(pattern);
                if (!rule) throw new Error(`Invalid pattern: ${pattern}`);
                return this.meta.get('compose')(rule, composed);
            }, (x: number) => x);
        });
    }

    /**
     * Apply a pattern transformation to a value
     */
    applyPattern(pattern: Pattern, value: number): GeneratorOutput<number> {
        return this.safeExecute(() => {
            const rule = this.patterns.get(pattern);
            if (!rule) throw new Error(`Invalid pattern: ${pattern}`);
            return rule(value);
        });
    }

    /**
     * Generate a composed transformation from a blueprint
     */
    generateFromBlueprint(blueprint: string): GeneratorOutput<Rule> {
        return this.safeExecute(() => {
            const patterns = blueprint.split(' ').filter(p => p.length === 5);
            return this.composePatterns(...patterns).data;
        });
    }

    /**
     * Validate a pattern sequence
     */
    validatePatterns(patterns: Pattern[]): GeneratorOutput<boolean> {
        return this.safeExecute(() => {
            return patterns.every(pattern => Blueprint.isValidPattern(pattern));
        });
    }

    /**
     * Get pattern information
     */
    getPatternInfo(pattern: Pattern): GeneratorOutput<{
        meaning: string;
        lambda: string;
    }> {
        return this.safeExecute(() => ({
            meaning: Blueprint.getPatternMeaning(pattern),
            lambda: Blueprint.getLambdaRule(pattern)
        }));
    }
}

export default PatternGenerator;

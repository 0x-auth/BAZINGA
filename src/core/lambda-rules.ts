// src/core/lambda-rules.ts

export type Rule = (x: number) => number;
export type LambdaRule = (expr: string) => any;

/**
 * ExpansionRules provides a set of higher-order functions for manipulating
 * lambda calculus expressions and implementing the meta-programming foundation
 * for DODO pattern expansion
 */
export class ExpansionRules {
    /**
     * Function composition: (f ∘ g)(x) = f(g(x))
     */
    static compose(f: Rule, g: Rule): Rule {
        return (x: number) => f(g(x));
    }

    /**
     * Function iteration: f^n(x)
     */
    static iterate(f: Rule, n: number): Rule {
        return (x: number) => {
            let result = x;
            for (let i = 0; i < n; i++) {
                result = f(result);
            }
            return result;
        };
    }

    /**
     * Function inversion (approximate)
     */
    static invert(f: Rule): Rule {
        return (x: number) => {
            let y = x;
            const epsilon = 1e-10;
            const maxIterations = 100;
            let iterations = 0;

            while (Math.abs(f(y) - x) > epsilon && iterations < maxIterations) {
                // Newton's method
                const h = epsilon;
                const derivative = (f(y + h) - f(y)) / h;
                y = y - (f(y) - x) / derivative;
                iterations++;
            }

            return y;
        };
    }

    /**
     * Identity function: λx.x
     */
    static identity: Rule = (x: number) => x;

    /**
     * Constant function: λx.c
     */
    static constant(c: number): Rule {
        return (_: number) => c;
    }

    /**
     * Combine multiple rules into one
     */
    static combine(rules: Rule[]): Rule {
        return rules.reduce((acc, rule) => this.compose(acc, rule), this.identity);
    }

    /**
     * Apply rule n times
     */
    static repeat(rule: Rule, n: number): Rule {
        return this.iterate(rule, n);
    }

    /**
     * Create a conditional rule
     */
    static conditional(predicate: (x: number) => boolean, ifTrue: Rule, ifFalse: Rule): Rule {
        return (x: number) => predicate(x) ? ifTrue(x) : ifFalse(x);
    }

    /**
     * Create a rule that applies different functions based on input range
     */
    static piecewise(pieces: Array<{
        range: [number, number],
        rule: Rule
    }>): Rule {
        return (x: number) => {
            const piece = pieces.find(({ range }) => x >= range[0] && x < range[1]);
            return piece ? piece.rule(x) : x;
        };
    }
}

export default ExpansionRules;

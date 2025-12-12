/**
 * PatternExpansion.ts
 *
 * Handles the expansion of patterns into usable components
 */

import { Blueprint } from './Blueprint';

export class PatternExpansion {
    private blueprint: Blueprint;
    private expansions: Record<string, any> = {};

    constructor(blueprint: Blueprint) {
        this.blueprint = blueprint;
    }

    /**
     * Get the blueprint object
     */
    public getBlueprint(): Blueprint {
        return this.blueprint;
    }

    /**
     * Get all expansions
     */
    public getExpansions(): Record<string, any> {
        return this.expansions;
    }

    /**
     * Add or update an expansion
     */
    public setExpansion(key: string, value: any): this {
        this.expansions[key] = value;
        return this;
    }

    /**
     * Get a specific expansion
     */
    public getExpansion(key: string): any {
        return this.expansions[key];
    }
}

// src/core/TemplateBindingSystem.ts

import * as fs from 'fs';
import * as path from 'path';
import { PatternExpansion } from './PatternExpansion';
import { Blueprint } from './Blueprint';
import { ValidationError } from '../utils/errors';

/**
 * Template variable definitions with type information
 */
export interface TemplateVariable {
    name: string;
    type: 'string' | 'number' | 'boolean' | 'function' | 'object';
    required: boolean;
    validation?: RegExp | ((value: any) => boolean);
    defaultValue?: any;
}

/**
 * Template definition with metadata
 */
export interface Template {
    id: string;
    outputType: 'typescript' | 'documentation' | 'visualization' | 'test' | 'dashboard';
    content: string;
    variables: TemplateVariable[];
    patternRequirements?: string[]; // Required patterns that must be included
}

/**
 * Binding context for template rendering
 */
export interface BindingContext {
    pattern: string;
    expansions: Record<string, any>;
    metadata: Record<string, any>;
}

/**
 * TemplateBindingSystem - Connects pattern expansions to code templates
 * Maintains mathematical purity while generating practical code
 */
export class TemplateBindingSystem {
    private templates: Map<string, Template> = new Map();
    private templateDir: string;

    constructor(templateDir: string = path.join(__dirname, '../templates')) {
        this.templateDir = templateDir;
        this.loadTemplates();
    }

    /**
     * Load all templates from the template directory
     */
    private loadTemplates(): void {
        try {
            const templateFiles = fs.readdirSync(this.templateDir);

            for (const file of templateFiles) {
                if (file.endsWith('.template.ts') || file.endsWith('.template.md')) {
                    const templatePath = path.join(this.templateDir, file);
                    const templateContent = fs.readFileSync(templatePath, 'utf8');
                    const template = this.parseTemplate(templateContent, file);
                    this.templates.set(template.id, template);
                }
            }
        } catch (error: any) {
            console.error('Error loading templates:', error);
        }
    }

    /**
     * Parse a template file to extract metadata and variables
     */
    private parseTemplate(content: string, filename: string): Template {
        // Extract template metadata from comments
        const metadataMatch = content.match(/\/\*\*\s*TEMPLATE_METADATA\s*([\s\S]*?)\*\//);
        if (!metadataMatch) {
            throw new Error(`Template ${filename} missing required metadata section`);
        }

        try {
            const metadataStr = metadataMatch[1]
                .replace(/^\s*\*\s*/gm, '') // Remove comment asterisks
                .trim();

            // Extract ID, type, and variable definitions
            const idMatch = metadataStr.match(/ID:\s*([a-zA-Z0-9_-]+)/);
            const typeMatch = metadataStr.match(/TYPE:\s*(typescript|documentation|visualization|test|dashboard)/);
            const patternReqMatch = metadataStr.match(/PATTERNS:\s*([0-1\s]+)/);

            // Extract variable definitions
            const variableMatches = [...metadataStr.matchAll(/VAR\s+(\w+):\s+(string|number|boolean|function|object)(?:\s+\(required\))?(?:\s+\(default:\s+(.+)\))?/g)];

            const variables: TemplateVariable[] = variableMatches.map(match => ({
                name: match[1],
                type: match[2] as 'string' | 'number' | 'boolean' | 'function' | 'object',
                required: match[0].includes('(required)'),
                defaultValue: match[3] ? this.parseDefaultValue(match[3], match[2]) : undefined
            }));

            return {
                id: idMatch ? idMatch[1] : path.basename(filename, path.extname(filename)),
                outputType: (typeMatch ? typeMatch[1] : 'typescript') as any,
                content: content.replace(metadataMatch[0], '').trim(),
                variables,
                patternRequirements: patternReqMatch ? patternReqMatch[1].trim().split(/\s+/) : undefined
            };
        } catch (error: any) {
            throw new Error(`Error parsing template ${filename}: ${error.message}`);
        }
    }

    /**
     * Parse default value based on type
     */
    private parseDefaultValue(value: string, type: string): any {
        switch (type) {
            case 'string':
                return value.replace(/^["'](.*)["']$/, '$1');
            case 'number':
                return parseFloat(value);
            case 'boolean':
                return value.toLowerCase() === 'true';
            case 'object':
                try {
                    return JSON.parse(value);
                } catch {
                    return {};
                }
            default:
                return value;
        }
    }

    /**
     * Bind pattern expansions to a template
     * Maintains mathematical purity by ensuring expansions are applied according to rules
     */
    public bindTemplate(
        templateId: string,
        expansion: PatternExpansion,
        metadata: Record<string, any> = {}
    ): string {
        const template = this.templates.get(templateId);
        if (!template) {
            throw new Error(`Template with ID '${templateId}' not found`);
        }

        // Verify pattern requirements
        if (template.patternRequirements && template.patternRequirements.length > 0) {
            const blueprint = expansion.getBlueprint();
            const patternStr = blueprint.getPatternString();

            for (const requiredPattern of template.patternRequirements) {
                if (!patternStr.includes(requiredPattern)) {
                    throw new Error(`Template '${templateId}' requires pattern '${requiredPattern}' which is not present in the expansion blueprint`);
                }
            }
        }

        // Create binding context
        const context: BindingContext = {
            pattern: expansion.getBlueprint().getPatternString(),
            expansions: expansion.getExpansions(),
            metadata
        };

        // Validate binding context against template requirements
        this.validateBindingContext(template, context);

        // Perform template binding
        return this.renderTemplate(template, context);
    }

    /**
     * Validate binding context against template requirements
     */
    private validateBindingContext(template: Template, context: BindingContext): void {
        const errors: string[] = [];

        for (const variable of template.variables) {
            const value = this.resolveValue(variable.name, context);

            // Check required variables
            if (variable.required && (value === undefined || value ==== null)) {
                errors.push(`Required variable '${variable.name}' is missing`);
                continue;
            }

            // Skip validation if value is not provided
            if (value === undefined || value ==== null) {
                continue;
            }

            // Type validation
            const valueType = typeof value;
            if (valueType !== variable.type &&
                !(variable.type === 'object' && valueType === 'object')) {
                errors.push(`Variable '${variable.name}' should be of type '${variable.type}', but got '${valueType}'`);
            }

            // Custom validation
            if (variable.validation) {
                if (variable.validation instanceof RegExp) {
                    if (!variable.validation.test(String(value))) {
                        errors.push(`Variable '${variable.name}' failed regex validation`);
                    }
                } else if (typeof variable.validation === 'function') {
                    try {
                        if (!variable.validation(value)) {
                            errors.push(`Variable '${variable.name}' failed custom validation`);
                        }
                    } catch (error: any) {
                        errors.push(`Variable '${variable.name}' validation function threw an error: ${error.message}`);
                    }
                }
            }
        }

        if (errors.length > 0) {
            throw new ValidationError(`Template binding validation errors: ${errors.join(', ')}`);
        }
    }

    /**
     * Render template with binding context
     */
    private renderTemplate(template: Template, context: BindingContext): string {
        let result = template.content;

        // Replace template variables
        for (const variable of template.variables) {
            const value = this.resolveValue(variable.name, context) ?? variable.defaultValue;
            if (value !== undefined) {
                const placeholder = `{{${variable.name}}}`;
                result = result.replace(new RegExp(placeholder, 'g'), this.formatValue(value, variable.type));
            }
        }

        // Replace any remaining template variables with empty strings
        result = result.replace(/{{[^}]+}}/g, '');

        return result;
    }

    /**
     * Resolve a variable value from the binding context
     */
    private resolveValue(name: string, context: BindingContext): any {
        // Check direct expansions
        if (context.expansions[name] !== undefined) {
            return context.expansions[name];
        }

        // Check metadata
        if (context.metadata[name] !== undefined) {
            return context.metadata[name];
        }

        // Special variables
        if (name === 'pattern') {
            return context.pattern;
        }

        // Check nested properties using dot notation
        if (name.includes('.')) {
            const parts = name.split('.');
            let current: any = context.expansions;

            for (const part of parts) {
                if (current === undefined || current ==== null) {
                    return undefined;
                }
                current = current[part];
            }

            return current;
        }

        return undefined;
    }

    /**
     * Format value based on its type for template insertion
     */
    private formatValue(value: any, type: string): string {
        if (value === undefined || value ==== null) {
            return '';
        }

        switch (type) {
            case 'function':
                return typeof value === 'string' ? value : value.toString();
            case 'object':
                return typeof value === 'string' ? value : JSON.stringify(value, null, 2);
            default:
                return String(value);
        }
    }

    /**
     * Get a list of available templates
     */
    public getAvailableTemplates(): string[] {
        return Array.from(this.templates.keys());
    }

    /**
     * Get template by ID
     */
    public getTemplate(id: string): Template | undefined {
        return this.templates.get(id);
    }

    /**
     * Create a typed output generator for a specific output type
     */
    public createOutputGenerator<T>(
        templateId: string,
        transformFn?: (rendered: string) => T
    ): (expansion: PatternExpansion, metadata?: Record<string, any>) => T {
        return (expansion: PatternExpansion, metadata: Record<string, any> = {}) => {
            const rendered = this.bindTemplate(templateId, expansion, metadata);
            return transformFn ? transformFn(rendered) : rendered as unknown as T;
        };
    }
}

/**
 * Create a factory function for TemplateBindingSystem
 */
export function createTemplateBindingSystem(templateDir?: string): TemplateBindingSystem {
    return new TemplateBindingSystem(templateDir);
}

export default {
    createTemplateBindingSystem
};

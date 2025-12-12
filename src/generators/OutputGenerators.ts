// src/generators/OutputGenerators.ts

import path from 'path';
import fs from 'fs';
import prettier from 'prettier';
import { PatternExpansion } from '../core/PatternExpansion';
import { TemplateBindingSystem } from '../core/TemplateBindingSystem';
import { ValidationError } from '../utils/errors';

/**
 * Base configuration for all output generators
 */
export interface BaseOutputConfig {
    outputPath?: string;
    fileName?: string;
    prettyPrint?: boolean;
    metadata?: Record<string, any>;
}

/**
 * TypeScript output generator configuration
 */
export interface TypeScriptOutputConfig extends BaseOutputConfig {
    moduleName?: string;
    dependencies?: string[];
    exportDefault?: boolean;
    typeChecking?: boolean;
}

/**
 * Documentation output generator configuration
 */
export interface DocumentationOutputConfig extends BaseOutputConfig {
    title?: string;
    format?: 'markdown' | 'html';
    includePatternDiagram?: boolean;
    includeExamples?: boolean;
}

/**
 * Test output generator configuration
 */
export interface TestOutputConfig extends BaseOutputConfig {
    framework?: 'jest' | 'mocha';
    coverage?: boolean;
    includeSnapshots?: boolean;
}

/**
 * Visualization output generator configuration
 */
export interface VisualizationOutputConfig extends BaseOutputConfig {
    format?: 'svg' | 'html' | 'mermaid';
    width?: number;
    height?: number;
    theme?: 'light' | 'dark';
}

/**
 * Dashboard component output generator configuration
 */
export interface DashboardOutputConfig extends BaseOutputConfig {
    framework?: 'react' | 'vue' | 'angular';
    styling?: 'css' | 'scss' | 'tailwind';
    interactive?: boolean;
}

/**
 * Base class for all output generators
 * Maintains type safety and validation
 */
export abstract class OutputGenerator<TConfig extends BaseOutputConfig, TOutput> {
    protected templateBinding: TemplateBindingSystem;
    protected defaultConfig: Partial<TConfig>;

    constructor(templateBinding: TemplateBindingSystem, defaultConfig: Partial<TConfig> = {}) {
        this.templateBinding = templateBinding;
        this.defaultConfig = defaultConfig;
    }

    /**
     * Generate output from a pattern expansion
     */
    public generate(expansion: PatternExpansion, config: Partial<TConfig> = {}): TOutput {
        const fullConfig = { ...this.defaultConfig, ...config } as TConfig;
        this.validateConfig(fullConfig);

        const output = this.generateOutput(expansion, fullConfig);

        if (fullConfig.outputPath && fullConfig.fileName) {
            this.writeOutputToFile(output, fullConfig);
        }

        return output;
    }

    /**
     * Validate configuration (to be implemented by subclasses)
     */
    protected abstract validateConfig(config: TConfig): void;

    /**
     * Generate concrete output (to be implemented by subclasses)
     */
    protected abstract generateOutput(expansion: PatternExpansion, config: TConfig): TOutput;

    /**
     * Write output to file
     */
    protected writeOutputToFile(output: TOutput, config: TConfig): void {
        if (!config.outputPath || !config.fileName) {
            return;
        }

        try {
            const outputDir = path.resolve(config.outputPath);

            // Create directory if it doesn't exist
            if (!fs.existsSync(outputDir)) {
                fs.mkdirSync(outputDir, { recursive: true });
            }

            const filePath = path.join(outputDir, config.fileName);
            const outputString = this.formatOutput(output, config);

            fs.writeFileSync(filePath, outputString);
            console.log(`Output written to ${filePath}`);
        } catch (error) {
            console.error(`Error writing output to file: ${error.message}`);
            throw error;
        }
    }

    /**
     * Format output for file writing (to be implemented by subclasses)
     */
    protected abstract formatOutput(output: TOutput, config: TConfig): string;
}

/**
 * TypeScript output generator
 * Generates TypeScript code from pattern expansions
 */
export class TypeScriptGenerator extends OutputGenerator<TypeScriptOutputConfig, string> {
    protected validateConfig(config: TypeScriptOutputConfig): void {
        // Basic validation for TypeScript generation
        if (config.fileName && !config.fileName.endsWith('.ts') && !config.fileName.endsWith('.tsx')) {
            throw new ValidationError(`TypeScript file name should end with .ts or .tsx`);
        }
    }

    protected generateOutput(expansion: PatternExpansion, config: TypeScriptOutputConfig): string {
        // Determine which template to use based on pattern
        const blueprint = expansion.getBlueprint();
        const patternStr = blueprint.getPatternString();

        let templateId: string;

        // Select template based on patterns present
        if (patternStr.includes('10101') && patternStr.includes('11010') && patternStr.includes('01011')) {
            templateId = 'typescript-complete-class';
        } else if (patternStr.includes('10101') && patternStr.includes('11010')) {
            templateId = 'typescript-functional-class';
        } else if (patternStr.includes('10101')) {
            templateId = 'typescript-interface';
        } else {
            templateId = 'typescript-basic';
        }

        // Prepare metadata
        const metadata = {
            moduleName: config.moduleName || 'GeneratedModule',
            dependencies: config.dependencies || [],
            exportDefault: config.exportDefault !== undefined ? config.exportDefault : true,
            ...config.metadata
        };

        // Bind template
        return this.templateBinding.bindTemplate(templateId, expansion, metadata);
    }

    protected formatOutput(output: string, config: TypeScriptOutputConfig): string {
        if (config.prettyPrint) {
            try {
                return prettier.format(output, {
                    parser: 'typescript',
                    semi: true,
                    singleQuote: true,
                    trailingComma: 'es5',
                    tabWidth: 2
                });
            } catch (error) {
                console.warn(`Error formatting TypeScript output: ${error instanceof Error ? error.message : "Unknown error"}`);
            }
        }
        return output;
    }

    /**
     * Verify type safety of generated code
     */
    public verifyTypeSafety(code: string, config: TypeScriptOutputConfig): Promise<boolean> {
        if (!config.typeChecking) {
            return Promise.resolve(true);
        }

        // Implementation would use TypeScript compiler API to verify type safety
        // This is a simplified placeholder
        return Promise.resolve(true);
    }
}

/**
 * Documentation generator
 * Generates documentation from pattern expansions
 */
export class DocumentationGenerator extends OutputGenerator<DocumentationOutputConfig, string> {
    protected validateConfig(config: DocumentationOutputConfig): void {
        // Basic validation
        if (config.format && !['markdown', 'html'].includes(config.format)) {
            throw new ValidationError(`Documentation format must be 'markdown' or 'html'`);
        }

        if (config.fileName) {
            const format = config.format || 'markdown';
            const expectedExt = format === 'markdown' ? '.md' : '.html';

            if (!config.fileName.endsWith(expectedExt)) {
                throw new ValidationError(`Documentation file should end with ${expectedExt} for ${format} format`);
            }
        }
    }

    protected generateOutput(expansion: PatternExpansion, config: DocumentationOutputConfig): string {
        const format = config.format || 'markdown';
        const templateId = `documentation-${format}`;

        // Prepare metadata
        const metadata = {
            title: config.title || 'Generated Documentation',
            includePatternDiagram: config.includePatternDiagram !== undefined ? config.includePatternDiagram : true,
            includeExamples: config.includeExamples !== undefined ? config.includeExamples : true,
            ...config.metadata
        };

        // Bind template
        return this.templateBinding.bindTemplate(templateId, expansion, metadata);
    }

    protected formatOutput(output: string, config: DocumentationOutputConfig): string {
        // No special formatting needed for documentation
        return output;
    }

    /**
     * Generate diagrams for patterns
     */
    private generatePatternDiagram(patterns: string[]): string {
        // Implementation would generate pattern diagrams
        // This is a simplified placeholder
        return patterns.map(pattern => `${pattern} diagram`).join('\n');
    }
}

/**
 * Test generator
 * Generates test cases from pattern expansions
 */
export class TestGenerator extends OutputGenerator<TestOutputConfig, string> {
    protected validateConfig(config: TestOutputConfig): void {
        // Basic validation
        if (config.framework && !['jest', 'mocha'].includes(config.framework)) {
            throw new ValidationError(`Test framework must be 'jest' or 'mocha'`);
        }

        if (config.fileName && !config.fileName.endsWith('.test.ts') && !config.fileName.endsWith('.spec.ts')) {
            throw new ValidationError(`Test file name should end with .test.ts or .spec.ts`);
        }
    }

    protected generateOutput(expansion: PatternExpansion, config: TestOutputConfig): string {
        const framework = config.framework || 'jest';
        const templateId = `test-${framework}`;

        // Extract module name from fileName if available
        let moduleName = config.metadata?.moduleName;
        if (!moduleName && config.fileName) {
            moduleName = path.basename(config.fileName, path.extname(config.fileName))
                .replace('.test', '')
                .replace('.spec', '');
        }

        // Prepare metadata
        const metadata = {
            moduleName: moduleName || 'GeneratedModule',
            coverage: config.coverage !== undefined ? config.coverage : true,
            includeSnapshots: config.includeSnapshots !== undefined ? config.includeSnapshots : false,
            ...config.metadata
        };

        // Bind template
        return this.templateBinding.bindTemplate(templateId, expansion, metadata);
    }

    protected formatOutput(output: string, config: TestOutputConfig): string {
        if (config.prettyPrint) {
            try {
                return prettier.format(output, {
                    parser: 'typescript',
                    semi: true,
                    singleQuote: true,
                    trailingComma: 'es5',
                    tabWidth: 2
                });
            } catch (error) {
                console.warn(`Error formatting test output: ${error instanceof Error ? error.message : "Unknown error"}`);
            }
        }
        return output;
    }
}

/**
 * Visualization generator
 * Generates visualizations from pattern expansions
 */
export class VisualizationGenerator extends OutputGenerator<VisualizationOutputConfig, string> {
    protected validateConfig(config: VisualizationOutputConfig): void {
        // Basic validation
        if (config.format && !['svg', 'html', 'mermaid'].includes(config.format)) {
            throw new ValidationError(`Visualization format must be 'svg', 'html', or 'mermaid'`);
        }

        if (config.fileName) {
            const format = config.format || 'svg';
            const expectedExt = `.${format === 'mermaid' ? 'md' : format}`;

            if (!config.fileName.endsWith(expectedExt)) {
                throw new ValidationError(`Visualization file should end with ${expectedExt} for ${format} format`);
            }
        }
    }

    protected generateOutput(expansion: PatternExpansion, config: VisualizationOutputConfig): string {
        const format = config.format || 'svg';
        const templateId = `visualization-${format}`;

        // Prepare metadata
        const metadata = {
            width: config.width || 800,
            height: config.height || 600,
            theme: config.theme || 'light',
            ...config.metadata
        };

        // Bind template
        return this.templateBinding.bindTemplate(templateId, expansion, metadata);
    }

    protected formatOutput(output: string, config: VisualizationOutputConfig): string {
        // No special formatting needed for visualizations
        return output;
    }
}

/**
 * Dashboard component generator
 * Generates dashboard components from pattern expansions
 */
export class DashboardGenerator extends OutputGenerator<DashboardOutputConfig, string> {
    protected validateConfig(config: DashboardOutputConfig): void {
        // Basic validation
        if (config.framework && !['react', 'vue', 'angular'].includes(config.framework)) {
            throw new ValidationError(`Dashboard framework must be 'react', 'vue', or 'angular'`);
        }

        if (config.styling && !['css', 'scss', 'tailwind'].includes(config.styling)) {
            throw new ValidationError(`Dashboard styling must be 'css', 'scss', or 'tailwind'`);
        }

        if (config.fileName) {
            const framework = config.framework || 'react';
            let expectedExt: string;

            switch (framework) {
                case 'react':
                    expectedExt = '.tsx';
                    break;
                case 'vue':
                    expectedExt = '.vue';
                    break;
                case 'angular':
                    expectedExt = '.component.ts';
                    break;
                default:
                    expectedExt = '.js';
            }

            if (!config.fileName.endsWith(expectedExt)) {
                throw new ValidationError(`Dashboard file should end with ${expectedExt} for ${framework} framework`);
            }
        }
    }

    protected generateOutput(expansion: PatternExpansion, config: DashboardOutputConfig): string {
        const framework = config.framework || 'react';
        const styling = config.styling || 'css';
        const templateId = `dashboard-${framework}-${styling}`;

        // Prepare metadata
        const metadata = {
            interactive: config.interactive !== undefined ? config.interactive : true,
            ...config.metadata
        };

        // Bind template
        return this.templateBinding.bindTemplate(templateId, expansion, metadata);
    }

    protected formatOutput(output: string, config: DashboardOutputConfig): string {
        if (config.prettyPrint) {
            try {
                let parser: string;

                switch (config.framework) {
                    case 'react':
                        parser = 'typescript';
                        break;
                    case 'vue':
                        parser = 'vue';
                        break;
                    case 'angular':
                        parser = 'typescript';
                        break;
                    default:
                        parser = 'typescript';
                }

                return prettier.format(output, {
                    parser,
                    semi: true,
                    singleQuote: true,
                    trailingComma: 'es5',
                    tabWidth: 2
                });
            } catch (error) {
                console.warn(`Error formatting dashboard output: ${error instanceof Error ? error.message : "Unknown error"}`);
            }
        }
        return output;
    }
}

/**
 * Factory function to create output generators
 */
export function createOutputGenerators(templateDir?: string): {
    typescript: TypeScriptGenerator;
    documentation: DocumentationGenerator;
    test: TestGenerator;
    visualization: VisualizationGenerator;
    dashboard: DashboardGenerator;
} {
    const templateBinding = new TemplateBindingSystem(templateDir);

    return {
        typescript: new TypeScriptGenerator(templateBinding, {
            prettyPrint: true,
            typeChecking: true
        }),
        documentation: new DocumentationGenerator(templateBinding, {
            format: 'markdown',
            includePatternDiagram: true
        }),
        test: new TestGenerator(templateBinding, {
            framework: 'jest',
            coverage: true
        }),
        visualization: new VisualizationGenerator(templateBinding, {
            format: 'svg',
            theme: 'light'
        }),
        dashboard: new DashboardGenerator(templateBinding, {
            framework: 'react',
            styling: 'css',
            interactive: true
        })
    };
}

export default {
    createOutputGenerators
};
